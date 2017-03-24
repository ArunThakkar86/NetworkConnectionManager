

Pod::Spec.new do |s|

# 1
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.name         = "NetworkConnectionManager"
  s.summary      = "NetworkConnectionManager allows to send request and parse json response."
  s.requires_arc = true

# 2
  s.version = "0.0.1"

# 3
  s.license = { :type => "MIT", :file => "LICENSE" }

# 4
  s.author       = { "Arun Thakkar" => "thakkar.arun@zensar.in" }

# 5
  s.homepage     = "http://EXAMPLE/NetworkConnectionManager"

# 6
  s.source       = { :git => "https://github.com/ArunThakkar86/NetworkConnectionManager.git", :tag => "0.0.1" }

# 7
  s.framework  = "UIKit"

# 8
  s.source_files  = "ConnectionManager"/**/*.{h,m}"

# 9
  s.resources = "Resources/*.png"
end
