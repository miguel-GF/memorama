# Contrato del catálogo

El catálogo empaquetado vive en `assets/data/packs.json` y se declara en
`pubspec.yaml`. Es contenido local: modificarlo requiere publicar una nueva
versión de la app.

## Esquema actual

```json
{
  "packs": [
    {
      "id": "farm",
      "included": true,
      "pairs": [
        {
          "id": "cow",
          "emoji": "🐄",
          "es": "Vaca",
          "en": "Cow"
        }
      ]
    }
  ]
}
```

## Campos

| Campo | Tipo | Regla |
|---|---|---|
| `packs` | lista | Al menos un paquete |
| `pack.id` | string | Único, estable, ASCII minúscula (`snake_case`) |
| `pack.included` | bool | `true` para contenido gratuito |
| `pack.pairs` | lista | IDs únicos dentro de todo el catálogo |
| `pair.id` | string | Identidad persistente; no es texto visible |
| `pair.emoji` | string | Placeholder visual temporal |
| `pair.es` | string | Nombre mostrado/pronunciado en español |
| `pair.en` | string | Nombre mostrado/pronunciado en inglés |

El paquete Granja necesita al menos ocho pares para formar todos los niveles
actuales y contiene doce para el contenido previsto.

## Reglas para cambios

1. No renombres IDs existentes. En el futuro serán claves de progreso, audio y
   posiblemente derechos.
2. No reutilices un ID retirado para otro concepto.
3. Mantén nombres breves, naturales y revisados por hablantes de ambos idiomas.
4. Agrega una prueba si incorporas un campo obligatorio.
5. Verifica JSON y pruebas antes de hacer commit.
6. No almacenes precio visible en este catálogo: la tienda proporciona precio y
   moneda localizados.

## Assets finales previstos

Cuando existan imágenes y audio licenciados, el esquema podrá añadir referencias
explícitas, por ejemplo:

```text
assets/images/packs/farm/cow.webp
assets/audio/es/cow.mp3
assets/audio/en/cow.mp3
```

Antes de ampliar el JSON se debe definir y probar:

- formatos y tamaños máximos;
- volumen normalizado y ausencia de silencios largos;
- comportamiento cuando falta un recurso;
- precarga para evitar latencia en dispositivos económicos;
- archivo de atribución/licencia fuera del bundle cuando corresponda.

No construyas rutas concatenando texto visible. Usa `pair.id` o rutas explícitas
validadas por tests.
