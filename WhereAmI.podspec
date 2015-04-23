Pod::Spec.new do |s|
  s.name         = "WhereAmI"
  s.version      = "1.2.1"
  s.summary      = "An easy to use Core Location library in Swift"
  s.homepage     = "https://github.com/lypiut/WhereAmI"
  s.license      = "MIT"
  s.author    = {"Romain Rivollier" => "romain.rivollier@gmail.com"}
  s.social_media_url   = "http://twitter.com/Lypiut"
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/lypiut/WhereAmI.git", :tag => s.version }
  s.source_files  = "Source/*.swift"
  s.requires_arc = true
end
