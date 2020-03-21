
Pod::Spec.new do |s|

  s.name         = "LWPhotoBrowser"
  s.version      = "0.0.2"
  s.summary      = "图片浏览器"
  s.description  = "一款类似微信图片浏览的库"

  s.homepage     = "https://github.com/LittleCuteCat/LWPhotoBrowser"


  s.license      = { :type => "MIT", :file => "LICENSE.md" }

  s.author             = { "LittleCuteCat" => "weil218@163.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/LittleCuteCat/LWPhotoBrowser.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.dependency "SDWebImage"

end
