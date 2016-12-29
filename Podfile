# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
workspace ‘PortfolioView’

target 'PortfolioView' do

  use_frameworks!

  # Pods for PortfolioView
 pod 'ObjectMapper', '~> 2.2'

target 'PortfolioViewShared (iOS)' do
    inherit! :search_paths
     pod 'ObjectMapper', '~> 2.2'
end

target 'PortfolioViewShared (watchOS)' do
    inherit! :search_paths
    platform :watchos, '2.0'
    pod 'ObjectMapper', '~> 2.2'
end

target 'PortfolioView WatchApp Extension' do
    inherit! :search_paths
    platform :watchos, '2.0'
    pod 'YOChartImageKit', '~> 1.1'
end

  target 'PortfolioViewTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PortfolioViewUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
