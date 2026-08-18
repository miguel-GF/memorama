# Sistema de avatar global

## Meta

Crear identidad reconocible sin nombres ni teclado. El avatar debe acompañar al
perfil en los momentos emocionales, especialmente celebraciones, sin competir con
las cartas ni convertirse en una recompensa de pago necesaria.

## Modelo

```dart
AvatarIdentity {
  String animalId;
  String colorId;
  String accessoryId; // "none" siempre disponible
}
```

Los IDs son estables. La UI resuelve esos IDs mediante un catálogo versionado; no
se guardan rutas, offsets ni valores de color dentro del perfil.

## Capas de render

```text
shadow (opcional)
bodyBase
bodyTintMask × color
face/details
accessory (anclado al animal)
celebrationPose (opcional, misma identidad)
```

El arte final puede ser SVG solo si la licencia y el renderer seleccionado son
aptos y se prueba rendimiento; PNG/WebP por capas evita añadir un plugin. No se
elige formato definitivo hasta recibir arte real.

## Catálogos

```text
AnimalDefinition
  id, baseAsset, tintMaskAsset, previewAsset
  accessoryAnchors: map<anchorId, normalizedPoint>

AvatarColor
  id, colorToken, localizedLabel

AccessoryDefinition
  id, asset, anchorId, scale, semanticLabel
```

Los puntos se expresan normalizados (0–1) respecto al canvas del animal. Así el
pin, gorra o moño se coloca desde metadata común y no desde `if (cat)` en widgets.

## Set inicial recomendado

- Animales: gato, perro, pez y conejo.
- Colores: seis tokens de `docs/design-system.md`.
- Accesorios: ninguno, pin estrella, gorra, moño y lentes redondos.

Todos los accesorios iniciales son cosméticos y gratuitos. Si en el futuro un
paquete incluye accesorios, siempre debe quedar suficiente diferenciación gratis.

## Aparición global

| Pantalla | Uso | Tamaño relativo |
|---|---|---:|
| Selección de perfil | Identificador principal | Grande |
| Inicio | Saludo junto al CTA | Mediano |
| Nivel | Acompaña instrucción | Pequeño/mediano |
| Tablero | Badge en encabezado | Pequeño |
| Pareja | Celebra al lado del concepto | Mediano |
| Fin | Protagonista con estrellas | Grande |
| Zona adulta | Edición/preview | Mediano |

En el tablero nunca invade la cuadrícula. En cada celebración aparece una vez y
su pose termina; no rebota permanentemente.

## Accesibilidad y sensibilidad

- Perfil no se diferencia solo por color: animal y accesorio aportan forma.
- `Semantics`: «Gato violeta con gorra», con nombres localizados.
- No asignar significado de género a color o accesorio.
- No bloquear accesorios tras rachas, tiempos o competencia.
- Si el niño no elige accesorio, `none` es una opción visible y válida.
- Animaciones respetan movimiento reducido.

## Persistencia y migración

- Guardar solo los tres IDs.
- Si falta un ID tras actualización: fallback determinista (`cat`, `leaf`, `none`)
  sin borrar el perfil.
- Validar unicidad y que cada accesorio tenga ancla compatible.
- Una compra puede conceder disponibilidad, pero la identidad guardada no es un
  recibo ni una fuente de derechos.

## Pruebas

- Composición de cada animal con cada accesorio permitido.
- Fallback para animal/color/accesorio desconocido.
- Semantics localizado.
- Distinción en escala de grises.
- Layout a tamaños pequeño, mediano y grande.
- Persistencia/reapertura y migración de catálogo.
