#
# Be sure to run `pod lib lint RegexScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RegexScanner'
  s.version          = '0.1.0'
  s.summary          = 'RegexScanner is a Camera scanner to read values that match with a regex.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  RegexScanner is a Camera scanner to read values that match with a regex. Just send a regex parameter and wait the scanner return the recognized value.
                       DESC

  s.homepage         = 'https://github.com/narlei/regexscanner'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Narlei Moreira' => 'narlei.guitar@gmail.com' }
  s.source           = { :git => 'https://github.com/narlei/regexscanner.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/narleimoreira'

  s.ios.deployment_target = '13.0'
  s.swift_versions   = '5.0'

  s.source_files = 'RegexScanner/Classes/**/*'
end
