# Uncomment the next line to define a global platform for your project
 platform :ios, '15.0'

target 'sekretess' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  use_modular_headers!

  # Pods for sekretess
ENV['LIBSIGNAL_FFI_PREBUILD_CHECKSUM']='fb5a199f21df1e088b99f92e5d43102cf7abecd0f95b5a64fad1a3ae300045a2'
pod 'LibSignalClient', git: 'https://github.com/signalapp/libsignal.git', tag: 'v0.83.0',testspecs: ["Tests"],

testspecs: ["Tests"] 
  target 'sekretessTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'sekretessUITests' do
    # Pods for testing
  end

end
