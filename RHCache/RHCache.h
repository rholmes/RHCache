//
//  RHCache.h
//  RHCache
//
//  Created by rholmes on 11/17/12.
//  Copyright (c) 2012 Ryan Holmes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RHCacheDelegate;

@interface RHCache : NSObject

@property (nonatomic, assign, readwrite) NSUInteger countLimit;
@property (nonatomic, assign, readwrite) NSTimeInterval timeToLive;
@property (nonatomic, assign, readwrite) NSTimeInterval timeToIdle;
@property (nonatomic, weak) id<RHCacheDelegate> delegate;

- (id)initWithCountLimit:(NSUInteger)limit;
- (id)initWithCountLimit:(NSUInteger)limit timeToLive:(NSTimeInterval)timeToLive timeToIdle:(NSTimeInterval)timeToIdle;
- (id)objectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id)key;
- (NSArray *)allKeys;
- (NSArray *)allValues;
- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;
- (NSUInteger)count;

@end

@protocol RHCacheDelegate <NSObject>

@optional
- (BOOL)cache:(RHCache *)cache shouldEvictObject:(id)obj withKey:(id)key;

@end
