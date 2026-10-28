#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'amazon_s3_cognito'
  s.version          = '0.9.1'
  s.summary          = 'This plugin allows users to  upload and delete files on amazon s3 storage'
  s.description      = <<-DESC
This plugin allows users to list, upload and delete image for amazon s3 cognito
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Fam Properties' => 'no-reply@famproperties.com' }
  s.source           = { :path => '.' }
  s.source_files = 'amazon_s3_cognito/Sources/amazon_s3_cognito/**/*'
  s.dependency 'Flutter'
  s.dependency 'AWSS3'
  s.dependency 'AWSCore'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end

