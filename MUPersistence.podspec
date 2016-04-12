Pod::Spec.new do |s|
  s.name         = "MUPersistence"
  s.version      = "0.9.1"
  s.license      = "MIT"
  s.summary      = "JSON and model transformation framework."
  s.homepage     = "https://github.com/muer2000/MUPersistence"
  s.author       = { "muer" => "muer2000@gmail.com" }
  s.platform     = :ios, "5.0"
  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/muer2000/MUPersistence.git", :tag => s.version }
  s.source_files  = "MUPersistence/**/*"
  s.requires_arc = true
end
