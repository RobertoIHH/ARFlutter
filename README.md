## Mienbros 

- **González Llamosas Noe Ramsés
- **Hernández Hernández Roberto Isaac.

# ARFlutter 📱🔍

Una aplicación Flutter que implementa funcionalidades de Realidad Aumentada (AR) para dispositivos móviles.

## 🚀 Características

- **Realidad Aumentada**: Implementación de AR usando Flutter
- **Multiplataforma**: Compatible con Android e iOS
- **Interfaz Intuitiva**: Diseño moderno y fácil de usar
- **Rendimiento Optimizado**: Experiencia fluida en dispositivos móviles

## 📋 Requisitos Previos

Antes de ejecutar este proyecto, asegúrate de tener instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión 3.0 o superior)
- [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
- Android Studio / VS Code con extensiones de Flutter
- Un dispositivo físico o emulador para pruebas

### Requisitos de Hardware

- **Android**: API nivel 24 (Android 7.0) o superior
- **iOS**: iOS 11.0 o superior
- Cámara trasera funcional
- Sensores de movimiento (acelerómetro, giroscopio)

## 🛠️ Instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/RobertoIHH/ARFlutter.git
   cd ARFlutter
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Configura los permisos**
   
   **Android**: Asegúrate de que `android/app/src/main/AndroidManifest.xml` incluya:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-feature android:name="android.hardware.camera" android:required="true" />
   <uses-feature android:name="android.hardware.camera.ar" android:required="true" />
   ```

   **iOS**: Agrega en `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Esta aplicación necesita acceso a la cámara para funciones de Realidad Aumentada</string>
   ```

4. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 📱 Uso

1. **Inicia la aplicación** en tu dispositivo móvil
2. **Permite los permisos** de cámara cuando se soliciten
3. **Apunta la cámara** hacia el entorno para activar las funciones AR
4. **Interactúa** con los elementos virtuales superpuestos

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── screens/                  # Pantallas de la aplicación
│   ├── ar_screen.dart       # Pantalla principal de AR
│   └── home_screen.dart     # Pantalla de inicio
├── widgets/                  # Widgets personalizados
│   ├── ar_widget.dart       # Widget de AR
│   └── common/              # Widgets comunes
├── models/                   # Modelos de datos
├── services/                 # Servicios y lógica de negocio
│   └── ar_service.dart      # Servicio de AR
└── utils/                    # Utilidades y helpers
    └── constants.dart       # Constantes de la aplicación
```

## 🔧 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  arcore_flutter_plugin: ^0.0.9  # Para funciones AR en Android
  arkit_plugin: ^0.11.0          # Para funciones AR en iOS
  camera: ^0.10.0                # Control de cámara
  permission_handler: ^10.2.0    # Gestión de permisos
```

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Para contribuir:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Guías para Contribuir

- Mantén el código limpio y bien comentado
- Sigue las convenciones de nomenclatura de Dart/Flutter
- Añade tests para nuevas funcionalidades
- Actualiza la documentación si es necesario

## 🐛 Problemas Conocidos

- **Android**: Algunos dispositivos pueden requerir calibración adicional
- **iOS**: La funcionalidad AR requiere iOS 11.0+ y dispositivos compatibles
- **Rendimiento**: El rendimiento puede variar según las especificaciones del dispositivo

## 📚 Recursos Adicionales

- [Documentación de Flutter](https://flutter.dev/docs)
- [ARCore para Android](https://developers.google.com/ar)
- [ARKit para iOS](https://developer.apple.com/arkit/)
- [Guía de AR en Flutter](https://flutter.dev/docs/development/platform-integration/ar)
