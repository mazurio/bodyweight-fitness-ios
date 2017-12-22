# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'BodyweightFitness' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Bodyweight Fitness
  pod 'RealmSwift', '~> 3.0.2'
  pod 'SwiftyJSON'
  pod 'RxSwift', '~> 3.0'
  pod 'RxCocoa', '~> 3.0'
  pod 'JTAppleCalendar', '~> 7.0'
  pod 'Eureka', '~> 4.0.1'
  pod 'Charts', '~> 3.0.4'
  pod 'SnapKit', '~> 3.2.0'
  pod 'Fabric'
  pod 'Crashlytics'
  
  target 'BodyweightFitnessTests' do
    pod 'Quick'
    pod 'Nimble'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
  	if ['Eureka'].include? target.name
  		target.build_configurations.each do |config|
  			config.build_settings['SWIFT_VERSION'] = '4.0'
  		end
  	end
    
    if ['Charts'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end

end
