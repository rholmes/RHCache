//
//  RHCacheUnitTests.m
//  RHCache
//
//  Created by Matt Szaro on 6/20/17.
//  Copyright © 2017 mszaro. All rights reserved.
//

@import XCTest;
@import RHCacheOSX;

@interface RHConfigurableCacheDelegate : NSObject <RHCacheDelegate>

@property (nonatomic) BOOL evictionPolicy;

- (id)initWithEvictionPolicy:(BOOL)evictionPolicy;

@end

@implementation RHConfigurableCacheDelegate

- (id)initWithEvictionPolicy:(BOOL)evictionPolicy
{
    self = [super init];
    if (self) {
        _evictionPolicy = evictionPolicy;
    }
    return self;
}

- (BOOL)cache:(RHCache *)cache shouldEvictObject:(id)obj withKey:(id)key
{
    return self.evictionPolicy;
}

@end

@interface RHCacheUnitTests : XCTestCase

@end

@implementation RHCacheUnitTests

- (void)testAddAndRemove
{
    RHCache *cache = [[RHCache alloc] init];
    [cache setObject:@"value1" forKey:@"key1"];
    XCTAssertNotNil([cache objectForKey:@"key1"], @"Failed to add entry to cache");
    XCTAssertEqual([cache count], 1U, @"Cache count should be 1");
    
    [cache removeObjectForKey:@"key1"];
    XCTAssertNil([cache objectForKey:@"key1"], @"Failed to remove entry from cache");
    XCTAssertEqual([cache count], 0U, @"Cache count should be 0");
    
    [cache setObject:@"value2" forKey:@"key2"];
    [cache setObject:@"value3" forKey:@"key3"];
    XCTAssertEqual([cache count], 2U, @"Cache count should be 2");
    
    [cache removeAllObjects];
    XCTAssertNil([cache objectForKey:@"key2"], @"Failed to remove entry from cache");
    XCTAssertEqual([cache count], 0U, @"Cache count should be 0");
    
}

- (void)testUpdate
{
    RHCache *cache = [[RHCache alloc] init];
    [cache setObject:@"value1" forKey:@"key1"];
    
    NSString *value = [cache objectForKey:@"key1"];
    XCTAssertEqual(value, @"value1", @"Incorrect initial value in cache");
    
    [cache setObject:@"value2" forKey:@"key1"];
    value = [cache objectForKey:@"key1"];
    XCTAssertEqual(value, @"value2", @"Incorrect updated value in cache");
    XCTAssertEqual([cache count], 1U, @"Incorrect cache count");
}


- (void)testCountLimitWithEvictingDelegate
{
    NSUInteger countLimit = 2;
    
    RHCache *cache = [[RHCache alloc] initWithCountLimit:countLimit];
    RHConfigurableCacheDelegate *delegate = [[RHConfigurableCacheDelegate alloc] initWithEvictionPolicy:YES];
    cache.delegate = delegate;
    
    // add entries up to count limit
    [cache setObject:@"value1" forKey:@"key1"];
    [cache setObject:@"value2" forKey:@"key2"];
    
    // check count before eviction
    XCTAssertEqual([cache count], countLimit, @"Cache count should be 2");
    
    // add objects exceeding count limit
    [cache setObject:@"value3" forKey:@"key3"];
    [cache setObject:@"value4" forKey:@"key4"];
    XCTAssertEqual([cache count], countLimit, @"Cache count should be 2");
    
    // keep delegate in scope so it doesn't get deallocated above
    delegate = nil;
}

- (void)testCountLimitWithNonEvictingDelegate
{
    NSUInteger countLimit = 2;
    
    RHCache *cache = [[RHCache alloc] initWithCountLimit:countLimit];
    RHConfigurableCacheDelegate *delegate = [[RHConfigurableCacheDelegate alloc] initWithEvictionPolicy:NO];
    cache.delegate = delegate;
    
    // add entries up to count limit
    [cache setObject:@"value1" forKey:@"key1"];
    [cache setObject:@"value2" forKey:@"key2"];
    
    // check count before eviction
    XCTAssertEqual([cache count], countLimit, @"Cache count should be 2");
    
    // add objects exceeding count limit
    [cache setObject:@"value3" forKey:@"key3"];
    [cache setObject:@"value4" forKey:@"key4"];
    XCTAssertEqual([cache count], 4U, @"Cache count should be 4");
    
    // keep delegate in scope so it doesn't get deallocated above
    delegate = nil;
}


- (void)testTimeToLive
{
    NSTimeInterval ttl = 0.2;
    RHCache *cache = [[RHCache alloc] initWithCountLimit:2];
    [cache setTimeToLive:ttl];
    
    [cache setObject:@"value1" forKey:@"key1"];
    
    [NSThread sleepForTimeInterval:0.1];
    XCTAssertNotNil([cache objectForKey:@"key1"], @"Entry should still exist in cache");
    XCTAssertEqual([cache count], 1U, @"Cache count should be 1");
    
    [NSThread sleepForTimeInterval:ttl];
    XCTAssertNil([cache objectForKey:@"key1"], @"Entry should no longer exist in cache");
    XCTAssertEqual([cache count], 0U, @"Cache count should be 0");
}

- (void)testLRUAlgorithm
{
    NSUInteger countLimit = 3;
    RHCache *cache = [[RHCache alloc] initWithCountLimit:countLimit];
    [cache setObject:@"value1" forKey:@"key1"];
    [cache setObject:@"value2" forKey:@"key2"];
    [cache setObject:@"value3" forKey:@"key3"];
    
    // check count before eviction
    XCTAssertEqual([cache count], countLimit, @"Incorrect cache count");
    
    // add object exceeding count limit
    [cache setObject:@"value4" forKey:@"key4"];
    XCTAssertEqual([cache count], countLimit, @"Incorrect cache count");
    XCTAssertNil([cache objectForKey:@"key1"], @"First entry should have been evicted");
    XCTAssertNotNil([cache objectForKey:@"key4"], @"Fourth entry should exist in cache");
    
    // refresh oldest entry
    [cache objectForKey:@"key2"];
    
    // add another object
    [cache setObject:@"value5" forKey:@"key5"];
    XCTAssertEqual([cache count], countLimit, @"Incorrect cache count");
    
    // third entry should be evicted since it is the oldest
    XCTAssertNil([cache objectForKey:@"key3"], @"Third entry should have been evicted");
    XCTAssertNotNil([cache objectForKey:@"key2"], @"Second entry should exist in cache");
    XCTAssertNotNil([cache objectForKey:@"key4"], @"Fourth entry should exist in cache");
    XCTAssertNotNil([cache objectForKey:@"key5"], @"Fifth entry should exist in cache");
}

@end


