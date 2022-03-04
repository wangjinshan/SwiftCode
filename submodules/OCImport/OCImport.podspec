
Pod::Spec.new do |spec|

  spec.name         = "OCImport"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of OCImport."

  spec.description  = <<-DESC
图片裁剪框架, 可以进行单图裁剪多图裁剪
                   DESC

  spec.homepage     = "http://wjs/OCImport"

  spec.license      = "MIT"

  spec.ios.deployment_target = "11.0"

  spec.author             = { "山神" => "1096452045@qq.com" }

  spec.source       = { :git => "http://wjs/OCImport.git", :tag => "#{spec.version}" }

  spec.source_files  = "OCImport", "OCImport/**/*.{h, m}"
  spec.exclude_files = "Classes/Exclude"

   spec.resources = "OCImport/*.bundle"
   spec.static_framework = true
   spec.dependency 'Masonry'

end
