# Guía de configuración – CCI San Pedro Sula App

Cuenta principal (host): **ccisanpedrosula@gmail.com**

Esta guía detalla la identidad de la app, Firebase, firma Android y publicación en App Store y Google Play.

---

## Estado actual (actualiza esta sección cuando avances)

| Área | Estado |
|------|--------|
| **Apple** | App creada en **App Store Connect**; instalación vía **TestFlight** operativa. **Pendiente:** completar la ficha de la versión (metadatos, capturas, privacidad, etc.) y **enviar a revisión** para App Store. |
| **Google Play** | **Sin app en Play Console aún.** Objetivo: crear la aplicación, cumplir el panel de tareas y subir el primer **AAB** (hoy). |
| **Firebase** | Proyecto **cci-app-5bac1**. Revisa que la app **Android** en Firebase use el mismo **package** que `applicationId` en Android (ver nota más abajo). |

### Identificadores reales en el código

| Plataforma | Identificador | Dónde se ve |
|------------|----------------|-------------|
| **iOS** | `com.ccisps.app` | Xcode (`PRODUCT_BUNDLE_IDENTIFIER`), `GoogleService-Info.plist`, App Store Connect / App ID |
| **Android** | `org.ccisanpedrosula.app` | `android/app/build.gradle` → `applicationId` |

