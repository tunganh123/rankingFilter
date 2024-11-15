#
# Be sure to run `pod lib lint AdsMediationManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AdsMediationManager'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AdsMediationManager.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/NhuomTV/AdsMediationManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NhuomTV' => 'nhuomtv@gmail.com' }
  s.source           = { :git => 'https://github.com/NhuomTV/AdsMediationManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'AdsMediationManager/Classes/**/*'
  
  s.resource_bundles = {
    'AdsMediationManager' => ['AdsMediationManager/Assets/*']
  }
  
  s.dependency 'FirebaseRemoteConfig'
  s.dependency 'FirebaseABTesting'
  s.dependency 'FirebaseAnalytics'
  s.dependency 'FirebaseCrashlytics'
  s.dependency 'AppsFlyerFramework'
  s.dependency 'AppsFlyer-AdRevenue'
  s.dependency 'SwiftyStoreKit'
  s.dependency 'Qonversion'

  s.dependency 'GoogleUserMessagingPlatform', '2.4.0'
  
  s.dependency 'GoogleMobileAdsMediationAppLovin'
  s.dependency 'GoogleMobileAdsMediationMintegral'
  s.dependency 'GoogleMobileAdsMediationVungle'
  s.dependency 'GoogleMobileAdsMediationPangle'
  s.dependency 'AppLovinSDK'#, '12.5.1'beta
  s.static_framework = true
end
