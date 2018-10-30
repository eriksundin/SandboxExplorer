#
# Be sure to run `pod lib lint SandboxExplorer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SandboxExplorer'
  s.version          = '2.1.0'
  s.summary          = 'Simple debugging tool for exploring the contents of your iOS app sandbox.'

  s.description      = <<-DESC
This tool provides a simple way to browse the file contents of your iOS app Sandbox.
With the UI provided you can navigate the sandbox content and view the size of files and folders.
Between usages the file sizes are cached and changes in the like are visible in the UI.
                       DESC

  s.homepage         = 'https://github.com/eriksundin/SandboxExplorer'
  s.screenshots     = 'https://github.com/eriksundin/SandboxExplorer/blob/master/ss1.png?raw=true', 'https://github.com/eriksundin/SandboxExplorer/blob/master/ss2.png?raw=true'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Erik Sundin' => 'erik@eriksundin.se' }
  s.source           = { :git => 'https://github.com/eriksundin/SandboxExplorer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/erik_sundin'
  s.swift_version = "4.2"
  s.ios.deployment_target = '8.0'

  s.source_files = 'SandboxExplorer/Classes/**/*'

  s.resource_bundles = {
   'Assets' => ['SandboxExplorer/Assets/*.png']
  }

end
