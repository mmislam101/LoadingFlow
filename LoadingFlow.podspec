Pod::Spec.new do |s|
s.name             = "LoadingFlow"
s.version          = "1.0.0"
s.summary          = "A loading indicator with multiple sections and some animations"
s.description      = <<-DESC
A loading indicator with multiple sections and some animations
DESC
s.homepage         = "https://github.com/mmislam101/LoadingFlow"
s.license          = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
s.author           = { "Mohammed Islam" => "ksitech101@gmail.com" }
s.source           = { :git => "https://github.com/mmislam101/LoadingFlow.git", :tag => s.version.to_s }

s.platform         = :ios, '6.0'
s.requires_arc     = true

s.source_files     = 'LoadingFlow'

s.dependency       = 'EasyTimeline', :git => 'https://github.com/mmislam101/EasyTimeline.git'

end
