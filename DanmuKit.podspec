Pod::Spec.new do |s|
  s.name             = 'DanmuKit'
  s.version          = '1.0.2'
  s.summary          = 'easy to get danmu from douyu panda qie and longzhu'
 
  s.description      = <<-DESC
Danmu easy to get, easy to get danmu from douyu panda qie and longzhu
                       DESC
 
  s.homepage         = 'https://github.com/ChaosTong/DanmuKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "ChaosTong" => "easyulife@gmail.com" }
  s.source           = { :git => 'https://github.com/ChaosTong/DanmuKit.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '10.0'
  s.source_files = 'DanmuKit/**/*.{h,m,swift}'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
 
end
