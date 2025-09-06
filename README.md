# App Órdenes - Gestión de Producción

Una aplicación móvil Flutter para la gestión de producción que unifica en un solo flujo: selección de órdenes de trabajo → confirmación de operaciones → movimientos de materiales → recepción de producto terminado.

## Stack Tecnológico

- **Flutter**: 3.24.x
- **Dart**: 3.8.x
- **Material Design**: 3

## Características Principales

### MVP (Minimum Viable Product)

1. **Consulta de órdenes**: Filtrar por pedido y posición del cliente, o por centro/planta, puesto de trabajo y estado.

2. **Trabajo del día**: Listar operaciones abiertas con tarifas/actividades planificadas y su estado.

3. **Confirmación (parcial/final)**: Capturar cantidades buenas, rechazo y reproceso; tiempos por actividad con totalizador automático.

4. **Movimientos de materiales**: Sugeridos a partir de la lista de materiales; permitir agregar/quitar materiales; búsqueda por descripción/código.

## Flujo de Pantallas

### 1. Bandeja / Filtro
- Campos rápidos: Pedido cliente, Posición, Centro/Planta, Puesto de trabajo, Rango de fechas, Estado
- Lista de órdenes → tap abre sus operaciones

### 2. Operaciones de la orden
- Tarjeta por operación (código, texto breve, fechas/horas relevantes, actividades/tarifas actuales)
- Botón "Confirmar" abre el formulario

### 3. Confirmación + Actividades
- Encabezado (orden/operación/material/centro/puesto)
- Cantidad buena / rechazo / reproceso
- Sección Actividades: líneas editables (MOD, Indirectos, Energía, Deprec…) con sumatoria
- Toggle "Compensar reservas abiertas"
- Botón "Componentes"

### 4. Componentes (consumos)
- Tabla con sugeridos (por BOM o última confirmación)
- Por línea: material, cantidad, UoM, almacén, lote, clase de valoración, tipo de movimiento
- Agregar componente (búsqueda por texto/código, lector de código de barras)
- Eliminar o marcar "no consumido"

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   └── orden_trabajo.dart    # Modelos principales
├── screens/                  # Pantallas de la aplicación
│   ├── bandeja_screen.dart   # Filtro y lista de órdenes
│   ├── operaciones_screen.dart # Lista de operaciones
│   ├── confirmacion_screen.dart # Confirmación y actividades
│   └── componentes_screen.dart # Gestión de componentes
├── services/                 # Servicios de datos
│   └── orden_service.dart    # Servicio de órdenes
└── widgets/                  # Widgets reutilizables
```

## Instalación y Configuración

### Prerrequisitos

1. **Flutter SDK 3.24.x**: [Guía de instalación](https://docs.flutter.dev/get-started/install)
2. **Android Studio**: Para desarrollo y emulación Android
3. **VS Code**: Editor recomendado con extensiones de Flutter

### Configuración del Proyecto

1. **Clonar e importar el proyecto**:
   ```bash
   # El proyecto ya está creado, simplemente ábrelo en VS Code
   code app_ordenes/
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Verificar la instalación**:
   ```bash
   flutter doctor
   ```

### Ejecutar la Aplicación

#### En Emulador Android (Android Studio)

1. Abrir Android Studio
2. Crear/iniciar un emulador Android
3. En VS Code, ejecutar:
   ```bash
   flutter run
   ```
   O usar F5 para debug

#### En Dispositivo Android Físico

1. Habilitar "Opciones de desarrollador" en el dispositivo
2. Activar "Depuración USB"
3. Conectar el dispositivo via USB
4. Ejecutar:
   ```bash
   flutter run
   ```

#### Para Web (opcional)

```bash
flutter run -d chrome
```

## Características Técnicas

### Material Design 3
- Usa el sistema de colores dinámico
- Componentes modernos (Cards, FilledButton, etc.)
- Soporte para tema claro y oscuro

### Arquitectura
- Separación clara entre modelos, servicios y UI
- Estados locales con StatefulWidget
- Navegación estándar de Flutter
- Validaciones en línea

### Funcionalidades Implementadas

- ✅ Filtrado avanzado de órdenes
- ✅ Navegación entre pantallas
- ✅ Confirmación de operaciones
- ✅ Gestión de actividades y tarifas
- ✅ Administración de componentes/materiales
- ✅ Validaciones de formularios
- ✅ Interfaz adaptable para móvil
- ✅ Datos de ejemplo para testing

### Próximas Funcionalidades

- 🔄 Integración con APIs reales
- 🔄 Persistencia local de datos
- 🔄 Sincronización offline/online
- 🔄 Escáner de códigos de barras
- 🔄 Reportes y exportación
- 🔄 Notificaciones push

## Desarrollo

### Agregar Nueva Funcionalidad

1. **Modelos**: Definir en `lib/models/`
2. **Servicios**: Implementar en `lib/services/`
3. **UI**: Crear pantalla en `lib/screens/`
4. **Navegación**: Configurar rutas en las pantallas

### Testing

```bash
# Ejecutar tests
flutter test

# Análisis de código
flutter analyze
```

## Contribución

1. Fork del proyecto
2. Crear branch feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push al branch (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo LICENSE para detalles.

## Soporte

Para soporte o preguntas sobre el proyecto, por favor crear un issue en el repositorio.