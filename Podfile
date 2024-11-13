# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'rankingFilter' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'LouisPod', :path => './Frameworks/LouisPod'
  pod 'AdsMediationManager', :path => './Frameworks/AdsMediationManager'
  pod 'SwiftyStoreKit'
  pod 'Qonversion'
  pod 'SystemServices'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod 'FirebaseMessaging'
  pod 'Firebase/Database'
  pod 'Kingfisher', '~> 7.0'
  pod 'IQKeyboardManagerSwift'
  pod 'DKImagePickerController’
end
post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
