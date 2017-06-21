RHCache (Updated 2017)
=======

RHCache is a simple in-memory LRU cache. It evicts objects based on an LRU algorithm and optional time-to-live and time-to-idle properties. Like NSCache, RHCache is a mutable collection with an API similar to NSDictionary. This is a simple fork of the original project, adding support for Cocoapods and Objective-C Generics.

RHCache objects have the following features:

- Least recently used objects are evicted from the cache when the count limit is exceeded. LRU eviction is disabled when the `countLimit` property is 0 (the default value).
- Objects are evicted when their time-to-live is exceeded. Time-to-live is based on when the object was initially added to the cache. Time-to-live eviction is disabled when the `timeToLive` property is 0 (the default value).
- Objects are evicted when their time-to-idle is exceeded. Time-to-idle is based on the last time an object was retrieved from the cache. Time-to-idle eviction is disabled when the `timeToIdle` property is 0 (the default value).
- The cache is thread-safe, so you can add, remove, and query items in the cache from different threads without having to lock the cache yourself.

How To Use
----------

Just #import the RHCache.h header file and use the initializer that supports the eviction features you need. The following example creates a cache with a limit of 1000 objects, a time-to-live of 10 minutes and a time-to-idle of 5 minutes. RHCache now supports Objective-C generics, meaning you can give it a key type and value type. This is especially handy for interoperability with Swift.

```objective-c
#import RHCache.h
RHCache <NSString *, NSNumber *> * cache = [RHCache cacheWithCountLimit: 1000 timeToLive: 600 timeToIdle: 300];

[cache setObject: @1 forKey: @"One"];
[cache setObject: @2 forKey: @"Two"];

NSNumber * one = [cache objectForKey: @"One"];
NSNumber * two = [cache objectForKey: @"Two"];
```

Installation
----------

The original static library had no support for dependency managers. However, I've converted it into a framework and written a Podspec now. Therefore, the standard deal applies, add it to your podfile:

```ruby
platform :osx, '10.13'
use_frameworks!

target 'YourProject' do
	pod 'RHCache', :git => 'https://github.com/mszaro/RHCache'
end
``` 

I haven't submitted this to the Cocoapods master repo yet as I first intend to see if the original author will merge my fork back in. Until then, you will need to specify the git repo manually (as shown above).

License
----------
All source code is licensed under the [MIT License](https://raw.github.com/rholmes/RHCache/master/LICENSE).