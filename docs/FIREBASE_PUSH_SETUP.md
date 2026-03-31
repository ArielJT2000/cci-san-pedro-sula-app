# Notificaciones push (Firebase Cloud Messaging)

La app ya incluye **Firebase Messaging** en Dart (`lib/utils/fcm_service.dart`), registro de APNs en `AppDelegate.swift` y temas `cci_live_streams` y `cci_events`.

## iOS

1. **Apple Developer**  
   El App ID debe tener la capacidad **Push Notifications** y coincidir con el Bundle ID del proyecto (`com.ccisps.app`).

2. **Entitlements** (ya en el repo)  
   - Debug → `RunnerDebug.entitlements` → `aps-environment`: **development**  
   - Release / Profile / TestFlight → `RunnerRelease.entitlements` → **production**

3. **Firebase Console**  
   - Proyecto → ⚙️ **Project settings** → pestaña **Cloud Messaging**.  
   - En **Apple app configuration**, sube la **clave APNs** (.p8) o el certificado, según la [documentación de Firebase](https://firebase.google.com/docs/cloud-messaging/ios/client).

4. **App iOS en Firebase**  
   El Bundle ID de la app iOS en Firebase debe ser **`com.ccisps.app`**. Si en la consola solo existe otra app (por ejemplo `com.example.cciApp`), añade una app iOS nueva con el ID correcto y vuelve a descargar `GoogleService-Info.plist` (o ejecuta `flutterfire configure`).

5. **Xcode**  
   Abre `ios/Runner.xcworkspace`, target **Runner** → **Signing & Capabilities**. Con firma automática y un equipo de pago, Xcode puede añadir de nuevo la fila **Push Notifications**; si ya compila y el perfil incluye push, los `.entitlements` del repo bastan.

## Android

- `google-services.json` debe corresponder al mismo proyecto Firebase.  
- El canal por defecto FCM está en `AndroidManifest.xml` como `cci_notifications` (mismo id que `AppConfig`).

## Probar

1. Instala la app en un dispositivo físico (las push no suelen funcionar en simulador iOS antiguo; en Android sí en emulador con Google Play).  
2. En Firebase → **Messaging**, envía una notificación de prueba al **token FCM** que imprime la consola al iniciar, o a un **tema** (`cci_live_streams` / `cci_events`).
