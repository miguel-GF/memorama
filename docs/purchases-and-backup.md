# Compras y respaldo local

## Decisión de producto

Memo Granja no crea cuentas ni pide iniciar sesión. La identidad de una compra
es la cuenta de la tienda (Google Play en Android), mientras que el progreso y
la configuración permanecen en el dispositivo.

El catálogo de productos usa IDs estables:

| Producto | Tipo | Acceso |
|---|---|---|
| `full_access_lifetime` | No consumible | Todos los paquetes actuales y futuros |
| `pack_<packId>` | No consumible opcional | Solo el paquete cuyo ID coincide |

El catálogo activo solo publica `full_access_lifetime` porque el contenido de
paquetes adicionales todavía no existe. `StoreProduct.pack` y
`StoreCatalog.packageProductId` dejan preparada la misma dinámica para vender
paquetes por separado sin renombrar IDs publicados. No se usarán suscripciones
ni productos consumibles para contenido permanente.

El precio, moneda, título y disponibilidad se leen de Google Play; no se
codifican importes en la aplicación. Una compra de por vida incluye el contenido
que se publique después, siempre que la ficha comercial mantenga esa promesa.

## Flujo sin login propio

1. La zona adulta consulta los productos exactos del catálogo de la app.
2. Solo una compra `purchased` o `restored` verificada concede un entitlement.
3. `pending`, cancelada, error o producto desconocido nunca concede acceso.
4. La tienda sigue siendo la autoridad; la app reconoce la compra pendiente de
   completar y conserva un cache local de IDs comprados para funcionar offline.
5. Restaurar con una cuenta sin compras elimina el cache cuando Play confirma un
   lote vacío. Una indisponibilidad de red conserva el acceso previamente
   cacheado.
6. Cambiar de cuenta no borra el progreso. Solo reconcilia los entitlements de
   la cuenta activa cuando se puede consultar la tienda.

El verificador local valida producto y estado que entrega el plugin, pero no es
verificación criptográfica antifraude. Para el MVP no se añade backend, RTDN ni
un servidor que reciba tokens. Antes de cobrar en producción hay que crear los
productos en Play Console y probar compra, pendiente, cancelación, restauración,
cambio de cuenta, reembolso y modo sin conexión en una pista autorizada.

## Respaldo local

`LocalBackupService` exporta e importa un JSON portable con el progreso de
niveles. El archivo no está cifrado por la aplicación y queda bajo control de la
persona adulta. Importar valida aplicación, versión y estructura antes de
escribir; un archivo incompatible no modifica el progreso existente.

El JSON nunca contiene:

- cuentas, correos o credenciales;
- `full_access_lifetime` ni otros IDs de compra;
- tokens, recibos o estados de facturación;
- datos de una partida en curso.

El cache de entitlements usa otra clave local y no forma parte del respaldo. La
licencia se restaura desde la tienda, no desde un archivo compartido. Android
Auto Backup permanece desactivado (`android:allowBackup="false"`) para conservar
la decisión v1 de no enviar datos del dispositivo a un backup cloud; el backup
manual sigue disponible desde la zona adulta.

## Dependencias y alcance técnico

| Dependencia | Motivo | Impacto |
|---|---|---|
| `in_app_purchase` | Consultar, comprar y restaurar no consumibles | Añade integración de tienda; no crea login ni permisos de contenido |
| `shared_preferences` | Cache local de entitlements y progreso | Datos locales pequeños; no transporte propio |
| `file_picker` | Elegir un JSON para restaurar | Selector del sistema; no acceso general a archivos |
| `file_saver` | Guardar el JSON exportado | Integración nativa para el destino elegido |

Estas dependencias no incorporan anuncios, analítica, cuentas, backend ni
permisos sensibles. Fire OS queda fuera de esta primera integración de compras;
si se habilita, necesitará un gateway de tienda separado sin cambiar el dominio
de entitlements.
