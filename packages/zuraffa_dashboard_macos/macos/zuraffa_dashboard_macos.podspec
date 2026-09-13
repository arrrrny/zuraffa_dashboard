#
# zuraffa_dashboard_macos podspec — the macOS native plugin.
#
Pod::Spec.new do |s|
  s.name             = 'zuraffa_dashboard_macos'
  s.version          = '1.0.0'
  s.summary          = 'The macOS implementation of zuraffa_dashboard.'
  s.description      = 'Persists dashboard layouts to NSUserDefaults behind the zuraffa_dashboard MethodChannel protocol.'
  s.homepage         = 'https://zuraffa.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Zuraffa' => 'https://github.com/arrrrny' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform         = :osx, '10.15'
  s.swift_version    = '5.9'
end
