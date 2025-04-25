import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)

    // Call the setup for screen security when the app launches
    setupScreenSecurityMethodChannel(controller: window?.rootViewController as! FlutterViewController)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
 

  // MARK: - Screen Security Methods
  func setupScreenSecurityMethodChannel(controller: FlutterViewController) {
    let screenSecurityChannel = FlutterMethodChannel(
        name: "com.yourdomain.app/screen_security", 
        binaryMessenger: controller.binaryMessenger)
    
    screenSecurityChannel.setMethodCallHandler { [weak self] (call, result) in
        guard let self = self else { return }
        
        switch call.method {
        case "startScreenRecordingDetection":
            self.setupScreenRecordingNotifications(channel: screenSecurityChannel)
            result(nil)
        case "isScreenBeingRecorded":
            let isRecording = UIScreen.main.isCaptured
            result(isRecording)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
  }

  func setupScreenRecordingNotifications(channel: FlutterMethodChannel) {
    // Screenshot detection
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleScreenshotTaken),
        name: UIApplication.userDidTakeScreenshotNotification,
        object: nil
    )
    
    // Screen recording detection
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleScreenCaptureChanged),
        name: UIScreen.capturedDidChangeNotification,
        object: nil
    )
  }

  @objc func handleScreenshotTaken() {
    let screenSecurityChannel = FlutterMethodChannel(
        name: "com.yourdomain.app/screen_security", 
        binaryMessenger: (window.rootViewController as! FlutterViewController).binaryMessenger)
    screenSecurityChannel.invokeMethod("onScreenshotTaken", arguments: nil)
  }

  @objc func handleScreenCaptureChanged() {
    if UIScreen.main.isCaptured {
        let screenSecurityChannel = FlutterMethodChannel(
            name: "com.yourdomain.app/screen_security", 
            binaryMessenger: (window.rootViewController as! FlutterViewController).binaryMessenger)
        screenSecurityChannel.invokeMethod("onScreenRecording", arguments: nil)
    }
  }
}

