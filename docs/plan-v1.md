# Plan de implementación v1

## Propósito

Este documento convierte el alcance de Memo Granja en trabajo ejecutable. La
prioridad es terminar una experiencia infantil útil **sin depender de internet**;
persistencia, backup y compras se agregan después de validar el juego.

No es realista «terminar todo» sin decisiones y materiales externos: hacen falta
arte y voces con licencia, identidad del publicador, cuentas de tienda, precios y
pruebas con familias. El agente puede continuar el código sin esos elementos,
pero no debe fingir que sustitutos temporales son una versión publicable.

## Principios obligatorios

1. Juego, catálogo, audio y progreso funcionan en modo avión.
2. No hay anuncios, analítica, cuentas sociales ni backend propio.
3. Ninguna pantalla infantil contiene precio, enlace externo o restauración.
4. No se utiliza color como única señal; icono, forma o estado lo acompañan.
5. Animación y audio informan o celebran, nunca castigan ni saturan.
6. Cada fase termina en un build instalable y un criterio observable.
7. Una fase no comienza hasta cerrar el gate de salida anterior.

## Estado inicial

| Área | Estado | Próximo paso |
|---|---|---|
| Flutter/Dart | FVM fijado en 3.44.8; checks locales aprobados | Mantener `.fvmrc` y fijar CI |
| Android | Generado con `com.memogranja.memo_granja` | Validar ejecución en dispositivo |
| Dominio | Motor Dart puro, controller observable y tests de taps/dispose | Probar ciclo de vida en dispositivo |
| UI | Tokens y movimiento reducido iniciales | Completar adaptación y validación sensorial |
| Catálogo | 12 conceptos, emoji temporal | Añadir contrato de assets finales |
| Audio | Ausente | Aprobar voces y hacer spike de latencia |
| Persistencia | Ausente | Diseñar esquema/migraciones después del juego |
| Avatar | Ausente | Implementar composición animal + color + accesorio |
| Backup | No decidido | Mantener desactivado hasta decisión de privacidad |
| IAP | Ausente | No iniciar hasta aprobar entitlements y gate |

## Fase A — Toolchain reproducible

**Objetivo:** poder compilar y verificar el mismo checkout en otra máquina.

- Ejecutar `./tool/bootstrap_flutter.sh` en una máquina con Flutter oficial.
- Confirmar `fvm flutter doctor -v`, Android SDK y dispositivo físico.
- Registrar Flutter, Dart, Java, Gradle y Android compile/target SDK reales en
  `docs/toolchain.md`.
- Versionar `android/`, `.metadata` y `pubspec.lock` generados y revisados.
- Fijar Flutter en CI/FVM/mise después de que los checks pasen.
- Ejecutar `./tool/check.sh` y una partida manual.

**Gate de salida:** un checkout limpio puede producir y ejecutar un APK debug con
comandos documentados. No se acepta una versión «más reciente» sin número.

## Fase B — Núcleo jugable robusto

**Objetivo:** un memorama correcto aun con taps rápidos y cambios de ciclo de vida.

- Extraer el motor de reglas de `ChangeNotifier`; dejar un controller Flutter como
  adaptador observable.
- Modelar explícitamente `idle`, `oneRevealed`, `resolving`, `celebrating` y
  `complete`.
- Hacer determinista el mazo en tests mediante seed/orden inyectable.
- Definir salida a mitad de partida: v1 descarta tablero y vuelve a nivel.
- Bloquear navegación/taps durante la comparación sin bloquear accesibilidad.
- Añadir pruebas de doble tap, tercera carta, misma carta, dispose durante delay y
  recompensa idempotente.
- Hacer que un error de catálogo permita reintentar y no muestre detalles técnicos.

**Gate de salida:** `fvm flutter analyze` y `fvm flutter test` pasan; en dispositivo no se
puede revelar una tercera carta ni duplicar un final.

## Fase C — Sistema visual y sensorial

**Objetivo:** una UI amable, coherente y legible sin sobreestimulación.

- Centralizar colores, tipografía, espaciado, radios, sombras, movimiento y tamaños
  táctiles según `docs/design-system.md`.
