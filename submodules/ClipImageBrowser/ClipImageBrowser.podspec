
Pod::Spec.new do |spec|

  spec.name         = "ClipImageBrowser"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of ClipImageBrowser."

  spec.description  = <<-DESC
图片裁剪框架, 可以进行单图裁剪多图裁剪
                   DESC

  spec.homepage     = "http://wjs/ClipImageBrowser"

  spec.license      = "MIT"

  spec.ios.deployment_target = "11.0"

  spec.author             = { "山神" => "1096452045@qq.com" }

  spec.source       = { :git => "http://wjs/ClipImageBrowser.git", :tag => "#{spec.version}" }

  spec.source_files  = "ClipImageBrowser", "ClipImageBrowser/**/*.{swift}"
  spec.exclude_files = "Classes/Exclude"

   spec.resources = "ClipImageBrowser/*.bundle"
   spec.static_framework = true

end
