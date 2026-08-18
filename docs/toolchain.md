# Toolchain

## Estado verificado

La imagen usada para la última edición **no contiene Flutter ni Dart**. Por tanto,
todavía no existe una versión Flutter verificada/fijada para este repositorio y no
se han podido regenerar los archivos Android desde aquí.

| Componente | Estado |
|---|---|
| Flutter | Pendiente de registrar |
| Dart | Restricción del proyecto: `>=3.4.0 <4.0.0` |
| Java disponible en el contenedor | 21.0.2, no validado con build Flutter |
| Android SDK/Gradle | Pendiente; `android/` aún no generado |

No escribir «latest» como versión reproducible ni inventar un número. La versión
estable cambia; consultar el [archivo oficial de Flutter](https://docs.flutter.dev/install/archive),
probarla y registrar el resultado exacto.

## Procedimiento para fijar versión

En una máquina con acceso al SDK oficial:

```bash
UPDATE_FLUTTER=1 ./tool/bootstrap_flutter.sh
flutter --version
dart --version
flutter doctor -v
./tool/check.sh
```

Después:

1. copia las versiones exactas a la tabla siguiente;
2. prueba un APK en teléfono y tableta objetivo;
3. versiona `android/`, `.metadata` y `pubspec.lock`;
4. fija Flutter con la herramienta elegida para CI;
5. actualiza README si cambia el comando de setup.

## Versiones fijadas para CI/release

| Componente | Versión | Fecha de validación | Evidencia |
|---|---|---|---|
| Flutter | **pendiente** | — | — |
| Dart | **pendiente** | — | — |
| Java | **pendiente** | — | — |
| compileSdk | **pendiente** | — | — |
| targetSdk | **pendiente** | — | — |
| Gradle/AGP | **pendiente** | — | — |

Solo una versión que haya pasado los gates se considera soportada. Actualizar el
SDK es un cambio separado, con diff generado revisado y checks completos.
