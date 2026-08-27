# Análisis del plan de desarrollo

## Dictamen

El orden general es correcto: primero vertical slice, después validación con
niños y solo entonces persistencia y monetización. Es más ejecutable que intentar
construir toda la arquitectura descrita en la documentación técnica desde el día
uno. Para una sola persona a 10–15 horas semanales, la estimación de 2.5–4 meses
es posible solo si arte, audio, revisión de tienda y reclutamiento no bloquean la
ruta crítica; debe manejarse como rango objetivo, no como fecha comprometida.

## Ajustes aplicados al arranque

1. **Flutter estable, no «latest» implícito.** Actualizar sin registrar la versión
   hace que dos máquinas produzcan builds distintos. El bootstrap usa el canal
   estable disponible y deja constancia local de la versión; después del primer
   build validado, CI debe fijar exactamente esa versión.
2. **Android primero.** Solo se genera Android. Amazon sigue siendo Android, pero
   su IAP y los dispositivos Fire requieren un spike separado en la fase prevista.
3. **Dependencias mínimas.** Riverpod, Hive, audio e IAP no se añaden hasta que
   exista una necesidad del vertical slice. Esto reduce fallos de configuración
   y permite que las reglas del memorama tengan pruebas puras desde el inicio.
4. **Arte temporal explícito.** El catálogo usa emoji para que el juego pueda
   ejecutarse ya, sin hacer pasar placeholders por assets licenciados finales.
5. **Dominio antes que animación.** La base incluye máximo de dos reveladas,
   bloqueo durante resolución, emparejamiento y finalización. El flip 3D y la
   celebración audiovisual se incorporan sobre esas invariantes.

## Cambios recomendados al plan

### Fase 0

- No usar todavía un package name de ejemplo como `com.tuestudio.memogranja`.
  Confirmar dominio/identidad del publicador antes de crear la ficha: cambiar el
  application ID después de publicar equivale a otra aplicación.
- Añadir una hoja de procedencia/licencia para cada imagen, voz, música y fuente.
- Definir presupuesto de peso, volumen normalizado, formato y silencio al inicio
  y final de cada audio.
- El hito debe incluir `fvm flutter analyze` y `fvm flutter test`, no solo «hola mundo».

### Fases 1 y 2

- El orden debe ser reglas probadas → tablero → animaciones → audio. De otro modo,
  los taps durante animaciones suelen convertir UI y dominio en un solo estado.
- Añadir pruebas de ciclo de vida: segundo plano durante una comparación, cambio
  de tamaño/orientación y salida antes de terminar.
- El protocolo con niños necesita consentimiento del adulto, dispositivo común,
  tarea idéntica y notas sin nombres ni grabaciones innecesarias.
- «Un niño de ~4 años» es señal cualitativa, no garantía. Registrar cuántos llegan,
  dónde dudan y qué cambio se deriva de cada observación.

### Fase 3

- La documentación anterior define v1 con un perfil, pero este plan incorpora
  cuatro y ranking antes de monetización. Esto amplía el MVP. Para lanzar antes,
  mantener un perfil automático en v1 y mover selector/ranking a v1.1.
- Si se conserva multiperfil, añadir desde el comienzo versión de esquema,
  migraciones e idempotencia al otorgar estrellas.

### Fase 4

- No implementar los SKU condicionales literalmente hasta corregir su economía y
  restauración. `complete_1` puede terminar costando más al comprador previo que
  `unlock_all` y el derecho debe poder reconstruirse solo con productos devueltos
  por la tienda.
- Reemplazar resultados booleanos de compra por estados: cargando, disponible,
  pendiente, comprado, restaurado, cancelado, no disponible y error recuperable.
- Tratar un fallo de consulta como «estado desconocido», nunca como «no posee».
- Probar reinstalación y borrado de datos, además del cierre offline del hito.

### Fases 5–7

- Las políticas, formularios y requisitos de pruebas de Google cambian. Verificar
  sus valores vigentes en la cuenta real; no codificar «14 días» o una cantidad
  de testers como regla permanente del proyecto.
- «Cero permisos sensibles» no significa necesariamente «sin permiso Internet»:
  billing y componentes de tienda pueden declarar permisos por manifest merge.
  La aceptación correcta es inventariar el manifest final y justificar cada
  permiso y cada conexión observada.
- La declaración de datos debe derivarse del comportamiento del binario y sus
  dependencias, no de la intención del producto.

## Ruta crítica revisada

1. Confirmar identidad Android y licencias de assets.
2. Ejecutar el bootstrap con Flutter estable y guardar la versión validada en CI.
3. Completar el vertical slice con placeholders y pruebas de dominio.
4. Medirlo en teléfono económico/tableta antes de integrar plugins.
5. Realizar prueba UX #1 e iterar.
6. Cerrar alcance de perfil único frente a multiperfil.
7. Integrar persistencia y probar migraciones.
8. Aprobar modelo económico y de entitlements.
9. Integrar gate e IAP con cuentas de prueba.
10. Auditar release, probar UX #2 y entrar a la pista cerrada.

## Resultado de esta iteración

El repositorio queda preparado como vertical slice sin plugins: catálogo de doce
pares, navegación mínima, niveles 4/6/8, tablero jugable y reglas unit-testables.
No se afirma que el entorno actual tenga el SDK más reciente: el contenedor no
incluye Flutter y la red bloquea su descarga. El script permite completar la
preparación de forma verificable en una máquina con acceso al SDK oficial.
