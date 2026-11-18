# 1. Declaración de Alcance

| Módulo / Servicio | ¿Aplica? | Observación |
| :--- | :---: | :--- |
| **Autenticación (Firebase Auth)** | Sí | Registro, inicio de sesión, manejo de errores (`invalid-credential`) y cierre de sesión con correo y contraseña. |
| **Base de datos (Firestore)** | Sí | Persistencia en tiempo real de la colección `tasks` (Crear, Leer, Actualizar estado y Eliminar registros por `userId`). |
| **Almacenamiento (Storage)** | No | No ejecutado: fuera del alcance funcional de la aplicación de gestión de tareas de texto. |
| **Notificaciones push (FCM)** | No | No ejecutado: el entorno de pruebas se ejecutó en navegador web corporativo sin dispositivo móvil físico ni configuración de Service Worker FCM. |
| **API REST externa** | No | No ejecutado: toda la persistencia se gestiona directamente mediante el SDK oficial de Cloud Firestore. |
| **Otros (Analytics, Crashlytics...)** | No | No ejecutado: servicios deshabilitados para priorizar la integración central de Auth y Firestore. |
