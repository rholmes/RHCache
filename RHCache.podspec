Pod::Spec.new do |s|
    s.name = 'RHCache'
    s.version = '1.0.0'
    s.summary = 'Standard LRU Cache in Objective-C'
    s.source = { :git => 'https://github.com/mszaro/RHCache.git', :branch => 'master' }
    s.authors = 'Ryan Holmes'
    s.license = 'MIT'
    s.homepage = 'https://github.com/rholmes/RHCache'

    s.ios.deployment_target = '8.3'
    s.osx.deployment_target = '10.10'

    s.ios.source_files = 'RHCache/RHCache/**/*.{h,m}'
    s.osx.source_files = 'RHCache/RHCache/**/*.{h,m}'
    s.source_files = 'RHCache/RHCache/**/*.{h,m}'
end
