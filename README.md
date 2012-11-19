RHCache
=======

RHCache is a simple in-memory LRU cache. It evicts objects based on an LRU algorithm and optional time-to-live and time-to-idle properties. Like NSCache, RHCache is a mutable collection with an API similar to NSDictionary.

RHCache objects have the following features:

- Least recently used objects are evicted from the cache when the count limit is exceeded. LRU eviction is disabled when the `countLimit` property is 0 (the default value).
- Objects are evicted when their time-to-live is exceeded. Time-to-live is based on when the object was initially added to the cache. Time-to-live eviction is disabled when the `timeToLive` property is 0 (the default value).
- Objects are evicted when their time-to-idle is exceeded. Time-to-idle is based on the last time an object was retrieved from the cache. Time-to-idle eviction is disabled when the `timeToIdle` property is 0 (the default value).
- The cache is thread-safe, so you can add, remove, and query items in the cache from different threads without having to lock the cache yourself.

How To Use
----------

Just #import the RHCache.h header file and use the initializer that supports the eviction features you need. The following example creates a cache with a limit of 1000 objects, a time-to-live of 10 minutes and a time-to-idle of 5 minutes.

```objective-c
#import RHCache.h

...

RHCache *cache = [[RHCache alloc] initWithCountLimit:1000 timeToLive:600 timeToIdle:300];

```


Installation
----------
There is no static library or podspec yet, so just copy the following files into your project:

- RHCache.h
- RHCache.m
- RHCacheEntry.h
- RHCacheEntry.m