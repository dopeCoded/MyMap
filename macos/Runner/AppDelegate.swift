import Cocoa
import FlutterMacOS
import MapKit

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    let searchChannel = FlutterMethodChannel(name: "com.example.map/search",
                                              binaryMessenger: controller.engine.binaryMessenger)
    
    searchChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "searchLocation" {
        guard let args = call.arguments as? [String: Any],
              let address = args["address"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Address is missing", details: nil))
          return
        }
        self.searchLocation(address: address, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    super.applicationDidFinishLaunching(notification)
  }

  private func searchLocation(address: String, result: @escaping FlutterResult) {
    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = address
    
    let search = MKLocalSearch(request: searchRequest)
    search.start { (response, error) in
      guard let response = response, let item = response.mapItems.first else {
        result(nil)
        return
      }
      
      let location = item.placemark.coordinate
      let dict: [String: Any] = [
        "lat": location.latitude,
        "lng": location.longitude,
        "name": item.name ?? address
      ]
      result(dict)
    }
  }
}
