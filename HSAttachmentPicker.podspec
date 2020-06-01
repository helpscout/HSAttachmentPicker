Pod::Spec.new do |s|
  s.name             = 'HSAttachmentPicker'
  s.version          = '1.1.0'
  s.summary          = 'Provides a UIAlertMenu to access photos, camera, and document browser'

  s.homepage         = 'https://github.com/helpscout/HSAttachmentPicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Help Scout' => 'developer@helpscout.com' }
  s.source           = { :git => 'https://github.com/helpscout/HSAttachmentPicker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'HSAttachmentPicker/**/*.{h,m}'
end
