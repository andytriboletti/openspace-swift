# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'Open Space' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Alamofire'
  pod 'AlamofireImage'
  #pod 'MaterialComponents/Buttons+Theming'
  #pod 'MaterialComponents/Buttons'
  pod 'PopupDialog'#, '~> 1.1'
  pod 'Defaults'
  pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift'
  # Add the Firebase pod for Google Analytics
  pod 'FirebaseAnalytics'

  # For Analytics without IDFA collection capability, use this pod instead
  # pod ‘Firebase/AnalyticsWithoutAdIdSupport’

  # Add the pods for any other Firebase products you want to use in your app
  # For example, to use Firebase Authentication and Cloud Firestore
  pod 'FirebaseAuth'
  pod 'FirebaseUI/Google'
  pod 'FirebaseUI/OAuth'
  pod 'FirebaseUI'
  pod 'FirebaseAuthUI'
  pod 'GoogleSignIn'
  pod 'Starscream'
  pod 'Zip', '~> 2.1'
  pod 'ZipArchive'
  pod 'SSZipArchive'
  pod 'Google-Mobile-Ads-SDK'
end

target 'Open Space Mac' do
  # Exclude GoogleMobileAds for Mac Catalyst
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Alamofire'
  pod 'AlamofireImage'
  #pod 'MaterialComponents/Buttons+Theming'
  #pod 'MaterialComponents/Buttons'
  pod 'PopupDialog'#, '~> 1.1'
  pod 'Defaults'
  pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift'
  # Add the Firebase pod for Google Analytics
  pod 'FirebaseAnalytics'

  # For Analytics without IDFA collection capability, use this pod instead
  # pod ‘Firebase/AnalyticsWithoutAdIdSupport’

  # Add the pods for any other Firebase products you want to use in your app
  # For example, to use Firebase Authentication and Cloud Firestore
  pod 'FirebaseAuth'
  pod 'FirebaseUI/Google'
  pod 'FirebaseUI/OAuth'
  pod 'FirebaseUI'
  pod 'FirebaseAuthUI'
  pod 'GoogleSignIn'
  pod 'Starscream'
  pod 'Zip', '~> 2.1'
  pod 'ZipArchive'
  pod 'SSZipArchive'
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
