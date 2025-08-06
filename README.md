# Invoky

Aplicación de escritorio desarrollada en Flutter para la gestión integral de inventario, ventas y caja en tiendas minoristas. Con integración a Supabase como base de datos y soporte para lectura de códigos de barras.

## Características principales

- Gestión completa de inventario de productos
- Control de caja con registro de apertura y cierre
- Búsqueda de productos por código de barras (compatible con lectores USB)
- Registro detallado de ventas
- Gestión de clientes y proveedores
- Reportes y estadísticas de ventas
- Multiplataforma: macOS y Windows

## Requisitos

- [Flutter](https://flutter.dev/) 3.8 o superior
- Cuenta y proyecto en [Supabase](https://supabase.com/)
- macOS 12+ o Windows 10+ (para escritorio)

## Instalación y configuración

1. **Clona el repositorio:**

   ```sh
   git clone https://github.com/tu_usuario/invoky.git
   cd invoky
   ```

2. **Instala las dependencias:**

   ```sh
   flutter pub get
   ```

3. **Configura las variables de entorno:**

   - Crea un archivo `.env` en la raíz del proyecto con el siguiente contenido:
     ```env
     SUPABASE_URL=TU_URL_SUPABASE
     SUPABASE_ANON_KEY=TU_ANON_KEY_SUPABASE
     ```
   - **No subas este archivo al repositorio.**

4. **Ejecuta la aplicación:**
   ```sh
   flutter run -d macos   # Para macOS
   flutter run -d windows # Para Windows
   ```

## Estructura del proyecto

- `lib/models/` — Modelos de datos (Producto, Caja, Venta, etc.)
- `lib/screens/` — Pantallas principales de la aplicación
- `lib/services/` — Servicios para acceso a Supabase y lógica de negocio
- `lib/widgets/` — Componentes reutilizables
- `lib/theme/` — Configuración de temas y estilos
- `lib/utils/` — Utilidades y helpers
- `lib/main.dart` — Punto de entrada de la aplicación
- `.env` — Variables de entorno (no versionado)

## Atajos de teclado

- **⌘/Ctrl + B** — Abre el diálogo de búsqueda por código de barras
- **⌘/Ctrl + N** — Nueva venta/transacción
- **⌘/Ctrl + K** — Abre la gestión de caja
- **⌘/Ctrl + I** — Ir al inventario
- **⌘/Ctrl + R** — Actualizar vista actual

## Buenas prácticas

- Las claves y URLs sensibles están en `.env` (no se suben a git)
- El código está organizado por responsabilidad (modelo, servicio, UI)

## Contribuir

1. Haz un fork del repositorio
2. Crea una rama para tu funcionalidad: `git checkout -b mi-feature`
3. Realiza tus cambios y haz commit
4. Envía un Pull Request

## Licencia

MIT

---

¿Dudas o sugerencias? ¡Abre un issue o contacta al autor!
