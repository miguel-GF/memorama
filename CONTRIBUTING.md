# Contribuir a Memo Granja

## Flujo recomendado

1. Abre una rama pequeña para una sola tarea.
2. Confirma el alcance contra `docs/README.md` y el roadmap activo.
3. Escribe o ajusta la prueba del comportamiento.
4. Implementa la solución más pequeña que satisfaga esa prueba.
5. Ejecuta `./tool/check.sh` y prueba el flujo afectado en Android.
6. Actualiza documentación y crea un commit descriptivo.

## Commits

Usa mensajes imperativos y acotados, por ejemplo:

```text
feat: add bilingual match audio
fix: block taps while cards resolve
test: validate duplicate catalog ids
docs: explain Android bootstrap
```

No mezcles actualización masiva de SDK, assets nuevos y lógica de juego en el
mismo commit.

## Pull requests

Incluye:

- problema y motivación;
- comportamiento anterior y nuevo;
- capturas o video para cambios visuales;
- comandos exactos de verificación y sus resultados reales;
- limitaciones conocidas;
- impacto en privacidad, permisos, persistencia o compras, si aplica.

## Código Dart/Flutter

- Sigue `analysis_options.yaml`.
- Prefiere widgets pequeños y `const` cuando sea posible.
- Mantén lógica determinista fuera de la UI.
- Evita estado global hasta que exista un caso real que lo requiera.
- No captures excepciones para ocultarlas. Los errores recuperables deben tener
  estado y mensaje explícitos.
- No añadas `try/catch` alrededor de imports.

## Pruebas manuales mínimas

Para cambios del tablero:

1. inicia cada nivel;
2. toca rápidamente una carta varias veces;
3. intenta revelar una tercera carta;
4. verifica pareja y error;
5. envía la app a segundo plano durante una comparación;
6. completa el tablero;
7. repite sin red.

Las sesiones con menores requieren consentimiento adulto, observación sin datos
identificables y el protocolo definido en la documentación del plan.

## Dependencias

Antes de agregar una dependencia, documenta:

- por qué el SDK de Flutter no basta;
- mantenimiento y licencia;
- tráfico o datos que produce;
- permisos/manifest que incorpora;
- soporte Android y Fire OS;
- impacto aproximado en el binario.

Las dependencias vinculadas con anuncios, tracking, cuentas o redes sociales no
son compatibles con el alcance del producto.
