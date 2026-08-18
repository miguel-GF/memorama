# Instrucciones para agentes

Estas instrucciones abarcan todo el repositorio.

## Antes de editar

1. Lee `README.md`, `docs/README.md`, `docs/architecture.md` y `docs/plan-v1.md`.
2. Revisa `git status` y no sobrescribas cambios ajenos sin confirmar su origen.
3. Lee `pubspec.yaml` y los tests relacionados con el área que modificarás.
4. No asumas que Flutter está instalado. Compruébalo con `flutter --version`.
5. Para UI/avatar/almacenamiento, lee respectivamente `docs/design-system.md`,
   `docs/avatar-system.md` y `docs/offline-and-backup.md` antes de diseñar.

## Límites del producto

- Offline-first y sin backend propio.
- Sin anuncios, analítica, cuentas ni login social.
- Sin permisos sensibles ni datos de menores.
- Flutter puro para el memorama; no agregar Flame sin un minijuego que necesite
  movimiento continuo o colisiones.
- No implementar IAP, perfiles o persistencia antes de que la fase activa los
  requiera.
- No agregar dependencias por conveniencia. Explica su necesidad y su impacto en
  privacidad, Android, Fire OS, tamaño y mantenimiento.

## Convenciones de código

- Formatea con `dart format` y obedece `analysis_options.yaml`.
- Mantén las reglas en `lib/models/` libres de navegación, widgets, plugins,
  almacenamiento y rutas de assets.
- Accede a datos mediante repositorios; una pantalla no debe decodificar JSON ni
  leer almacenamiento directamente.
- Usa modelos inmutables y resultados tipados. No representes estados de compra
  con un simple booleano.
- Conserva IDs de catálogo/SKU estables. Trátalos como datos persistentes.
- Todos los timers, listeners, streams y controllers deben liberarse en
  `dispose`.
- Tras un `await` en un `State`, comprueba `mounted` antes de usar `context` o
  mutar la UI.
- Los controles infantiles deben ser grandes, claros y tener `Semantics` útil.
- No simules como terminada una función ausente: placeholders, audio falso y
  servicios mock deben identificarse explícitamente.

## Pruebas obligatorias

Ejecuta:

```bash
./tool/check.sh
```

Si Flutter no está disponible, ejecuta los checks independientes posibles
(`git diff --check`, `bash -n`, validación JSON), explica la limitación y **no
digas que `flutter analyze` o `flutter test` pasaron**.

Agrega pruebas cuando cambies:

- reglas de revelado, coincidencia o recompensas;
- esquema o validación del catálogo;
- persistencia o migraciones;
- resolución de derechos de compra;
- navegación protegida por el gate parental.

## Assets y contenido

- Lee `docs/catalog.md`.
- No agregues arte, fuentes, música o voces sin procedencia y licencia registradas.
- Emoji es placeholder de prototipo, no arte final.
- No renombres archivos o IDs publicados sin una migración documentada.

## Commits y documentación

- Un commit debe representar una unidad coherente y dejar el árbol limpio.
- Actualiza README/docs si cambia setup, arquitectura, alcance o comportamiento.
- En el resumen final distingue checks aprobados, fallidos y no ejecutados.
- Cita archivos y líneas relevantes al describir el cambio.
