# Memo Granja

Memorama infantil bilingüe (español/inglés) para niñas y niños de 3 a 6 años.
El producto está diseñado para funcionar sin cuentas, anuncios, analítica ni un
backend propio. Todo el contenido jugable y el progreso permanecen en el
dispositivo; la red se reservará para compras gestionadas por la tienda y para
actualizaciones de la aplicación.

> **Estado:** prototipo Flutter en desarrollo. La experiencia visual usa emoji
> como arte temporal y todavía no incorpora audio, persistencia, perfiles ni
> compras. No es una versión publicable.

## Qué funciona hoy

- Flujo **Inicio → selección de nivel → tablero → final**.
- Catálogo local de 12 animales con nombres ES/EN.
- Tableros de 4, 6 y 8 pares.
- Barajado, máximo de dos cartas abiertas y bloqueo durante la comparación.
- Animación de volteo, parejas atenuadas y celebración bilingüe automática.
- Máquina de fases independiente de Flutter y controller observable para la UI.
- Tokens visuales semánticos y alternativa inicial de movimiento reducido.
- Pruebas de las reglas de juego y de la integridad del catálogo.

## Qué no funciona todavía

- Audio e imágenes finales.
- Guardado de progreso, estrellas, avatares y perfiles.
- Gate parental, zona de adultos y compras dentro de la app.
- Proyecto Android generado, cuando el checkout se hace sin ejecutar el
  bootstrap.
- Flavors Google/Amazon, firma release y configuración de tiendas.

El alcance, los riesgos y la secuencia prevista se detallan en el
[índice de documentación](docs/README.md).

## Requisitos

- Git.
- Flutter instalado desde el canal `stable`.
- Android Studio o Android SDK con las licencias aceptadas.
- Un emulador o, preferentemente, un teléfono Android físico.
- Para Fire OS, un dispositivo real cuando comience la fase Amazon.

El proyecto acepta Dart `>=3.4.0 <4.0.0`. Antes de fijar una versión concreta de
Flutter para CI/release, esa versión debe pasar análisis, pruebas y una ejecución
en los dispositivos objetivo.

La versión exacta todavía está pendiente porque este entorno no contiene Flutter.
No sustituyas ese dato por «latest»: consulta el estado y el procedimiento para
fijarla en [`docs/toolchain.md`](docs/toolchain.md).

## Primer arranque

```bash
git clone <URL_DEL_REPOSITORIO>
cd memorama
flutter --version
flutter doctor -v
./tool/bootstrap_flutter.sh
flutter run
```

`bootstrap_flutter.sh` hace lo siguiente:

1. comprueba que Flutter exista;
2. opcionalmente actualiza el canal estable;
3. genera el proyecto Android si falta;
4. registra localmente la versión efectiva en `.tool-versions.local`;
5. descarga dependencias y ejecuta todos los checks disponibles.

Por defecto **no actualiza Flutter automáticamente**. Para solicitar una
actualización consciente al último estable disponible:

```bash
UPDATE_FLUTTER=1 ./tool/bootstrap_flutter.sh
```

Revisa el diff después de `flutter create` o de una actualización del SDK. Los
archivos generados de plataforma sí deben versionarse una vez creados y validados.

## Comandos de desarrollo

```bash
# Formato
dart format lib test

# Verificación completa
./tool/check.sh

# Ejecución
flutter run

# Una prueba concreta
flutter test test/models/game_state_test.dart
```

## Estructura

```text
assets/data/        catálogo de contenido empaquetado
docs/               decisiones, análisis y contratos técnicos
lib/app/            composición y tema global
lib/models/         modelos y reglas del dominio
lib/repositories/   acceso a catálogos y futuras fuentes locales
lib/screens/        pantallas y flujos
lib/widgets/        componentes visuales reutilizables
test/               pruebas que reflejan la estructura de lib/
tool/               bootstrap y verificaciones locales/CI
```

La dependencia fluye desde UI hacia dominio y repositorios. Las reglas del juego
no deben depender de pantallas, rutas, audio, almacenamiento o una tienda. Consulta
la [arquitectura](docs/architecture.md) antes de introducir un plugin.

## Trabajar con el catálogo

El contenido se define en [`assets/data/packs.json`](assets/data/packs.json). No
añadas pares directamente desde una pantalla. Cada ID debe ser estable y único;
renombrarlo puede romper progreso o derechos guardados en versiones futuras.
Consulta el [contrato del catálogo](docs/catalog.md) antes de editarlo.

## Calidad y definición de terminado

Todo cambio debe, como mínimo:

1. quedar formateado;
2. pasar `flutter analyze`;
3. pasar `flutter test`;
4. agregar o actualizar pruebas si modifica comportamiento;
5. mantener el juego utilizable sin red;
6. no agregar telemetría, anuncios, cuentas o permisos sensibles;
7. documentar cualquier dependencia, migración o decisión nueva.

Una limitación del entorno debe reportarse como tal; nunca se debe afirmar que un
check pasó si no se ejecutó.

## Privacidad y seguridad infantil

- No agregar analítica, anuncios, login social ni identificadores remotos.
- No introducir permisos de cámara, micrófono, ubicación o contactos.
- Precios, compras, restauraciones, enlaces y ajustes protegidos deben vivir tras
  un gate parental.
- No registrar nombres, voz, imágenes ni comportamiento de menores.
- Auditar el manifest final y el tráfico de cada build release: la intención de
  «cero datos» no basta si una dependencia transmite información.

Estos principios son requisitos de producto, no asesoría legal. Las políticas de
Google Play y Amazon deben verificarse nuevamente antes de cada publicación.

## Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md). Los agentes automatizados también deben
seguir [AGENTS.md](AGENTS.md). Mantén cada cambio pequeño, verificable y dentro de
la fase activa del roadmap.

## Licencia

No se ha definido una licencia pública. Hasta que la persona propietaria del
proyecto agregue una, no asumas permiso para redistribuir código, arte o audio.
