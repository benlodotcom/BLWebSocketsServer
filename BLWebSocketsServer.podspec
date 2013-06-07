#
# Be sure to run `pod spec lint BLWebSocketsServer.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "BLWebSocketsServer"
  s.version      = "0.1"
  s.summary      = "BLWebSocketsServer is a lightweight websockets server for iOS built around libwebsockets. The server suports both synchronous and asynchronous messaging."
  s.homepage     = "https://github.com/benlodotcom/BLWebSocketsServer"
  s.author       = { "Benjamin Loulier" => "benlodotcom@gmail.com" }
  s.source       = { :git => "https://github.com/benlodotcom/BLWebSocketsServer.git" }
  s.platform     = :ios, '5.0'
  s.source_files = 'BLWebSocketsServer', 'BLWebSocketsServer/libwebsockets'
  s.library   = 'z'
  s.requires_arc = true
end
