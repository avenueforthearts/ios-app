platform :ios, '10.0'

use_frameworks!

target 'AvenueForTheArts' do
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'RxSwift'
    pod 'Alamofire'
    pod 'RxAlamofire'
    pod 'RxCocoa'
    pod 'AlamofireImage'

    post_install do |installer_representation|
        swift3_pods = [
            'RxSwift',
            'Alamofire',
            'RxAlamofire',
            'RxCocoa',
            'AlamofireImage'
        ]

        installer_representation.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                if swift3_pods.include? target.name
                    config.build_settings['SWIFT_VERSION'] = '3.2'
                end
            end
        end
    end
end
