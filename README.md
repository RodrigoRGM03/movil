# PoSly

Aplicación Flutter para el punto de venta PoSly. Incluye bienvenida,
autenticación, recuperación de contraseña, tema claro/oscuro y navegación
responsive por los módulos de la primera mitad del proyecto.

## Requisitos

- Flutter estable y Dart incluidos con Flutter.
- API Laravel accesible por HTTP/HTTPS.

## Ejecutar

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=https://tu-servidor.example/api
```

`API_BASE_URL` debe incluir el prefijo de API que use Laravel, por ejemplo
`/api`. No agregues una barra final. La autenticación espera los endpoints
`auth/login`, `auth/register`, `auth/forgot-password` y `auth/logout`.
El token se guarda con almacenamiento seguro y se envía como Bearer.

## Explorar sin backend

Para entrar al dashboard con datos ficticios locales, ejecuta:

```powershell
flutter run -d chrome --dart-define=POSLY_DEMO_MODE=true
```

En la pantalla de acceso aparecerá **Explorar modo demo**. Este modo evita
llamadas al backend y no guarda cambios; la opción no aparece en ejecuciones
normales si no se activa la bandera.

El dashboard consulta `dashboard`. Las pantallas de consulta usan endpoints
REST configurados en `lib/features/shell/posly_modules.dart`. Los nombres de
rutas son una base de integración y deben alinearse con las rutas reales de la
API y la especificación maestra antes de completar operaciones de escritura.

## Módulos navegables

- Dashboard.
- Productos y categorías.
- Precios y promociones.
- Inventario y movimientos.
- Ventas y métodos de pago.
- Devoluciones y cancelaciones.
- Caja y sesiones de efectivo.
- Clientes, fiados/cuentas de crédito y abonos.
- Envases retornables.

La app usa el tema PoSly claro y oscuro. El documento maestro de requisitos y
las rutas/contratos del backend deben incorporarse para implementar y validar
las reglas de negocio y las operaciones de cada módulo.
