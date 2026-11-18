# Práctica de Integración y Pruebas en Flutter

Aplicación móvil/web desarrollada en Flutter para la gestión de tareas personales, integrada con **Firebase Authentication** y **Cloud Firestore**, validada mediante pruebas funcionales manuales, pruebas unitarias y pruebas de widgets.

## Alcance del Proyecto
- **Autenticación:** Registro e inicio de sesión con correo y contraseña (Firebase Auth).
- **Base de Datos:** Operaciones CRUD en tiempo real sobre la colección `tasks` filtradas por usuario (Cloud Firestore).
- **Pruebas Automatizadas:** Pruebas unitarias de validadores/modelos y pruebas de widgets utilizando `FakeTaskRepository`.

## Instrucciones de Ejecución
1. Clonar el repositorio y cambiar a la rama de trabajo:
   ```bash
   git checkout semana16-integracion