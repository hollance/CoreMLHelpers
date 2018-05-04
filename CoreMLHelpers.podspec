Pod::Spec.new do |s|
  s.name         = "CoreMLHelpers"
  s.version      = "0.1.0"
  s.summary      = "Types and functions that make it a little easier to work with Core ML in Swift."
  s.homepage     = "https://github.com/hollance/CoreMLHelpers"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.authors      = { "Matthijs Hollemans" => "matt@machinethink.net" }
  s.source       = { :git => "https://github.com/hollance/CoreMLHelpers.git", :branch => 'master'}
  s.source_files  = "CoreMLHelpers/**/*"
  s.platform = :ios, '11.0'
  s.swift_version = '4.0'
end
