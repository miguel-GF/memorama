# Memo Granja: análisis técnico de la propuesta v0.1

## Resumen ejecutivo

La propuesta tiene una dirección de producto coherente: un memorama infantil,
offline-first, sin publicidad, cuentas ni telemetría. Flutter es una elección
razonable y no hace falta un motor de juegos para el alcance descrito. La
separación prevista entre juego, persistencia, audio y compras también es una
buena base.

Sin embargo, el documento todavía no es una especificación lista para
implementación. Hay decisiones abiertas presentadas como alternativas, el
modelo de compras contiene supuestos peligrosos y el alcance del MVP no coincide
con varias pantallas y estructuras descritas. La recomendación es hacer una
iteración v0.2 antes de desarrollar la tienda o la persistencia definitiva.

**Dictamen:** viable con ajustes. Se puede iniciar un prototipo jugable sin
compras, pero no conviene publicar ni cerrar la arquitectura de IAP hasta
resolver los puntos críticos de este análisis.

## Lo que está bien resuelto

### Producto y experiencia infantil

- La ausencia de cronómetros, vidas y castigos es consistente con la audiencia.
- La dificultad expresada mediante cantidad de cartas evita depender de lectura.
- La celebración bilingüe transforma el emparejamiento en un momento de
  aprendizaje y permite repetición deliberada.
- Evitar teclado, cuentas, nombres y permisos sensibles reduce fricción y
  exposición de datos.
- El criterio de lanzamiento basado en observación de niños reales es más útil
  que medir únicamente finalización técnica.

### Arquitectura

- El juego sí puede ser completamente local: catálogo, imágenes, audio,
  barajado y progreso no necesitan un servidor propio.
- Flutter puro es suficiente para una cuadrícula con gestos y animaciones de
  volteo. Flame no aportaría valor al MVP.
- Encapsular Google Play y Amazon detrás de una interfaz evita contaminar la UI
  con detalles de cada distribuidor.
- Tratar la tienda como fuente de verdad y conservar una vista local para jugar
  sin conexión es el enfoque conceptual correcto.

### Privacidad

- Minimizar datos por diseño es preferible a recopilar datos y luego intentar
  anonimizar los de menores.
- La prohibición explícita de analítica, anuncios, login social y servicios de
  juego limita tanto el riesgo regulatorio como la superficie de fallos.

## Hallazgos críticos

### 1. «Sin backend» no equivale automáticamente a compras robustas

La tienda puede procesar pagos y restauraciones, pero la aplicación todavía
debe modelar estados transitorios y validar lo que devuelve cada plataforma.
Una firma tan simple como `Future<bool> buy(String sku)` pierde información
esencial: compra pendiente, cancelada, ya poseída, error de red, artículo no
disponible, restauración y confirmación/consumo requerido por la plataforma.

Además, la disponibilidad offline crea una decisión de seguridad/producto:

- si el dispositivo conserva el caché, el contenido seguirá abierto aunque una
  compra se revoque o reembolse mientras no haya conexión;
- si se exige revalidación periódica, deja de ser estrictamente offline-first;
- si se borra la app o sus datos, el caché desaparece y la restauración requiere
  red y la cuenta de tienda correcta.

Esto no invalida la decisión sin servidor, pero debe quedar como un riesgo
aceptado y probado. La interfaz debería exponer un flujo de eventos y resultados
tipados, no un booleano.

### 2. Los SKU `complete_1` y `complete_2` no expresan qué contenido se compró

Una compra de `complete_1` solo dice que se adquirió ese producto; no registra
de manera portable qué paquete poseía el usuario en ese momento. Después de una
reinstalación en otro dispositivo, la app puede ver `complete_1`, pero no debe
depender de una bandera local perdida para interpretar el derecho adquirido.

La semántica propuesta —«marca `allUnlocked = true`»— puede funcionar si se
define formalmente que **cualquier recibo válido** de `complete_1`, `complete_2`
o `unlock_all` otorga todos los paquetes presentes y futuros. Esa regla debe
aplicarse al reconstruir derechos exclusivamente desde recibos, sin depender
del orden histórico ni del caché. También requiere confirmar que la descripción
visible y las condiciones de cada tienda comunican con precisión ese derecho.

Hay otro problema comercial: con tres paquetes de USD 1.99, comprar uno y luego
`complete_1` cuesta USD 5.48, más que `unlock_all` (USD 4.99). La oferta llamada
«Solo para ti» resulta peor para quien ya pagó. Los precios y el número total de
paquetes deben revisarse antes de crear productos en las consolas.

### 3. El catálogo futuro no puede ser completamente dinámico sin actualización

`unlock_all` puede conceder derecho a contenido futuro, pero imágenes, audio y
metadatos están empaquetados en la aplicación. El usuario necesitará actualizar
la app para recibirlos. La documentación debe distinguir claramente:

- **derecho futuro:** no vuelve a pagar;
- **entrega futura:** llega mediante una nueva versión de la app.

Sin backend o descarga de recursos, no es posible publicar paquetes nuevos sin
actualizar el binario.

