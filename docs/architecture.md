# Arquitectura actual

## Objetivos

- Juego completo disponible sin conexión.
- Reglas fáciles de probar sin dispositivo ni plugins.
- Ninguna transmisión de datos de menores.
- UI adaptativa para teléfono/tableta y Android/Fire OS.
- Integraciones de tienda aisladas del juego cuando se implementen.

## Capas

```text
Screens / Widgets
       │
       ├── consumen controllers y coordinan navegación/animación
       ▼
Controllers (adaptadores observables de Flutter)
       │
       ▼
Models / game rules
       ▲
       │
Repositories ──> assets locales (hoy)
             └─> almacenamiento/adaptadores (futuro)
```

### `lib/app`

Compone `MaterialApp`, tema y dependencias raíz. No contiene reglas del juego.

### `lib/models`

Contiene `CardPair`, `CardPack`, `MemoryCard` y la máquina `GameState`. Define
identidades, fases e invariantes sin importar Flutter, pantallas, navegación,
audio, Hive o IAP.

### `lib/controllers`

Adapta las reglas puras a mecanismos Flutter. `GameController` expone cambios con
`ChangeNotifier`; no contiene tiempos, diálogos ni decisiones visuales.

### `lib/repositories`

Traduce fuentes externas a modelos. `PackRepository` carga el catálogo incluido
en el bundle. En el futuro habrá repositorios para progreso y entitlements; la UI
no debe conocer Hive ni SDKs de tienda.

### `lib/screens` y `lib/widgets`

Las pantallas coordinan flujos y efectos temporales. Los widgets representan
estado recibido y emiten intenciones. Deben conservar targets táctiles grandes,
contraste, semántica y ausencia de caminos accidentales hacia contenido adulto.

## Flujo de partida actual

1. `PackRepository` carga y decodifica `packs.json`.
2. La selección de nivel toma 4, 6 u 8 pares del paquete Granja.
3. `GameState` duplica y baraja cada concepto.
4. El motor avanza por `idle`, `oneRevealed`, `resolving`, `celebrating` y
   `complete`; durante las tres últimas no acepta nuevas cartas.
5. Tras la pausa visual, las cartas se marcan como pareja o vuelven a ocultarse.
6. Una coincidencia abre la celebración ES/EN y luego se confirma su final.
7. Cuando todas están emparejadas, se muestra el final y se vuelve a nivel.

## Invariantes

- Cada instancia de carta posee un `instanceId` único dentro del mazo.
- Un concepto aparece exactamente dos veces en una partida.
- Solo cartas ocultas pueden revelarse.
- Nunca hay más de dos cartas en estado `revealed`.
- Mientras se resuelve una pareja no se aceptan taps.
- Una carta `matched` no vuelve a estar oculta.
- La UI no otorga progreso todavía; al implementarlo, deberá ser idempotente.

## Errores y ciclo de vida

Actualmente, un error al cargar el catálogo presenta un mensaje genérico. Antes
de release se necesitan estados recuperables y pruebas de pausa/reanudación. Los
timers y listeners de widgets deben cancelarse al desmontar, y todo uso de
`BuildContext` tras `await` debe comprobar `mounted`.

## Evolución prevista

1. Terminar vertical slice: audio, assets finales y pruebas en dispositivo.
2. Añadir repositorio local versionado para progreso.
3. Añadir perfiles solo según el alcance aprobado.
4. Implementar gate parental.
5. Implementar `PurchaseService` por plataforma y un resolver puro de
   entitlements restaurables.

No introducir una capa antes de que su fase esté activa. La arquitectura es una
frontera para reducir acoplamiento, no una invitación a generar archivos vacíos.
