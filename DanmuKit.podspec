Pod::Spec.new do |s|
  s.name             = 'DanmuKit'
  s.version          = '0.0.1'
  s.summary          = 'easy to get danmu from douyu panda and longzhu'
 
  s.description      = <<-DESC
Danmu easy to get
                       DESC
 
  s.homepage         = 'https://github.com/ChaosTong/DanmuKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "ChaosTong" => "easyulife@gmail.com" }
  s.source           = { :git => 'https://github.com/ChaosTong/DanmuKit.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '9.0'
  s.source_files = 'DanmuKit/*.{h,m,swift}'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
 
end