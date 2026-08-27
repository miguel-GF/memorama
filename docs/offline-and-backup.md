# Offline-first, persistencia y backup

## Qué significa offline-first aquí

- Instalada la app, todo el paquete incluido se juega en modo avión.
- Perfiles, ajustes y progreso se leen/escriben localmente.
- Un error de red no bloquea inicio, nivel, tablero, audio ni celebración.
- La red solo interviene en compra/restauración de tienda, actualización del
  binario y, si se aprueba después, backup administrado por el sistema.

Offline-first no significa que todos los datos deban sincronizarse ni que un
backup sea instantáneo.

## Clases de datos

| Datos | Fuente de verdad | Backup recomendado |
|---|---|---|
| Catálogo/arte/audio | Bundle de la app | No; se reinstala/actualiza |
| Preferencias | Local | No incluido en el backup actual |
| Perfiles cosméticos | Local | Pendiente de perfiles |
| Progreso de niveles | Local | JSON manual implementado |
| Partida en curso | Memoria/local temporal | No en v1 |
| Productos comprados | Tienda | No; restaurar desde tienda |
| Cache de entitlements | Local derivado | No |
| Gate parental/sesión | Memoria | Nunca |
| Logs/debug | Local temporal | Nunca |

## Android Auto Backup

Android puede respaldar datos de la aplicación en la cuenta del sistema sin que
Memo Granja implemente la API de Google Drive. La documentación de Android permite
incluir/excluir dominios mediante reglas de backup. Es un backup oportunista del
sistema, no una base sincronizada, no una cuenta dentro de la app y no una solución
disponible de la misma forma en Fire OS.

Referencia oficial que debe revalidarse al implementar:
[Android Auto Backup](https://developer.android.com/identity/data/autobackup).

### Ventajas

- Sin servidor propio ni pantalla de login.
- Puede recuperar progreso tras reinstalación/cambio de Android compatible.
- El sistema gestiona transporte, condiciones y cifrado del backup.

### Costes y límites de producto

- Datos dejan físicamente el dispositivo, aunque el desarrollador no opere el
  servidor; obliga a matizar la promesa «nada sale del dispositivo».
- El momento de backup/restore lo decide el sistema.
- No sustituye restauración de compras.
- No ofrece paridad en Amazon Fire.
- Reglas incorrectas pueden copiar cache, tokens o datos no deseados.

## Decisión vigente

**v1: backup cloud desactivado y backup JSON manual de progreso.** Es coherente
con la promesa estricta, reduce superficie de privacidad y permite restaurar lo
que ya se guarda localmente sin crear una cuenta.

La exportación e importación viven en `LocalBackupService` y están protegidas por
la zona adulta. El JSON no cifra el contenido, no incluye entitlements ni tokens
de compra, y se valida completo antes de escribir.

**v1.x opcional:** evaluar Auto Backup solo para progreso, preferencias y avatar,
tras decisión explícita del propietario y actualización de textos de privacidad.
No integrar Google Drive API ni Google Sign-In.

## Reglas si se aprueba

1. Definir reglas modernas `data-extraction-rules` y compatibilidad legacy según
   los niveles Android soportados.
2. Excluir compras, cache de derechos, sesión de gate, logs y temporales.
3. Mantener el total pequeño; imágenes/audio nunca entran al backup.
4. Restaurar a través de repositorios y migrar antes de mostrar UI.
5. No fusionar silenciosamente perfiles si ya existen datos locales.
6. Probar sin cuenta, backup desactivado, restore viejo y corrupción.
7. Documentar claramente que Amazon no restaura este backup.
8. Auditar el manifest fusionado release, no solo el manifest fuente.

## Opciones descartadas para v1

- **Google Drive API:** requiere identidad/permisos/red y crea una experiencia
  distinta para Fire; complejidad injustificada.
- **Backend propio:** contradice la arquitectura y aumenta obligaciones sobre
  datos infantiles.
- **Backup cloud:** se mantiene desactivado; el manifest usa
  `android:allowBackup="false"`.
