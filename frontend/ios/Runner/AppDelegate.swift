import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //GeneratedPluginRegistrant.register(with: self)

    // Ignore SSL verification errors for local development
    if let apiURL = URL(string: "https://localhost:5259") {
      let config = URLSessionConfiguration.default
      config.timeoutIntervalForRequest = 10
      config.timeoutIntervalForResource = 10

      let session = URLSession(configuration: config)
      session.configuration.httpAdditionalHeaders = [
        "Content-Type": "application/json"
      ]
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
