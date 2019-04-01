Pod::Spec.new do |s|
  s.name             = 'RxDucks'
  s.version          = '0.2.0'
  s.swift_version    = '5.0'
  s.summary          = 'RxDucks is a Redux-like framework working on RxSwift.'
  s.homepage         = 'https://github.com/cats-oss/RxDucks'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kyohei Ito' => 'ito_kyohei@cyberagent.co.jp' }
  s.source           = { :git => 'https://github.com/cats-oss/RxDucks.git', :tag => s.version.to_s }
  s.ios.deployment_target       = '8.0'
  s.tvos.deployment_target      = '9.0'
  s.osx.deployment_target       = '10.10'
  s.watchos.deployment_target   = '2.0'
  s.source_files     = 'RxDucks/**/*.{h,swift}'
  s.requires_arc     = true
  s.dependency "RxSwift", "~> 4.4"
  s.dependency "RxCocoa", "~> 4.4"
end
