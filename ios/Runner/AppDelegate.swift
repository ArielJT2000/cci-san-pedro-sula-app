import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Registrar plugins primero (esto inicializa Firebase automáticamente)
    GeneratedPluginRegistrant.register(with: self)
    
    // Configurar notificaciones push después de registrar plugins
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      let center = UNUserNotificationCenter.current()
      center.getNotificationSettings { settings in
        if settings.authorizationStatus == .authorized
            || settings.authorizationStatus == .provisional {
          DispatchQueue.main.async {
            application.registerForRemoteNotifications()
          }
        }
      }
      center.requestAuthorization(
        options: authOptions,
        completionHandler: { granted, _ in
          if granted {
            DispatchQueue.main.async {
              application.registerForRemoteNotifications()
            }
          }
        }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
      application.registerForRemoteNotifications()
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Manejar el registro de notificaciones remotas
  override func application(_ application: UIApplication,
                           didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Configurar APNs token en Firebase
    if FirebaseApp.app() != nil {
      Messaging.messaging().apnsToken = deviceToken
    }
  }
  
  // Manejar errores al registrar notificaciones remotas
  override func application(_ application: UIApplication,
                           didFailToRegisterForRemoteNotificationsWithError error: Error) {
    // Esto es normal si APNs no está configurado en Firebase
    print("Error registrando notificaciones remotas: \(error.localizedDescription)")
  }
}
