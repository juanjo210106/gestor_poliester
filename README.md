# Gestor Poliéster - Depofibra 🚀

**Gestor Poliéster** es una aplicación móvil corporativa desarrollada con **Flutter** y **Firebase** para la gestión integral de la empresa **Depofibra**. La aplicación permite administrar de manera eficiente el catálogo de productos (depósitos y piscinas), la cartera de clientes y el registro de pedidos en tiempo real, integrando servicios avanzados de autenticación y conectividad externa.

## 📋 Checklist de Requisitos Cumplidos

### Funcionalidades Base (6 Puntos)
* **Tecnología:** Proyecto desarrollado íntegramente con el framework **Flutter**.
* **Persistencia:** Conexión reactiva y persistente con **Firebase Firestore**.
* **Base de Datos:** Implementación de **3 colecciones** dinámicas: `clientes`, `productos` y `pedidos`.
* **Operaciones CRUD:** * **Añadir:** Formularios de creación validados para cada entidad.
    * **Eliminar:** Borrado de documentos con actualización automática de la interfaz.
    * **Consultar:** Visualización de datos en tiempo real mediante el uso de `Streams` y `StreamBuilder`.
* **Pantallas Independientes:** Organización modular con 3 pantallas principales (una por colección) implementadas como Widgets independientes.
* **Listado, Filtrado y Ordenación:** * Listado dinámico de todos los registros.
    * Filtrado de productos por categoría (Depósitos/Piscinas).
    * Ordenación lógica de productos por precio.
* **Validación de Formularios:** Implementación de `GlobalKey<FormState>` y validadores de campo para prevenir errores en la entrada de datos.

### Funcionalidades Avanzadas (4 Puntos)
* **Login con Google:** Autenticación social nativa integrada mediante Firebase Auth y Google Sign-In.
* **Modificación de Colecciones:** Lógica de actualización (Update) completamente operativa en todas las entidades.
* **Webservice (Lectura):** Consumo de API REST externa (GET) para mostrar un "Consejo del Día" dinámico en el Dashboard principal.
* **Webservice (Escritura):** Sincronización de datos (POST) enviando pedidos locales a un servidor externo simulado (`jsonplaceholder`) con confirmación de estado HTTP 201.

---

## 🛠️ Stack Tecnológico

* **Lenguaje:** Dart
* **Framework:** Flutter
* **Base de Datos:** Firebase Firestore (NoSQL)
* **Autenticación:** Firebase Authentication (Google Sign-In)
* **Networking:** Librería `http` para integración de Webservices.
* **Estilo:** Material Design con personalización de identidad corporativa.

---

## 📁 Estructura del Proyecto

El código fuente sigue una arquitectura limpia y separada por responsabilidades:

* `lib/models/`: Clases de datos (`cliente_model.dart`, `producto_model.dart`, `pedido_model.dart`).
* `lib/screens/`: Interfaz de usuario (`login_screen.dart`, `home_screen.dart`, y pantallas de gestión).
* `lib/services/`: Capa de lógica y comunicación externa:
    * `firestore_service.dart`: Gestión de operaciones con Firebase.
    * `auth_service.dart`: Manejo de autenticación y sesiones.
    * `api_service.dart`: Conectividad con Webservices REST.

---

## 🚀 Instalación y Ejecución

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/tu-usuario/gestor_poliester.git](https://github.com/tu-usuario/gestor_poliester.git)
    ```
2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```
3.  **Configuración de Firebase:**
    * Colocar el archivo `google-services.json` en la ruta `android/app/`.
4.  **Ejecutar la aplicación:**
    ```bash
    flutter run
    ```

---

## 👤 Autor
* **Alumno:** Juan José Gamero López
* **Asignatura:** Acceso a Datos.
* **Empresa:** Depofibra.
