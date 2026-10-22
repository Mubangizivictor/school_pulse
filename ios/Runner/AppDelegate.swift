import Flutter
import UIKit
import FirebaseAuth

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var appBadgeChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    // Explicitly initiate APNs registration.
    // Notification authorization itself is requested from Flutter.
    DispatchQueue.main.async {
      application.registerForRemoteNotifications()
    }

    return result
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if Auth.auth().canHandle(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }

  func didInitializeImplicitFlutterEngine(
    _ engineBridge: FlutterImplicitEngineBridge
  ) {
    GeneratedPluginRegistrant.register(
      with: engineBridge.pluginRegistry
    )

    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "SchoolPulseAppBadge"
    ) else { return }
    let channel = FlutterMethodChannel(
      name: "school_pulse/app_badge",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setBadgeCount" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let arguments = call.arguments as? [String: Any]
      let count = arguments?["count"] as? Int ?? call.arguments as? Int ?? 0
      UIApplication.shared.applicationIconBadgeNumber = max(0, count)
      result(nil)
    }
    appBadgeChannel = channel
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("[APNs] registration failed: \(error)")
    super.application(
      application,
      didFailToRegisterForRemoteNotificationsWithError: error
    )
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("[APNs] device token received (\(deviceToken.count) bytes)")
    super.application(
      application,
      didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
    )
  }
}
