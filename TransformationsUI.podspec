Pod::Spec.new do |spec|
  spec.name         = "TransformationsUI"
  spec.version      = "0.0.1"
  spec.summary      = "Filestack's Transformations UI implementation for iOS and iPadOS devices."
  spec.homepage     = "https://www.filestack.com/docs/concepts/transform_ui"
  spec.license      = { :type => 'Apache License, Version 2.0"', :file => "LICENSE" }
  spec.author       = { 'Filestack' => 'ios@filestack.com' }
  spec.source       = { :git => "https://github.com/filepicker/transformations-ui-ios.git", :tag => "#{spec.version}" }

  spec.platform     = :ios, "11.0"

  spec.source_files = "TransformationsUI/**/*.{swift,h,m}"
  spec.resources    = "TransformationsUI/Resources/*.xcassets"
end
