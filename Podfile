# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

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
  # Pods for Open Space
  
  # https://stackoverflow.com/a/75729977
  post_install do |installer|
      installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                 end
            end
     end
  end
  
end