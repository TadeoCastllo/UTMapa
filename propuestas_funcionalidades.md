# 📝 Descripción de Cambios para Proyecto Final: UTMapa

Basado en las funcionalidades seleccionadas para enriquecer la experiencia de los estudiantes de nuevo ingreso y mejorar la accesibilidad de la aplicación, a continuación se detallan los tres grandes cambios que se implementarán en el proyecto final:

## 1. 📷 Escáner de Códigos QR Físicos
**Objetivo:** Fomentar la exploración física del campus universitario. En lugar de tener acceso libre a toda la información desde el inicio, el estudiante deberá interactuar con su entorno.

**Descripción de la funcionalidad:** 
Se colocarán códigos QR (reales o simulados) en los distintos puntos de interés (Edificios, Biblioteca, Canchas). Al usar el escáner dentro de la aplicación, el estudiante "desbloqueará" la galería de imágenes, la información detallada del lugar y el minijuego asociado a esa zona.

**Cambios técnicos:**
* Agregar la dependencia `mobile_scanner` (o `qr_code_scanner`) en `pubspec.yaml`.
* Añadir permisos de cámara en `android/app/src/main/AndroidManifest.xml` y `ios/Runner/Info.plist`.
* Crear una pantalla de `LectorQR` a la que se pueda acceder desde un botón flotante (FAB) en la pantalla del mapa principal.
* Implementar lógica para validar el contenido del QR y redirigir a la pantalla de detalle correspondiente (`POI`).

---

## 2. 🗺️ Rutas Guiadas (Tours)
**Objetivo:** Evitar que el usuario se pierda buscando lugares específicos de uso recurrente y facilitar su orientación.

**Descripción de la funcionalidad:** 
El mapa no solo mostrará pines aislados, sino que ofrecerá "Tours" predefinidos que trazarán un camino visual sobre las calles de la universidad. Ejemplos de rutas:
* **Ruta de Trámites:** Servicios Escolares -> Caja -> Biblioteca.
* **Ruta de Tecnologías:** Laboratorios -> Aulas de Computación -> Auditorio.

**Cambios técnicos:**
* Utilizar el widget `PolylineLayer` dentro de `flutter_map` para dibujar las líneas sobre el mapa.
* Definir listas de `LatLng` (coordenadas geográficas) que representen las calles internas del campus.
* Añadir un menú (por ejemplo, un `BottomSheet` o un menú lateral) donde el estudiante pueda seleccionar la ruta que desea ver iluminada en el mapa.

---

## 3. 🗣️ Accesibilidad: Lectura de Textos (Text-To-Speech - TTS)
**Objetivo:** Hacer la aplicación más inclusiva y cómoda. Permite que el usuario escuche la descripción de los lugares de la universidad mientras camina o si tiene dificultades visuales.

**Descripción de la funcionalidad:** 
En la pantalla de detalle de cada punto de interés (POI), se añadirá un botón de "Escuchar". Al presionarlo, el dispositivo leerá en voz alta la información, historia y horarios del lugar, actuando como un audioguía del campus.

**Cambios técnicos:**
* Agregar la dependencia `flutter_tts` en `pubspec.yaml`.
* Modificar la pantalla de Detalles del Lugar (POI) agregando botones de control (Reproducir / Pausar / Detener).
* Configurar la instancia de TTS para usar idioma español (`es-MX` o `es-ES`).
* Asegurarse de manejar el ciclo de vida del widget para detener el audio si el usuario sale de la pantalla de detalle.