> **Importante (Firebase Android):** En el repo, `android/app/google-services.json` aún puede listar un `package_name` distinto (p. ej. `com.example.cci_app`). Para que FCM y Analytics funcionen bien en release, en [Firebase Console](https://console.firebase.google.com) → **Project settings** → añade o usa una app Android con package **`org.ccisanpedrosula.app`**, descarga el `google-services.json` nuevo y sustituye el archivo. Luego opcionalmente: `dart run flutterfire configure`.

---

## Cambios ya aplicados en el proyecto

- **Bundle ID (iOS):** `com.ccisps.app`.
- **Application ID (Android):** `org.ccisanpedrosula.app` (`namespace` y `applicationId` en `android/app/build.gradle`).
- **Push Notifications (iOS):** `RunnerDebug.entitlements` (development) y `RunnerRelease.entitlements` (production) con `aps-environment` para FCM/APNs.
- **Firma en Xcode:** Si `DEVELOPMENT_TEAM` está vacío en git, en cada máquina abre **Xcode → Runner → Signing & Capabilities** y elige el **Team** de la cuenta host.

---

## 1. Apple Developer (ccisanpedrosula@gmail.com)

### 1.1 Inscripción

1. Entra a [developer.apple.com](https://developer.apple.com).
2. Inicia sesión con **ccisanpedrosula@gmail.com** (o el Apple ID del host).
3. Si no estás inscrito: **Account** → **Membership** → **Join the Apple Developer Program** (cuota anual).

### 1.2 App ID

1. En [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) → **Identifiers** → **+** → **App IDs** → **App**.
2. **Bundle ID explícito:** `com.ccisps.app` (debe coincidir con Xcode y con la app en App Store Connect).
3. Capabilities: **Push Notifications** si usas FCM vía APNs.

---

## 2. Xcode: equipo y firma

```bash
open ios/Runner.xcworkspace
```

**Runner** → **Signing & Capabilities** → **Team** de la cuenta host, **Automatically manage signing**, capacidad **Push Notifications** si aplica.

---

## 3. Firebase

1. [console.firebase.google.com](https://console.firebase.google.com) — proyecto **cci-app-5bac1** (o el que uses).
2. **iOS:** app con Bundle ID **`com.ccisps.app`** → `ios/Runner/GoogleService-Info.plist`.
3. **Android:** app con package **`org.ccisanpedrosula.app`** → `android/app/google-services.json`.
4. **Cloud Messaging:** clave APNs (.p8) en **Apple app configuration** para iOS. Detalle: **[docs/FIREBASE_PUSH_SETUP.md](docs/FIREBASE_PUSH_SETUP.md)**.

---

## 4. Android: firma de release (antes del primer AAB en Play)

### 4.1 Keystore (solo una vez)

```bash
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cci-app
```

Guarda `key.jks` en lugar seguro, p. ej. `android/key.jks` (y añádelo a `.gitignore` si no está).

### 4.2 `android/app/build.gradle`

Descomenta `signingConfigs` y en `buildTypes.release` usa `signingConfig signingConfigs.release`. Contraseñas vía variables de entorno:

```bash
export KEYSTORE_PASSWORD="…"
export KEY_ALIAS="cci-app"
export KEY_PASSWORD="…"
flutter build appbundle
```

El bundle queda en:

`build/app/outputs/bundle/release/app-release.aab`

---

## 5. Google Play Console — plan para “hoy”

Usa [Google Play Console](https://play.google.com/console) con **ccisanpedrosula@gmail.com** (o la cuenta de desarrollador que tenga la cuota de 25 USD pagada).

### 5.1 Crear la aplicación

1. **Crear app** → nombre público (p. ej. “CCI SPS” o el que uses en tienda).
2. **Idioma predeterminado**, **tipo** (app / juego), **gratis o de pago**.
3. Declaraciones iniciales (políticas de Play): léelas y acéptalas.

### 5.2 Panel principal (tareas obligatorias)

Play bloquea producción hasta completar, como mínimo:

1. **Ficha de Play Store**  
   - Descripción breve y completa.  
   - **Icono** 512×512, **capturas** de teléfono (obligatorio; hay mínimos de cantidad según el formulario).  
   - Opcional: tablet, TV, etc., según publiques en esos formatos.

2. **Clasificación de contenido**  
   Cuestionario (religión / comunidad suele encajar en categorías generales; responde con honestidad).

3. **Público objetivo y contenido familiar**  
   Edades y si la app está dirigida a niños.

4. **Seguridad de los datos** (Data safety)  
   Qué datos recopilas, si se comparten, cifrado, etc. Alinea esto con tu política de privacidad.

5. **Política de privacidad**  
   URL pública obligatoria si la app recopila datos personales o usa permisos sensibles.

6. **Acceso a la app**  
   Si hay login, indica cómo revisar la app (usuario de prueba, instrucciones).

7. **Anuncios**  
   Si la app muestra anuncios o no.

Completa todo lo que el panel marque en rojo o como obligatorio para **producción** o **prueba interna**.

### 5.3 Primera subida de build (recomendado: prueba interna)

1. **Testing** → **Internal testing** → crea una lista de testers (emails de Google).
2. **Crear nueva versión** → sube el **`.aab`** firmado (`flutter build appbundle`).
3. Espera el procesamiento; luego los testers pueden instalar desde el enlace de Play.

Cuando la ficha y las políticas estén listas, repite el flujo en **Producción** (o **Prueba cerrada** primero, si prefieres).

### 5.4 Package name en Play

Al crear la app, el **applicationId** del primer upload fija el paquete: debe ser **`org.ccisanpedrosula.app`** (igual que en `build.gradle`). No se puede cambiar después sin crear otra app.

---

## 6. App Store (iOS) — enviar a revisión

1. [App Store Connect](https://appstoreconnect.apple.com) → tu app (Bundle ID `com.ccisps.app`).
2. **App Store** → nueva versión o la versión en borrador.
3. Rellena: **capturas**, **descripción**, **palabras clave**, **URL de soporte / privacidad**, **categoría**, revisión de **privacidad** (nutrición de la app), **información de contacto** para revisión.
4. En **Xcode**: **Product → Archive** → **Distribute App** → **App Store Connect** y sube el build si aún no está enlazado.
5. Selecciona el build en la versión y **Enviar a revisión**.

---

## 7. Entitlements y push en release (iOS)

- **Debug** → `RunnerDebug.entitlements` → `aps-environment`: **development**.
- **Release / Profile / TestFlight / App Store** → `RunnerRelease.entitlements` → **production**.

Si fallan las push en producción: **Signing & Capabilities**, App ID con Push, y APNs en Firebase. Ver **[docs/FIREBASE_PUSH_SETUP.md](docs/FIREBASE_PUSH_SETUP.md)**.

---

## 8. Checklist

### Apple (mayoría hecha)

- [x] Apple Developer activo; app en **App Store Connect**.
- [x] **TestFlight** con builds instalables.
- [ ] Ficha de versión completa para **App Store** (textos, capturas, privacidad, etc.).
- [ ] **Enviar a revisión** desde App Store Connect.

### Google Play (pendiente)

- [ ] Cuenta de desarrollador Play activa.
- [ ] App creada con package **`org.ccisanpedrosula.app`**.
- [ ] Keystore + `signingConfigs.release` en `build.gradle`.
- [ ] `flutter build appbundle` y primer upload (interno o producción).
- [ ] Ficha de tienda, clasificación de contenido, público objetivo, seguridad de datos, política de privacidad (URL), demás ítems obligatorios del panel.

### Firebase / archivos

- [ ] `GoogleService-Info.plist` acorde a **`com.ccisps.app`**.
- [ ] `google-services.json` acorde a **`org.ccisanpedrosula.app`** (mismo proyecto Firebase).
- [ ] APNs (.p8) configurado en Firebase para iOS.

Cuando Play y la revisión de iOS estén completas, la app quedará alineada con **ccisanpedrosula@gmail.com** como host en Apple, Firebase y Google Play.
