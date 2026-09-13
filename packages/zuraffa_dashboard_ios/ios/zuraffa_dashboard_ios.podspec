#
# zuraffa_dashboard_ios podspec — the iOS native plugin.
#
Pod::Spec.new do |s|
  s.name             = 'zuraffa_dashboard_ios'
  s.version          = '1.0.0'
  s.summary          = 'The iOS implementation of zuraffa_dashboard.'
  s.description      = 'Persists dashboard layouts to NSUserDefaults behind the zuraffa_dashboard MethodChannel protocol.'
  s.homepage         = 'https://zuraffa.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Zuraffa' => 'https://github.com/arrrrny' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.9'
end
