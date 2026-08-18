# Sistema visual y sensorial

## Objetivo

La app debe sentirse cálida y alegre sin depender de brillo extremo, parpadeo,
ruido visual o recompensa constante. No existe una paleta universal que garantice
comodidad sensorial: estos tokens son una base medible que debe validarse con
familias y personas con necesidades sensoriales diversas.

## Paleta semántica propuesta

| Token | Hex | Uso |
|---|---|---|
| `canvas` | `#FFF8E7` | Fondo cálido principal |
| `surface` | `#FFFFFF` | Tarjetas, paneles y overlays |
| `ink` | `#243127` | Texto e iconos principales |
| `inkMuted` | `#526158` | Texto secundario grande |
| `primary` | `#287A4B` | Acción principal y reverso de carta |
| `primarySoft` | `#DCEEDF` | Contenedor seleccionado |
| `secondary` | `#C56D24` | Acento cálido limitado |
| `secondarySoft` | `#F7DFC8` | Contenedor de nivel/celebración |
| `info` | `#3478B8` | Ayuda o idioma inglés |
| `focus` | `#7357A8` | Foco adulto/accesibilidad |
| `outline` | `#66756B` | Bordes y separación |
| `errorAdult` | `#A33A3A` | Errores solo en zona adulta |

`primary` con blanco supera 4.5:1; `ink` sobre `canvas` supera ampliamente ese
umbral. Los colores de avatar **no se usan automáticamente como fondo de texto**.
Contraste debe comprobarse cada vez que cambie un token.

## Colores de avatar

Paleta inicial tintable: frambuesa `#C94F78`, océano `#3478B8`, hoja `#4C8B57`,
ámbar `#C47B20`, violeta `#7357A8` y coral `#C95F4A`. La silueta conserva contorno
`ink` y detalles blancos/oscuros predefinidos. Animal + accesorio distinguen el
perfil aunque dos colores se perciban iguales.

## Reglas sensoriales

- Máximo un botón primario y un elemento animado protagonista por pantalla.
- Nada parpadea. Nunca alternar luminosidad más de tres veces por segundo.
- Celebraciones duran 1.5–2.5 s y luego se detienen por completo.
- No usar confeti infinito, vibración repetida ni zoom de toda la pantalla.
- Solo una voz o SFX informativo a la vez; la música, si se aprueba, baja durante
  voz y puede silenciarse con un toque.
- El error de pareja usa retorno neutro, sin rojo dominante, buzzer ni sacudida.
- Fondo estable y de baja complejidad durante el tablero.
- Respetar reducción de movimiento; sustituir flip/scale por cross-fade corto.
- No depender de haptics: dispositivos Fire/Android varían y pueden estar apagados.

## Tipografía y objetivos táctiles

- Fuente sans redondeada incluida/licenciada o fuente del sistema hasta aprobarla.
- Texto infantil mínimo recomendado: 20 sp; acciones principales: 24–32 sp.
- Texto adulto no menor de 16 sp salvo metadata no interactiva.
- Objetivo táctil mínimo: 56×56 dp; acción primaria: 72–88 dp de alto.
- Separación mínima entre acciones infantiles: 12 dp.
- Líneas cortas y máximo una instrucción principal por pantalla.
- Texto escala sin cortar controles; no bloquear `textScaleFactor`.

## Formas y estados

- Radio de tarjeta: 16–20 dp; panel/celebración: 24–32 dp.
- Elevación suave y consistente; no comunicar selección solo con sombra.
- Selección = contorno + escala leve o check + etiqueta semántica.
- Deshabilitado = opacidad + ausencia de acción + semántica; no solo gris.
- Pareja encontrada = visible y atenuada, no desaparece abruptamente.

## Movimiento

| Evento | Duración | Alternativa reducida |
|---|---:|---|
| Tap/press | 80–120 ms | Cambio de color |
| Flip | 280–380 ms | Cross-fade 120 ms |
| Error neutro | 500–800 ms visible | Igual sin rotación |
| Overlay de pareja | 180–260 ms entrada | Fade 100 ms |
| Celebración | 1.5–2.5 s total | Estado estático 1.2 s |

## Checklist por pantalla

- [ ] Contraste verificado para texto, iconos y foco.
- [ ] Se entiende en escala de grises.
- [ ] Se entiende sin audio.
- [ ] Se entiende sin leer texto largo.
- [ ] Soporta movimiento reducido.
- [ ] No hay más de un sonido simultáneo.
- [ ] Targets ≥56 dp y separación suficiente.
- [ ] Semantics describe acción/estado, no decoración.
- [ ] Funciona a 200 % de escala de texto en zona adulta.
- [ ] Probada en teléfono pequeño y tableta.

## Referencias para revalidar

- [WCAG: contraste mínimo](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html).
- [WCAG: pausa, detener, ocultar](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html).
- [Flutter: accesibilidad](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility).

Las referencias fijan mínimos de accesibilidad, no sustituyen pruebas con la edad
objetivo ni garantizan por sí solas una experiencia sensorial apropiada.
