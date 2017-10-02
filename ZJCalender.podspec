Pod::Spec.new do |s|
  s.name             = 'ZJCalender'
  s.version          = '0.1.0'
  s.summary          = 'A simple calender.'

  s.description      = <<-DESC
TODO: A calendar that supports a variety of functions, easy to use.
                       DESC

  s.homepage         = 'https://github.com/syik/ZJCalender'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '281925019@qq.com' => 'Jsoul1227@hotmail.com' }
  s.source           = { :git => 'https://github.com/syik/ZJCalender.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZJCalender/Classes/*'
  
  s.resource_bundles = {
	'ZJCalender' => ['ZJCalender/Assets/*']
  }

  s.public_header_files = 'ZJCalender/Classes/*.h'
end
