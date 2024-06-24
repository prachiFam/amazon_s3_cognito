import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
   
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  //add this to be able to run the background file uploads.
  func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void)
  {
      //  Will print the identifer you have set at the enum: .CALLBACK_KEY
      print("Identifier: " + identifier)
      //  Stores the completion handler.
      AWSS3TransferUtility.interceptApplication(application,
                                               completionHandler: completionHandler)
  }
}
