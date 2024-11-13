Pod::Spec.new do |s|
  s.name         = 'LouisPod'
  s.version      = '0.1.0'
  s.summary      = 'A short description of LouisPod.'

  s.description  = <<-DESC
  A longer description of LouisPod in more detail.ádadadadada
                   DESC

  s.homepage     = 'http://EXAMPLE/LouisPod'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Tunganh' => 'louistunganh@gmail.com' }
  s.source       = { :git => 'https://github.com/YourGitHubUsername/LouisPod.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files  = 'LouisPod/**/*'
  
  s.dependency 'Toast-Swift', '~> 5.1.1'
  s.dependency 'MBProgressHUD'
  s.dependency 'Qonversion'
  s.dependency 'SwiftyStoreKit'
  s.dependency 'RealmSwift'
  s.dependency 'Alamofire'
  s.dependency 'Localize-Swift', '~> 3.2'
  s.dependency 'SVPullToRefresh'
  
  s.dependency 'ProgressHUD', '~> 13.8.4'
  s.dependency 'IQKeyboardManager'
  s.dependency 'FSPagerView'
  s.dependency 'SDWebImage'
  s.dependency 'Swifter', '~> 1.5.0'
  s.dependency "Colorful", "~> 3.0"
  s.dependency 'SwiftyJSON'
  s.dependency 'PanModal'
  s.dependency 'Localize-Swift'
  s.dependency 'UIColor_Hex_Swift'
  s.dependency 'Moya'
end
