#
# Be sure to run `pod lib lint Scoper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Scoper'
  s.version          = '0.1.0'
  s.summary          = 'Scoper. is a microframework for performance testing '

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Scoper is a microframework cragted for performance testing purposes.
With help of very few basic types it provides powerful DSL for declarative
description of performance testing suite. Unlike XCTest works on physical iOS devices
                       DESC

  s.homepage         = 'https://github.com/soxjke/Scoper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'soxjke' => 'soxjke@gmail.com' }
  s.source           = { :git => 'https://github.com/soxjke/Scoper.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/@soxjke'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.0'

  s.source_files = 'Scoper/Classes/**/*'
  
end
