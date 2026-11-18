# 2. Mapa de Flujos Críticos

1. **FC-01 — Registro e inicio de sesión:** El usuario puede crear una cuenta nueva o iniciar sesión con su correo electrónico y contraseña, recibiendo retroalimentación clara ante campos vacíos o credenciales inválidas.
2. **FC-02 — Creación y almacenamiento de tareas:** El usuario autenticado puede ingresar el título de una nueva tarea, validando que no esté vacía, y guardarla en Cloud Firestore vinculada a su identificador único (`userId`).
3. **FC-03 — Consulta en tiempo real y actualización de estado:** El usuario puede visualizar su listado actualizado de tareas desde Firestore y marcar o desmarcar cada tarea como completada mediante un checkbox.
4. **FC-04 — Eliminación de registros y cierre de sesión:** El usuario puede eliminar tareas existentes de la base de datos y cerrar su sesión de forma segura regresando a la pantalla de acceso.