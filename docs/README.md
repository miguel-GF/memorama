# Documentación

## Empieza aquí

| Documento | Propósito | Estado |
|---|---|---|
| [`../README.md`](../README.md) | Setup, comandos y estado actual | Vigente |
| [`architecture.md`](architecture.md) | Límites, dependencias y flujo técnico | Vigente |
| [`catalog.md`](catalog.md) | Contrato de `packs.json` y assets | Vigente |
| [`plan-v1.md`](plan-v1.md) | Fases, gates, bloqueos y próximas tareas | Vigente |
| [`design-system.md`](design-system.md) | Paleta y reglas sensoriales/accesibles | Vigente |
| [`avatar-system.md`](avatar-system.md) | Avatar por capas, color y accesorio | Vigente |
| [`offline-and-backup.md`](offline-and-backup.md) | Datos locales y decisión de backup | Vigente |
| [`purchases-and-backup.md`](purchases-and-backup.md) | Compra única, paquetes y respaldo local | Vigente |
| [`toolchain.md`](toolchain.md) | Versiones verificadas y cómo fijarlas | Vigente |
| [`analisis-plan-desarrollo.md`](analisis-plan-desarrollo.md) | Revisión y ruta crítica del plan | Referencia |
| [`analisis-tecnico-v0.1.md`](analisis-tecnico-v0.1.md) | Riesgos y decisiones de arquitectura/IAP | Referencia |

## Fuente de verdad

- El código y sus pruebas definen el comportamiento implementado.
- `README.md` define cómo preparar y verificar el checkout actual.
- `architecture.md` define límites técnicos vigentes.
- `plan-v1.md` define el orden de implementación y sus gates de salida.
- Los dos análisis registran propuestas y riesgos; no significan que todas las
  funciones descritas estén implementadas.
- El catálogo actual vive en `assets/data/packs.json`.

Si dos documentos se contradicen, abre una decisión explícita y actualiza ambos;
no elijas silenciosamente el texto que facilite el cambio.

## Estado por fase

| Área | Estado |
|---|---|
| Catálogo Granja | Prototipo con 12 pares y emoji |
| Núcleo de juego | Máquina pura + controller + pruebas widget; falta ciclo de vida en dispositivo |
| Animación/celebración | Prototipo visual |
| Sistema visual/sensorial | Tokens y movimiento reducido iniciales; falta validación |
| Audio | Pendiente |
| Avatar global | Especificado; implementación pendiente |
| Perfiles/progreso | Progreso de niveles local; perfiles pendientes |
| Gate parental/IAP | Gate y servicio de compra única implementados; Play pendiente |
| Backup | Exportación/restauración local de progreso; Auto Backup desactivado |
| Android generado | Generado; falta validar en un dispositivo Android |
| Amazon | Fuera del alcance actual |

## Decisiones pendientes

1. Identidad definitiva del publicador y `applicationId`.
2. Versión exacta de Flutter que se fijará en CI (ver `toolchain.md`).
3. Arte, voces, licencias y presupuesto de assets.
4. Perfil único en v1 frente a multiperfil.
5. Persistencia y estrategia de migraciones.
6. Modelo económico y semántica restaurable de entitlements.
7. Confirmar backup cloud desactivado en v1 o aceptar el cambio de privacidad.
