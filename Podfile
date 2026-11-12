# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'
install! 'cocoapods', :warn_for_unused_master_specs_repo => false

#use_modular_headers!
def shared_pods
  pod 'Alamofire'
  pod 'AlamofireImage'
  pod 'PopupDialog'#, '~> 1.1'
  pod 'Defaults'
  pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift'
  pod 'FirebaseAnalytics'
  #pod 'FirebaseAuth'
  pod 'FirebaseUI/Google'
  pod 'FirebaseUI/OAuth'
  #pod 'FirebaseUI'
  pod 'FirebaseAuthUI'
  pod 'GoogleSignIn'
  #pod 'Zip', '~> 2.1'
  #pod 'ZipArchive'
  pod 'SSZipArchive'
  pod 'IQKeyboardManagerSwift'
  
  pod 'RxSwift', '~> 6.0'
  pod 'RxCocoa', '~> 6.0'
  pod 'Firebase/Crashlytics'
  pod 'FirebasePerformance'
  

  pod 'Firebase'
  
end

target 'Open Space' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  shared_pods
  pod 'Google-Mobile-Ads-SDK'

end

target 'Open Space Desktop' do
  # Exclude GoogleMobileAds for Mac Catalyst
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  shared_pods
end 

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0' # Xcode 26+ rejects anything below iOS 15
      end
    end
  end
end
