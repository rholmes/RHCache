//
//  RHCacheEntry.h
//  RHCache
//
//  Created by rholmes on 11/17/12.
//  Copyright (c) 2012 Ryan Holmes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHCacheEntry : NSObject

@property (nonatomic, strong, readwrite) id key;
@property (nonatomic, strong, readwrite) id object;
@property (nonatomic, assign, readwrite) NSTimeInterval created;
@property (nonatomic, assign, readwrite) NSTimeInterval accessed;

- (id)initWithObject:(id)anObject forKey:(id)aKey;

@end
