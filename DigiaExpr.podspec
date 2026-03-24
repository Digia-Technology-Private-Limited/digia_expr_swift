Pod::Spec.new do |s|
  s.name             = 'DigiaExpr'
  s.version          = '0.1.0'
  s.summary          = 'Expression evaluation engine used by Digia Swift SDKs.'
  s.description      = <<-DESC
DigiaExpr is a Swift expression evaluation library with support for variables,
custom functions, interpolation, JSON access, and a standard library of utility operations.
  DESC
  s.homepage         = 'https://github.com/Digia-Technology-Private-Limited/digia_expr_swift'
  s.license          = { :type => 'Business Source License 1.1', :file => 'LICENSE' }
  s.author           = { 'Digia Engineering' => 'engg@digia.tech' }
  s.source           = { :git => 'https://github.com/Digia-Technology-Private-Limited/digia_expr_swift.git', :tag => s.version.to_s }

  s.swift_versions   = ['6.0']
  s.ios.deployment_target = '16.0'

  s.source_files     = 'Sources/DigiaExpr/**/*.swift'
end
