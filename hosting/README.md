# Página de enlace para compartir eventos (WhatsApp / redes)

WhatsApp **no** convierte en azul los links `ccisps://…`. Por eso la app ahora comparte:

```text
https://ccisanpedrosula.org/app/?e=EVENT_ID&c=general
```

## Qué subir al sitio

Copia estos archivos al hosting de **ccisanpedrosula.org**:

| Archivo local | Destino en el servidor |
|---------------|------------------------|
| `hosting/app/index.html` | `https://ccisanpedrosula.org/app/index.html` |
| `hosting/.well-known/apple-app-site-association` | `https://ccisanpedrosula.org/.well-known/apple-app-site-association` |

Requisitos del archivo AASA:
- Servido por **HTTPS**
- Content-Type: `application/json` (sin `.json` en el nombre del archivo)
- Sin redirecciones HTTP→HTML intermedias

## Cómo funciona

1. La persona toca el link en WhatsApp (azul, `https://…`).
2. Se abre la página `app/index.html`.
3. Puede pulsar **Abrir en la app** → `ccisps://event/…`.
4. Si no tiene la app, usa los botones de App Store / Play Store.

## Verificar

```bash
curl -I https://ccisanpedrosula.org/app/
curl https://ccisanpedrosula.org/.well-known/apple-app-site-association
```
