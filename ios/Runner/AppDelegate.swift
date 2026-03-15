import UIKit
import Flutter
import MapKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let registrar = self.registrar(forPlugin: "MapSearchPlugin")
    let searchChannel = FlutterMethodChannel(name: "com.example.map/search",
                                              binaryMessenger: registrar!.messenger())
    
    searchChannel.setMethodCallHandler({ [weak self] (call, result) in
      if call.method == "searchLocation" {
        guard let args = call.arguments as? [String: Any],
              let address = args["address"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Address is missing", details: nil))
          return
        }
        self?.searchLocation(address: address, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
      // 住所や電話番号などの詳細情報を取得
      let dict: [String: Any] = [
        "lat": location.latitude,
        "lng": location.longitude,
        "name": item.name ?? address,
        "address": item.placemark.title ?? "",
        "phone": item.phoneNumber ?? "情報なし"
      ]
      result(dict)
    }
  }
}
