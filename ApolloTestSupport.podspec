Pod::Spec.new do |s|
  s.name = 'ApolloTestSupport'
  s.version = `echo "$(scripts/get-version.sh)-connect"`
  s.author = 'Apollo GraphQL'
  s.homepage = 'https://github.com/apollographql/apollo-ios'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = "A GraphQL client for iOS, written in Swift."
  s.source = { :git => 'https://github.com/scorebet/apollo-ios.git', :tag => "#{s.version}-connect" }
  s.requires_arc = true
  s.swift_version = '5.6'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '5.0'
  s.source_files = 'Sources/ApolloTestSupport/*.swift'
  s.dependency 'Apollo/Core'
  s.frameworks = ['XCTest']
end