- Sustituir colores literales de las pantallas por tokens semánticos.
- Mantener un solo foco primario por pantalla.
- Evitar flashes, fondos saturados, partículas continuas y audio simultáneo.
- Respetar `MediaQuery.disableAnimations`; ofrecer «movimiento reducido» en zona
  adulta cuando existan ajustes.
- Validar contraste programáticamente y también en dispositivo económico.
- Probar teléfono pequeño, tableta, landscape/portrait definidos y text scaling.

**Gate de salida:** checklist sensorial completo y ninguna acción esencial depende
solo de color, lectura o animación.

## Fase D — Audio bilingüe offline

**Objetivo:** convertir cada acierto en repetición pedagógica ES/EN.

- Aprobar 12 clips ES, 12 EN, instrucciones y SFX con licencia registrada.
- Elegir plugin tras un spike comparando latencia, precarga, mezcla, licencia,
  tamaño y soporte Fire OS.
- Implementar cola: voz 1 → pausa breve → voz 2; nunca superponer nombres.
- Hacer las dos burbujas tocables para repetir un idioma concreto.
- Añadir mute inmediato y conservarlo localmente.
- Cancelar audio al salir, cambiar perfil o iniciar otra celebración.
- Mantener fallback visual si un recurso falla.

**Gate de salida:** una partida completa funciona en modo avión, sin audio
superpuesto y con latencia aceptable en hardware objetivo.

## Fase E — Avatar global y perfiles

**Objetivo:** que cada niña o niño se reconozca sin escribir su nombre.

La identidad se compone de tres elecciones independientes:

```text
AvatarIdentity = animalId + colorId + accessoryId
```

- **Animal:** silueta principal (por ejemplo gato, perro, pez, conejo).
- **Color:** paleta limitada y validada; cambia zonas tintables, no toda la imagen.
- **Accesorio:** uno global por perfil (`none`, pin estrella, gorra, moño, lentes).

Las capas y reglas completas están en `docs/avatar-system.md`.

Implementación:

- Selector en tres pasos grandes: animal → color → accesorio → confirmar.
- Previsualización inmediata y botón de volver sin perder elecciones.
- Máximo cuatro perfiles locales, sin nombre ni teclado.
- El avatar compuesto aparece en selección, inicio, nivel, encabezado de tablero,
  celebraciones, final y zona adulta de gestión; no tapa cartas ni instrucciones.
- En celebraciones aparece una sola vez, con pose breve y no intermitente.
- Accesorios se anclan por animal mediante metadata; no usar posiciones mágicas
  dispersas por widgets.
- Guardar IDs, nunca colores ARGB o rutas crudas, para permitir migraciones.

**Gate de salida:** cuatro combinaciones se distinguen también en escala de grises
gracias a animal/accesorio, y sobreviven a un reinicio local.

## Fase F — Persistencia local versionada

**Objetivo:** conservar perfiles, preferencia de audio y progreso sin red.

- Elegir almacenamiento tras un spike; ocultarlo detrás de repositorios.
- Definir `schemaVersion` y migración desde el primer release.
- Persistir perfiles, perfil activo, estrellas, progreso, mute, orden de voz y
  preferencia de movimiento/corona.
- Escribir de forma atómica y tolerar cierre durante escritura.
- No persistir el tablero en curso en v1 salvo que pruebas infantiles lo exijan.
- Separar progreso de cache de entitlements.
- Probar datos vacíos, corruptos, migración y doble otorgamiento de estrellas.

**Gate de salida:** reiniciar conserva identidad/progreso; datos corruptos no
impiden abrir y nunca convierten un error en compras concedidas.

## Fase G — Backup: decisión antes de código

**Decisión recomendada para v1:** desactivar backup cloud y mantener la promesa
estricta de que el progreso no sale del dispositivo. Android Auto Backup puede
copiar datos de app a la cuenta Google del adulto, lo cual contradice literalmente
«nada sale del dispositivo», y no existe de la misma forma en Fire OS.

Si producto elige backup en una versión posterior:

- usar **Android Auto Backup**, no integrar Google Drive API ni login;
- documentar que es una función del sistema/cuenta adulta y revalidar la
  declaración de privacidad;