### 4. El parental gate propuesto necesita una especificación verificable

«Mantener 3 segundos + suma» no basta como requisito. Hay que definir:

- generación de ejercicios y rango de respuestas;
- entrada accesible para adultos y bloqueo de compras hasta resolverlo;
- reintentos, cancelación y caducidad de una sesión autorizada;
- protección de precios, restauración, enlaces, idioma y cualquier acción que
  pueda llevar fuera del área infantil;
- comportamiento al volver desde la hoja de pago del sistema;
- pruebas en teléfono, tableta, Fire y con lectores de pantalla.

El gate reduce acceso accidental; no debe describirse como prueba suficiente de
cumplimiento legal. Las declaraciones de audiencia, datos y familias deben
validarse contra las políticas vigentes al publicar y, cuando corresponda, con
asesoría especializada.

### 5. El alcance de v1 contradice la estructura funcional

El MVP promete un solo perfil, mientras que el flujo comienza en selección y
creación de perfil, y el modelo contempla hasta cuatro. Conviene elegir una de
estas alternativas:

1. **MVP realmente mínimo:** crear automáticamente un perfil local y comenzar
   en Inicio; introducir selección y ranking en v1.1.
2. **Base multiperfil desde v1:** implementar repositorio y selección ahora,
   aunque inicialmente se limite la UI a un perfil.

La primera reduce trabajo desechable en UI; la segunda reduce migraciones. Para
validar el núcleo del juego, se recomienda la primera.

### 6. Faltan reglas deterministas del juego

`GameState` aparece como archivo, pero no se especifican sus invariantes. Antes
de animar la UI deben definirse al menos:

- estados de carta: oculta, revelada, emparejada;
- máximo de dos cartas activas;
- bloqueo de taps durante comparación y celebración;
- qué ocurre al tocar dos veces la misma carta;
- barajado y prevención de que una partida reiniciada repita siempre el orden;
- restauración ante pausa, cierre o rotación;
- momento exacto de otorgar estrellas y protección contra doble conteo;
- comportamiento al salir a mitad de partida.

La máquina de estados debería ser Dart puro y probarse sin widgets ni audio.

## Decisiones que deben cerrarse en v0.2

La especificación usa alternativas donde el equipo necesita una sola elección:

| Tema | Estado actual | Recomendación para MVP |
|---|---|---|
| Estado | Provider o Riverpod | Riverpod, con dependencias inyectables |
| Persistencia | Hive o sqflite | Hive/almacén clave-valor con repositorios; no exponerlo a la UI |
| Audio | audioplayers o just_audio | Hacer un spike en Android y Fire; elegir por latencia y mezcla |
| Identificadores | UUID sin librería definida | ID aleatorio local generado por repositorio |
| Navegación | No definida | Rutas tipadas y gate como flujo, no solo overlay visual |
| Orientación | No definida | Paisaje o adaptativa, validada en teléfono y tableta |
| Reanudación | No definida | Persistir partida o descartarla explícitamente con UX segura |
| Localización UI | Solo audio descrito | Catálogo de textos ES/EN separado del orden de voces |
| Accesibilidad | No definida | Objetivos táctiles grandes, contraste y semántica para controles adultos |

No es imprescindible que la tecnología coincida literalmente con estas
recomendaciones; sí es imprescindible eliminar los «o» antes de crear la base
del proyecto.

## Modelo recomendado de derechos de compra

Separar productos adquiridos de derechos derivados evita ambigüedades:

```text
StoreSnapshot
  verifiedProductIds: Set<String>
  refreshedAt: DateTime?
  source: store | cache

Entitlements (derivado, no comprado directamente)
  allPacks: bool
  packIds: Set<String>
```

Reglas puras sugeridas:

1. `farm` siempre pertenece al usuario.
2. Cada recibo `pack_*` agrega ese paquete.
3. La presencia de `unlock_all`, `complete_1` o `complete_2` activa `allPacks`.
4. `allPacks` abre cada paquete conocido por el catálogo incluido en esa versión.
5. Al arrancar se muestran primero los derechos derivados del último snapshot;
   una consulta exitosa los sustituye de forma atómica.
6. Un fallo de red no debe convertir una lista desconocida en lista vacía.
7. Los estados pendiente y cancelado no conceden derechos.

Así, reinstalación, restauración y paquetes futuros se interpretan siempre con
la misma función, que debe tener pruebas unitarias exhaustivas.

## Arquitectura mínima sugerida

```text
UI / Screens
  -> Controllers (perfil, partida, tienda)
     -> Use cases / reglas puras
        -> Repositories (progreso, catálogo, derechos)
           -> adaptadores locales / Google Billing / Amazon IAP
```

Principios:

- La UI no lee Hive ni llama directamente a SDKs.
- El dominio no importa Flutter, audio ni plugins de tienda.
- `PurchaseService` produce estados tipados y `EntitlementResolver` transforma
  productos en acceso.
- `AudioService` acepta claves semánticas (`cow`, `es`) y no rutas construidas
  por las pantallas.
