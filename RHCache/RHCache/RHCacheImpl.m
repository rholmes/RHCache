//
//  RHCache.m
//  RHCache
//
//  Created by rholmes on 11/17/12.
//  Copyright (c) 2012 Ryan Holmes. All rights reserved.
//

#import "RHCacheImpl.h"
#import "RHCacheEntry.h"

@interface RHCache ()

@property (strong, nonatomic) NSMutableDictionary *entries;
@property (strong, nonatomic) NSMutableArray *entriesByTime;

@end

@implementation RHCache

- (id)init
{
    return [self initWithCountLimit:0];
}

- (id)initWithCountLimit:(NSUInteger)limit
{
    return [self initWithCountLimit:limit timeToLive:0 timeToIdle:0];
}

- (id)initWithCountLimit:(NSUInteger)limit timeToLive:(NSTimeInterval)timeToLive timeToIdle:(NSTimeInterval)timeToIdle
{
    self = [super init];
    if (self) {
        _entries = [[NSMutableDictionary alloc] init];
        _entriesByTime = [[NSMutableArray alloc] init];
        
        _countLimit = limit;
        
        // Entries never expire by default
        _timeToLive = timeToLive;
        _timeToIdle = timeToIdle;
    }
    return self;
}


#pragma mark - Public API 

- (id)objectForKey:(id)key
{
    if (!key) {
        return nil;
    }
    
    @synchronized(self) {
        // Look for the cache entry with the given key
        RHCacheEntry *entry = [_entries objectForKey:key];
        if (!entry) {
            return nil;
        }
        
        // Has the entry exceeded the time to live or time to idle?
        if ([self isTimeToLiveExpiredForEntry:entry] || [self isTimeToIdleExpiredForEntry:entry]) {
            // Entry is expired; try to evict it
            if ([self evictCacheEntry:entry]) {
                return nil;
            }
        }
        
        // Update the entry's last accessed time
        [entry setAccessed:[NSDate timeIntervalSinceReferenceDate]];
        
        // Refresh the entry by moving it to the end of the LRU list
        [_entriesByTime removeObjectIdenticalTo:entry];
        [_entriesByTime addObject:entry];
        
        return [entry object];
    }
}

- (void)setObject:(id)obj forKey:(id)key
{
    if (!obj || !key) {
        return;
    }
    
    @synchronized(self) {
        RHCacheEntry *entry = [_entries objectForKey:key];
        if (entry) {
            // Object exists in cache, refresh by removing it from the list
            [_entriesByTime removeObjectIdenticalTo:entry];
        }
        
        // Create a cache entry to contain the given object
        entry = [[RHCacheEntry alloc] initWithObject:obj forKey:key];
        
        // Add the entry to the cache and put it and at the end of the LRU list
        [_entries setObject:entry forKey:key];
        [_entriesByTime addObject:entry];
        
        // Enforce the count limit
        [self evictObjectsExceedingCountLimit];
    }
}

- (NSArray *)allKeys
{
    @synchronized(self) {
        return [_entries allKeys];
    }
}

- (NSArray *)allValues
{
    @synchronized(self) {
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:[_entries count]];
        for (RHCacheEntry *entry in [_entries allValues]) {
            [values addObject:[entry object]];
        }
        return values;
    }
}

- (void)removeObjectForKey:(id)key
{
    @synchronized(self) {
        RHCacheEntry *entry = [_entries objectForKey:key];
        if (entry) {
            [_entries removeObjectForKey:key];
            [_entriesByTime removeObjectIdenticalTo:entry];
        }
    }
}


- (void)removeAllObjects
{
    @synchronized(self) {
        [_entries removeAllObjects];
        [_entriesByTime removeAllObjects];
    }
}

- (NSUInteger)count
{
    @synchronized(self) {
        return [_entries count];
    }
}

#pragma mark - Cache eviction

- (BOOL)evictCacheEntryAtTimeIndex:(NSUInteger)timeIndex
{
    if (timeIndex >= [_entriesByTime count]) {
        return NO;
    }
    
    RHCacheEntry *entry = [_entriesByTime objectAtIndex:timeIndex];
    BOOL evict = YES;
    if ([self.delegate respondsToSelector:@selector(cache:shouldEvictObject:withKey:)]) {
        evict = [self.delegate cache:self shouldEvictObject:entry.object withKey:entry.key];
    }
    
    if (evict) {
        [_entries removeObjectForKey:entry.key];
        [_entriesByTime removeObjectAtIndex:timeIndex];
    }
    
    return evict;
}

- (BOOL)evictCacheEntry:(RHCacheEntry *)entry
{
    NSUInteger timeIndex = [_entriesByTime indexOfObjectIdenticalTo:entry];
    return [self evictCacheEntryAtTimeIndex:timeIndex];
}

- (void)evictObjectsExceedingCountLimit
{
    if (_countLimit == 0) {
        return;
    }
    
    NSUInteger count = [_entriesByTime count];
    if (count == 0) {
        return;
    }
    
    // Remove oldest entries that exceed the count limit
    NSUInteger timeIndex = 0;
    for (NSUInteger i = count; i > _countLimit; i--) {
        BOOL evicted = [self evictCacheEntryAtTimeIndex:timeIndex];
        if (evicted) {
            continue;
        }
        
        // The prior entry was not evicted, so try the next oldest entry
        timeIndex++;
        if (timeIndex >= count ) {
            break;
        }
    }
    
}

- (BOOL)isTimeToLiveExpiredForEntry:(RHCacheEntry *)entry
{
    // Is time to live unlimited?
    if (_timeToLive == 0) {
        return NO;
    }
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    return (now - _timeToLive) > [entry created];
}

- (BOOL)isTimeToIdleExpiredForEntry:(RHCacheEntry *)entry
{
    // Is time to idle unlimited?
    if (_timeToIdle == 0) {
        return NO;
    }
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    return (now - _timeToIdle) > [entry accessed];
}

#pragma mark Factory methods
+(instancetype) cacheWithCountLimit:(NSUInteger)countLimit {
    return [[[self class] alloc] initWithCountLimit: countLimit];
}

+(instancetype) cacheWithCountLimit:(NSUInteger)limit timeToLive:(NSTimeInterval)timeToLive timeToIdle:(NSTimeInterval)timeToIdle
{
    return [[[self class] alloc] initWithCountLimit: limit timeToLive: timeToLive timeToIdle:timeToIdle];
}

@end
