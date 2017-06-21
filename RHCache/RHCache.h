//
//  RHCache.h
//  RHCache
//
//  Created by rholmes on 11/17/12.
//  Updated by mszaro on 06/20/17.
//  Copyright (c) 2012 Ryan Holmes. All rights reserved.
//

@import Foundation;

@protocol RHCacheDelegate;

@interface RHCache <__covariant KeyType, __covariant ValueType> : NSObject

/**
 * The maximum number of entries in the cache. Upon insertion, if the cache size will exceed this count, the oldest object will be evicted. */
@property (nonatomic, assign, readwrite) NSUInteger countLimit;

/**
 * The maximum age, in seconds, of a cache entry.
 */
@property (nonatomic, assign, readwrite) NSTimeInterval timeToLive;

/**
 * The maximum time since last access, in seconds, of a cache entry.
 */
@property (nonatomic, assign, readwrite) NSTimeInterval timeToIdle;

/**
 * Delegate which can optionally refuse cache eviction.
 */
@property (nonatomic, weak) id <RHCacheDelegate> delegate;

/**
 * Instantiate a new LRU cache with a given maximum size.
 */
- (instancetype) initWithCountLimit: (NSUInteger) limit;

/**
 * Instantiate a new LRU cache with a given maximum size, TTL and TTI.
 */
- (instancetype) initWithCountLimit: (NSUInteger)limit timeToLive:(NSTimeInterval) timeToLive timeToIdle:(NSTimeInterval) timeToIdle;

/**
 * Retrieve an object from the cache.
 */
- (instancetype) objectForKey: (id) key;

/**
 * Store an object in the cache.
 */
- (void) setObject: (ValueType) obj forKey: (KeyType) key;

/**
 * Retrieve an array of all valid cache keys.
 */
- (NSArray <KeyType> *) allKeys;

/**
 * Retrieve an array of all valid cache entries.
 */
- (NSArray <ValueType> *) allValues;

/**
 * Evict an item from the cache.
 */
- (void) removeObjectForKey: (KeyType) key;

/**
 * Evict all entries from the cache.
 */
- (void) removeAllObjects;

/**
 * The current size of the cache.
 */
@property (assign, nonatomic, readonly) NSUInteger count;

@end

@protocol RHCacheDelegate <NSObject>

@optional

/**
 * Informs the receiver that the LRU cache is about to evict a given object.
 * @param object The candidate for eviction.
 * @param key Its associated key.
 * @return YES if the item should be evicted from the cache. NO to force the item to live on in cache.
 */
- (BOOL) cache:(RHCache *) cache shouldEvictObject: (NSObject *) object withKey: (NSObject *) key;

@end
