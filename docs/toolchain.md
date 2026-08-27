# Toolchain reproducible

## Version fijada

El proyecto usa FVM. La versión obligatoria se declara en `.fvmrc` y los
comandos de Flutter/Dart deben ejecutarse como `fvm flutter` y `fvm dart`.

| Componente | Versión | Fecha de validación | Evidencia |
|---|---|---|---|
| FVM | 4.1.2 | 2026-08-27 | `fvm --version` |
| Flutter | 3.44.8 stable | 2026-08-27 | `fvm flutter --version` |
| Dart | 3.12.2 | 2026-08-27 | `fvm dart --version` |
| Java (Android Studio JBR) | 17.0.6 LTS | 2026-08-27 | `fvm flutter doctor -v` |
| Android SDK | 36.0.0 | 2026-08-27 | `fvm flutter doctor -v` |
| compileSdk | 36 | 2026-08-27 | Flutter Gradle plugin 3.44.8 |
| targetSdk | 36 | 2026-08-27 | Flutter Gradle plugin 3.44.8 |
| Gradle | 9.1.0 | 2026-08-27 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Android Gradle Plugin | 9.0.1 | 2026-08-27 | `android/settings.gradle.kts` |
| Kotlin | 2.3.20 | 2026-08-27 | `android/settings.gradle.kts` |

FVM reutiliza un SDK local cuya versión coincide exactamente con 3.44.8. El
enlace del proyecto (`.fvm/flutter_sdk`) y las cachés no se versionan; la ruta
concreta depende de cada máquina.

## Android generado

La plataforma Android fue generada con:

```powershell
fvm flutter create --platforms=android --org com.memogranja --project-name memo_granja .
```

El identificador actual generado es `com.memogranja.memo_granja`. La firma de
release todavía usa la configuración debug del template y debe cambiarse antes
de publicar.

## Procedimiento reproducible

Desde la raíz del repositorio:

```powershell
fvm install
fvm use 3.44.8
fvm flutter --version
fvm flutter doctor -v
fvm flutter pub get
./tool/check.sh
fvm flutter build apk --debug --target-platform android-arm64 --split-per-abi
```

`tool/bootstrap_flutter.sh` automatiza la instalación/activación de `.fvmrc`,
la generación de Android cuando falta, `pub get` y los checks. No actualiza el
SDK global ni mueve rutas instaladas fuera del proyecto.

## Estado del gate

El checkout ya tiene `.fvmrc`, Android y `pubspec.lock`; el comando anterior
produjo un APK debug correctamente. El artefacto y las cachés de compilación se
retiraron después para liberar espacio. `fvm flutter doctor` detecta Android
SDK y licencias, pero en la validación del 27 de agosto de 2026 no había un
teléfono Android físico conectado. La ejecución en dispositivo debe
completarse antes de declarar cerrado el gate de la Fase A.

`fvm flutter doctor -v` también advierte que `flutter` y `dart` globales están en
el `PATH`; esa ruta no se usa para las tareas del proyecto y no se debe modificar
el SDK global.

No versionar `.fvm/flutter_sdk`, cachés, `build/` ni `android/local.properties`.