- El catálogo se valida al compilar/probar: IDs únicos, recursos existentes,
  exactamente dos audios por concepto y suficientes pares para cada nivel.

## Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
|---|---:|---|
| Latencia de audio en dispositivos Fire económicos | Alta | Prototipo temprano, precarga y pruebas en hardware real |
| Estado de IAP divergente del caché | Alta | Snapshot atómico, resultados tipados y matriz offline/restauración |
| SKU de completar mal interpretado tras reinstalar | Alta | Derechos derivados solo de IDs restaurables |
| Precio de completar peor que el bundle inicial | Alta | Rehacer tabla económica antes de configurar tiendas |
| Assets elevan el tamaño del binario | Media | Presupuesto por imagen/audio y compresión medida |
| Tap rápido rompe animaciones | Media | Máquina de estados pura y bloqueo explícito de entrada |
| Texto/audio bilingüe inconsistente | Media | Catálogo único validado automáticamente |
| Declaración «cero datos» no coincide con plugins | Alta | Auditoría de dependencias, manifest y tráfico antes de publicar |
| Progreso se pierde al borrar datos | Media | Explicarlo a padres; restaurar compras no implica restaurar progreso |

## Estrategia de pruebas

### Unitarias

- máquina de estados de cartas y taps concurrentes;
- cálculo de estrellas e idempotencia;
- resolución de derechos para cada combinación de SKU;
- migraciones del esquema local;
- validación del catálogo y selección aleatoria de pares.

### Integración

- arranque sin red con y sin caché;
- compra aprobada, pendiente, cancelada y fallida;
- restauración después de borrar datos;
- actualización desde una versión anterior con `allPacks`;
- interrupción durante audio, celebración y volteo;
- navegación atrás desde el pago del sistema.

### Dispositivos y UX

- Android de gama baja, tableta y al menos un Fire real;
- modo avión durante una partida completa;
- distintas relaciones de aspecto, tamaños de fuente y orientación acordada;
- prueba observacional con 2–3 niños, pero con protocolo: tarea, señales de
  ayuda, tiempo hasta primer par, errores de navegación y consentimiento adulto.

La prueba con pocos niños es adecuada como estudio formativo, no como evidencia
estadística. Cada sesión debe producir problemas observables y cambios concretos.

## Plan de implementación revisado

### Fase 0: cierre técnico

1. Resolver las decisiones abiertas de stack y orientación.
2. Congelar esquema de catálogo y reglas de partida.
3. Corregir precios y semántica de productos.
4. Redactar matriz de políticas y checklist de publicación por tienda.

### Fase 1: vertical slice sin IAP

1. Inicio → nivel de 4 pares → tablero → celebración → final.
2. Un subconjunto de arte y audio final o representativo.
3. Persistencia mínima de sonido, progreso y estrellas.
4. Pruebas de dominio y medición de latencia en hardware objetivo.

### Fase 2: contenido y robustez

1. Completar 12 pares y niveles 4/6/8.
2. Implementar avatar/perfil único según el alcance revisado.
3. Añadir accesibilidad, reanudación y manejo del ciclo de vida.
4. Ejecutar sesiones observacionales e iterar.

### Fase 3: monetización Google

1. Gate parental completo.
2. Adaptador Google y resolución de derechos.
3. Pruebas de compra/restauración con pistas de prueba.
4. Auditoría de dependencias, permisos, tráfico y declaraciones de consola.

### Fase 4: Amazon

No asumir que cambiar un flavor basta. Hacer un spike específico para IAP,
disponibilidad de plugins, ciclo de vida y audio en Fire antes de comprometer la
fecha de v1.2.

## Criterios de aceptación recomendados para v1

- Una partida completa funciona en modo avión después de instalar la app.
- Ningún tap rápido puede revelar más de dos cartas ni duplicar recompensas.
- Todas las rutas a precio, compra, restauración o ajustes protegidos pasan por
  un gate cuya autorización caduca.
- El juego solicita cero permisos sensibles y una auditoría confirma que no hay
  telemetría incorporada por dependencias.
- Una compra válida se restaura tras borrar datos; el progreso local no se
  promete como restaurable.
- Un fallo o ausencia de red no elimina derechos cacheados.
- Audio e imágenes existen para todos los elementos del catálogo y todos los
  niveles pueden formarse sin duplicados indebidos.
- La UX pasa una prueba formativa: los niños llegan sin instrucciones desde
  Inicio hasta el primer par, y los bloqueos observados quedan documentados.

## Conclusión

El concepto y la arquitectura general son sólidos, especialmente la decisión de
minimizar datos y mantener el juego local. Los mayores riesgos no están en el
memorama sino en IAP, restauración, semántica de bundles y afirmaciones de
cumplimiento. La siguiente versión debe convertir alternativas en decisiones,
expresar el juego como una máquina de estados y definir derechos de compra
reconstruibles. Con esos cambios, el equipo puede avanzar a un vertical slice
con bajo riesgo y validar primero la experiencia que diferencia al producto.
