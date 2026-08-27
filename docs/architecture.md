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
en el bundle y `ProgressRepository` guarda el progreso local. La UI no debe
conocer SharedPreferences ni SDKs de tienda.

`ProgressRepository` guarda el progreso local mediante una interfaz pequeña. El
servicio de compras y el backup usan gateways/cache inyectables para mantener el
plugin y el selector de archivos fuera de las reglas del dominio.

### `lib/services`

`PurchaseService` adapta `in_app_purchase` a estados tipados y entitlements por
ID. `full_access_lifetime` concede todos los paquetes; un producto
`pack_<packId>` concede únicamente su paquete. `LocalBackupService` serializa
progreso y nunca serializa derechos de compra.

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
- Completar un nivel registra el progreso como una operación idempotente.

## Errores y ciclo de vida

Un error al cargar o validar el catálogo presenta un mensaje genérico con acción
de reintento; los detalles técnicos no llegan a la UI infantil. Ya existe una
prueba de dispose durante la comparación, pero antes de release se necesitan
pruebas de pausa/reanudación en dispositivo. Los timers y listeners de widgets
deben cancelarse al desmontar, y todo uso de `BuildContext` tras `await` debe
comprobar `mounted`.

## Evolución prevista

1. Terminar vertical slice: audio, assets finales y pruebas en dispositivo.
2. Añadir repositorio local versionado para progreso.
3. Añadir perfiles solo según el alcance aprobado.
4. Implementar gate parental.
5. Implementar `PurchaseService` por plataforma y un resolver puro de
   entitlements restaurables.

No introducir una capa antes de que su fase esté activa. La arquitectura es una
frontera para reducir acoplamiento, no una invitación a generar archivos vacíos.