- incluir solo perfiles cosméticos, preferencias y progreso pequeño;
- excluir cache de compras, recibos/tokens, sesión de gate, logs y partida activa;
- reconstruir compras siempre desde la tienda;
- definir reglas de Android 12+ y reglas legacy para dispositivos anteriores;
- probar restore en un dispositivo nuevo y restore con versión de esquema vieja;
- mantener una ruta equivalente o una limitación explícita para Amazon.

Consulta `docs/offline-and-backup.md`. No llamar a Auto Backup «Drive gratis» en
la UI: no es almacenamiento administrado por la app ni sincronización inmediata.

**Gate de salida:** decisión escrita y manifest/reglas auditados en el APK final.

## Fase H — Gate parental y zona adulta

**Objetivo:** separar de forma inequívoca juego y acciones adultas.

- Mantener 3 segundos y luego resolver una suma simple aleatoria.
- Caducar autorización al salir de la zona o tras inactividad breve.
- Proteger idioma, backup, corona, restauración, tienda y enlaces.
- No mostrar precios antes del gate.
- Probar back, rotación, segundo plano y retorno desde hoja de pago.
- Mantener accesibilidad para el adulto sin hacer el gate resoluble por accidente.

**Gate de salida:** ningún recorrido desde zona infantil alcanza precio, enlace o
restauración sin autorización vigente.

## Fase I — Compras Google

**Objetivo:** compras no consumibles restaurables y honestas.

- Cerrar primero SKU/precios; no implementar `complete_N` hasta corregir economía.
- Modelar estados tipados: cargando, disponible, pendiente, comprado, restaurado,
  cancelado, no disponible, error y desconocido offline.
- Separar productos verificados de entitlements derivados.
- Un fallo de red conserva el último snapshot; no equivale a «no posee».
- Cachear solo derechos derivados para uso offline.
- Restaurar desde Play en reinstalación y excluir cache del backup cloud.
- Probar purchase pending, cancel, refund/revoke, sin red y borrado de datos.

**Gate de salida:** `pack_dino` de prueba se compra, se usa offline y se restaura
después de borrar datos, sin depender del orden histórico local.

## Fase J — Validación y release

- Dos rondas observacionales con consentimiento adulto y sin datos identificables.
- Auditoría de dependencias, manifest, tráfico y assets/licencias.
- Pruebas en Android económico, tableta y al menos versiones Android objetivo.
- Store listing, capturas, política de privacidad y formularios verificados contra
  políticas vigentes, no contra números copiados en este documento.
- Prueba cerrada según requisitos mostrados por la cuenta real de Play Console.
- Crash-free no se medirá con analítica infantil; usar reportes de consola y
  feedback voluntario adulto dentro del canal de pruebas.

**Gate de salida:** build firmado reproducible, checklist de publicación aprobado
y ningún placeholder en contenido mostrado por producción.

## Qué necesita el equipo propietario

| Necesidad | Cuándo bloquea | Entrega esperada |
|---|---|---|
| Nombre de empresa/dominio y application ID | Fase A/release | ID definitivo |
| Arte y licencia | Fase C/D | Archivos fuente/exportados + licencia |
| Voces y licencia | Fase D | Clips aprobados ES/EN |
| Selección de animales/accesorios | Fase E | Lista y arte por capas |
| Decisión backup sí/no | Antes de Fase G | ADR/aceptación de privacidad |
| Cuenta y productos Play | Fase I | Acceso/configuración de testing |
| Familias para sesiones | Fases C/J | Consentimiento y agenda |

Mientras eso llega, un agente puede completar A–C, diseñar contratos de D–I y
crear tests/mocks identificados; no puede aprobar arte, políticas, precios ni
observación infantil en nombre del propietario.

## Próximas cinco tareas concretas

1. Ejecutar el APK debug en un teléfono Android físico y cerrar el gate A.
2. Probar pausa/reanudación y salida a mitad de partida en dispositivo.
3. Completar la validación sensorial en teléfono pequeño, tableta y escalado.
4. Preparar el contrato de assets/audio sin sustituir los placeholders licenciados.
5. Sustituir los placeholders solo cuando exista procedencia y licencia registrada.
