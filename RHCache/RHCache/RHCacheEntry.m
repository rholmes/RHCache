//
//  RHCacheEntry.m
//  RHCache
//
//  Created by rholmes on 11/17/12.
//  Copyright (c) 2012 Ryan Holmes. All rights reserved.
//

#import "RHCacheEntry.h"

@implementation RHCacheEntry

- (id)init
{
    return [self initWithObject:nil forKey:nil];
}

- (id)initWithObject:(id)anObject forKey:(id)aKey
{
    self = [super init];
    if (self) {
        _key = aKey;
        _object = anObject;
        _created = [NSDate timeIntervalSinceReferenceDate];
        _accessed = _created;
    }
    
    return self;
}

@end
