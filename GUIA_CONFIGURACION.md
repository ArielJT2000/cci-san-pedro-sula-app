# Guía de configuración – CCI San Pedro Sula App

Cuenta principal (host): **ccisanpedrosula@gmail.com**

Esta guía detalla los pasos para dejar la app lista para publicación en App Store y Google Play usando esa cuenta como titular.

---

## Cambios ya aplicados en el proyecto

- **Bundle ID (iOS):** `org.ccisanpedrosula.app` (antes `com.Arielito.cciApp`).
- **Application ID (Android):** `org.ccisanpedrosula.app` (antes `com.example.cci_app`).
- **Push Notifications (iOS):** `RunnerDebug.entitlements` (development) y `RunnerRelease.entitlements` (production) con `aps-environment` para FCM/APNs.
- **Firma en Xcode:** `DEVELOPMENT_TEAM` está vacío; **debes abrir Xcode, elegir el target Runner → Signing & Capabilities y seleccionar el Team** de la cuenta ccisanpedrosula@gmail.com (o la que uses como host).

Después de elegir el Team en Xcode, el proyecto compilará y firmará correctamente.

---

## 1. Apple Developer (ccisanpedrosula@gmail.com)

### 1.1 Inscripción

1. Entra a [developer.apple.com](https://developer.apple.com).
2. Inicia sesión con **ccisanpedrosula@gmail.com** (o el Apple ID que uses como iCloud de la iglesia).
3. Si no estás inscrito:
   - **Account** → **Membership** → **Join the Apple Developer Program**.
   - Cuota anual: 99 USD (tarjeta o método de pago de la organización).
4. Completa datos legales (persona o organización). Para “CCI San Pedro Sula” suele usarse una **entidad legal** (asociación, iglesia, empresa).

### 1.2 Crear el App ID

1. En [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list):
   - **Identifiers** → **+**.
   - Elige **App IDs** → **App**.
2. Configura:
   - **Description:** CCI San Pedro Sula.
   - **Bundle ID:** **Explicit** → `org.ccisanpedrosula.app` (ya está en el proyecto).
3. En **Capabilities** marca:
   - **Push Notifications**.
4. **Register**.

---

## 2. Xcode: equipo y firma

1. Abre el proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. En el navegador izquierdo selecciona el proyecto **Runner** (icono azul).
3. Selecciona el target **Runner**.
4. Pestaña **Signing & Capabilities**:
   - **Team:** elige el equipo asociado a **ccisanpedrosula@gmail.com** (si no aparece, añade la cuenta en **Xcode → Settings → Accounts**).
   - Deja **Automatically manage signing** activado.
   - Si Xcode muestra “No team”, haz clic y selecciona tu equipo para que genere perfiles y certificados.
5. Comprueba que en **Capabilities** aparezca **Push Notifications** (el proyecto usa `RunnerDebug.entitlements` / `RunnerRelease.entitlements` con `aps-environment`).

Con esto, el **host** de la app en Apple es la cuenta con la que elegiste el Team.

---

## 3. Firebase (misma cuenta recomendada)

### 3.1 Proyecto Firebase

1. Entra a [console.firebase.google.com](https://console.firebase.google.com).
2. Inicia sesión con **ccisanpedrosula@gmail.com** (o la cuenta que quieras como “dueña” del proyecto).
3. Si ya existe un proyecto para CCI, úsalo. Si no:
   - **Add project** → nombre ej. “CCI San Pedro Sula”.
   - Sigue los pasos (Analytics opcional).

### 3.2 Añadir la app iOS

1. En el proyecto Firebase → **Project overview** (engranaje) → **Project settings**.
2. En **Your apps**:
   - Si ya hay una app iOS con bundle ID `org.ccisanpedrosula.app`, úsala.
   - Si no: **Add app** → **iOS**.
3. **Bundle ID:** `org.ccisanpedrosula.app` (igual que en Xcode).
4. Descarga **GoogleService-Info.plist** y **sustituye** el que está en:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
5. Regenera opciones de FlutterFire (en la raíz del proyecto):
   ```bash
   dart run flutterfire configure
   ```
   Elige el mismo proyecto Firebase y la app iOS. Esto actualiza `lib/firebase_options.dart` si hace falta.

### 3.3 Notificaciones push (APNs) en iOS

Para que Firebase pueda enviar notificaciones a dispositivos iOS:

1. En **Apple Developer** → [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/authkeys/list) → **Keys**.
2. **+** para crear una nueva clave:
   - **Key Name:** ej. “Firebase CCI APNs”.
   - Activa **Apple Push Notifications service (APNs)**.
   - **Continue** → **Register**.
3. Descarga el archivo **.p8** (solo una vez; guárdalo en lugar seguro).
4. Anota:
   - **Key ID**
   - **Team ID** (en Membership)
   - **Bundle ID:** `org.ccisanpedrosula.app`
5. En **Firebase Console** → **Project settings** → pestaña **Cloud Messaging**.
6. En **Apple app configuration**:
   - Sube el archivo **.p8**.
   - Indica **Key ID**, **Team ID** y **Bundle ID**.
   - Guarda.

Desde ese momento, Firebase usa esa cuenta (y tu App ID) como “host” de la configuración de push en iOS.

---

## 4. Android (Google Play y firma)

### 4.1 Firma de release (keystore)

1. En la raíz del proyecto (o en `android`), genera un keystore **solo una vez** (guarda contraseñas y alias en lugar seguro):
   ```bash
   keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cci-app
   ```
   - Te pedirá contraseña del keystore y del alias (pueden ser la misma).
   - Datos que pidas (nombre, organización, etc.) pueden ser “CCI San Pedro Sula”.
2. Mueve `key.jks` a una ruta segura, por ejemplo:
   ```
   android/key.jks
   ```
   (O fuera del repo y ajusta la ruta en `build.gradle`.)

### 4.2 Configurar firma en el proyecto

1. Abre `android/app/build.gradle`.
2. Descomenta y ajusta `signingConfigs` en `android/app/build.gradle`. Si guardaste `key.jks` en la carpeta `android/` (al lado de `app/`), usa:
   ```gradle
   signingConfigs {
       release {
           storeFile file("../key.jks")
           storePassword System.getenv("KEYSTORE_PASSWORD")
           keyAlias "cci-app"
           keyPassword System.getenv("KEY_PASSWORD")
       }
   }
   buildTypes {
       release {
           signingConfig signingConfigs.release
           minifyEnabled false
           shrinkResources false
           proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
       }
   }
   ```
   (Si `key.jks` está en otra ruta, ajusta `storeFile` según corresponda.)
3. Para compilar release sin poner contraseñas en el código, usa variables de entorno:
   ```bash
   export KEYSTORE_PASSWORD="tu_contraseña_keystore"
   export KEY_ALIAS="cci-app"
   export KEY_PASSWORD="tu_contraseña_alias"
   flutter build appbundle
   ```

### 4.4 Firebase en Android

1. En Firebase Console → **Project settings** → **Your apps**.
2. Añade una app **Android** (si no está):
   - **Package name:** `org.ccisanpedrosula.app`
3. Descarga **google-services.json** y reemplaza el de:
   ```
   android/app/google-services.json
   ```
4. Si cambiaste de proyecto/paquete, vuelve a ejecutar:
   ```bash
   dart run flutterfire configure
   ```

---

## 5. Resumen de identidad de la app

| Plataforma | Identificador        | Uso |
|-----------|----------------------|-----|
| iOS       | `org.ccisanpedrosula.app` | Bundle ID en Xcode, App ID en Apple, Firebase iOS app |
| Android   | `org.ccisanpedrosula.app` | applicationId en `build.gradle`, Firebase Android app, Google Play |

Todo queda ligado a:
- **Apple:** cuenta con la que elegiste el Team en Xcode (recomendado: **ccisanpedrosula@gmail.com**).
- **Firebase / Google Play:** misma cuenta **ccisanpedrosula@gmail.com** como “host” del proyecto y publicador.

---

## 6. Publicación

### App Store (iOS)

1. En [App Store Connect](https://appstoreconnect.apple.com) (misma Apple ID):
   - **My Apps** → **+** → **New App**.
   - Bundle ID: `org.ccisanpedrosula.app`.
2. Completa ficha (nombre, descripción, capturas, privacidad, etc.).
3. En Xcode: **Product → Archive** → **Distribute App** → **App Store Connect**.
4. Sube el build y en App Store Connect enlaza el build a la versión y envía a revisión.

### Google Play (Android)

1. En [Google Play Console](https://play.google.com/console) (con **ccisanpedrosula@gmail.com**):
   - Crea la aplicación y asocia el paquete `org.ccisanpedrosula.app`.
2. Rellena ficha de la app, política de privacidad, contenido, etc.
3. Genera el AAB:
   ```bash
   flutter build appbundle
   ```
4. En Play Console → **Release** → **Production** (o testing) → sube el `.aab` que está en `build/app/outputs/bundle/release/`.

---

## 7. Entitlements y push en release (iOS)

- **Debug** usa `RunnerDebug.entitlements` → `aps-environment`: **development** (pruebas desde Xcode a dispositivo).
- **Release** y **Profile** usan `RunnerRelease.entitlements` → **production** (TestFlight / App Store).

Si las notificaciones en producción fallan, revisa **Signing & Capabilities**, el App ID con Push activado y la clave APNs en Firebase. Detalle: **[docs/FIREBASE_PUSH_SETUP.md](docs/FIREBASE_PUSH_SETUP.md)**.

---

## 8. Checklist final

- [ ] Apple Developer inscrito con la cuenta host (ccisanpedrosula@gmail.com).
- [ ] App ID creado: `org.ccisanpedrosula.app` con Push Notifications.
- [ ] Xcode: Team seleccionado (cuenta host), firma automática, capacidad Push.
- [ ] Firebase: proyecto con la misma cuenta; apps iOS y Android con `org.ccisanpedrosula.app`.
- [ ] APNs: clave .p8 subida en Firebase Cloud Messaging.
- [ ] Android: keystore creado, `signingConfigs.release` configurado en `build.gradle`.
- [ ] `GoogleService-Info.plist` y `google-services.json` actualizados según el proyecto Firebase.
- [ ] App Store Connect y Google Play Console creados y listos para subir el primer build.

Cuando todo esto esté hecho, la app quedará configurada con **ccisanpedrosula@gmail.com** como cuenta principal (host) en Apple, Firebase y Google Play.
