# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'HRTune' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HRTune
  pod 'KDCircularProgress'
  pod 'Charts', :git => 'https://github.com/danielgindi/Charts.git', :branch => 'master'
  pod 'SnapKit'
  pod 'WCDBSwift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'NSObject+Rx'
  pod 'Zip', '~> 2.1'
  pod 'Eureka'
  pod 'R.swift', '~> 5.0'  # https://github.com/mac-cain13/R.swift
  pod 'Texture', '>= 2.0'
  pod 'lottie-ios'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
    
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

