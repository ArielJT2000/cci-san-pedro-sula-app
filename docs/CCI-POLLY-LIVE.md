# CCI-POLLY-LIVE

**Palabra clave del proyecto:** `CCI-POLLY-LIVE`

**Frase para iniciar implementación (en chat o con el equipo):**

> Implementar CCI-POLLY-LIVE

**Frase para iniciar solo periodo de prueba (sin publicar en tiendas):**

> Iniciar prueba CCI-POLLY-LIVE

---

## Objetivo

Transmisión en vivo en la pantalla **En Vivo** con selector de idioma:

| Idioma   | Video              | Audio                          |
|----------|--------------------|--------------------------------|
| Español  | YouTube (actual)   | YouTube (sin cambios)          |
| English  | YouTube (mute)     | Amazon IVS + Polly (traducción)|

Contexto: cumbre **Red CCI** — audiencia internacional. **V1 solo ES + EN.**

---

## Alcance V1

- Una sola pantalla `Transmisiones` con botón / selector **Español | English**
- Rama española: código actual intacto (`TransmisionLive` + YouTube)
- Rama inglés: RTMP templo → AWS (Transcribe → Translate → Polly) → IVS
- Lambda + DynamoDB con mapa `languages` extensible
- Prueba en **TestFlight / prueba cerrada Play** antes de versión pública

## Fuera de alcance V1

- Kirundi y otros idiomas sin validar en AWS Polly/Translate
- ElevenLabs u otros TTS
- Segunda pantalla separada en Home

---

## Señal desde el templo

```
ATEM → Restream → YouTube (ES)     → app modo Español
ATEM → RTMP → AWS (audio ES)       → pipeline Polly → IVS EN
```

---

## Fases

| Fase | Entregable |
|------|------------|
| F1 | IVS + ingest RTMP (prueba sin app) |
| F2 | Worker: Transcribe → Translate → Polly → IVS |
| F3 | Lambda/DynamoDB `languages` + API |
| F4 | App: selector idioma + reproductor IVS EN |
| F5 | Piloto cumbre (prueba interna/cerrada) |
| F6 | Publicar versión en App Store + Play |

---

## Estado

`PLANIFICADO` — no implementado. Retomar con: **Implementar CCI-POLLY-LIVE**
