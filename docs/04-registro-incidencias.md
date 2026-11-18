# 4. Registro y Seguimiento de Incidencias

| ID | Descripción | Severidad | Prioridad | Origen | Estado |
| :--- | :--- | :---: | :---: | :--- | :---: |
| **INC-001** | Error de compilación en análisis estático: `test/widget_test.dart` referencia la clase inexistente `MyApp`. | Alta | Alta | Pruebas automatizadas (`flutter analyze`) | Cerrada (Corregida) |
| **INC-002** | Fallo al lanzar navegador Chrome por bloqueo de puerto de depuración remota (`--remote-debugging-port`) en entorno corporativo. | Media | Alta | Entorno de ejecución (`flutter run -d chrome`) | Cerrada (Resuelta) |
| **INC-003** | El campo de título de tarea permitía enviar cadenas compuestas únicamente por espacios en blanco si no se aplicaba `.trim()`. | Baja | Media | Validación de formularios (`HomeScreen`) | Cerrada (Corregida) |

---

### Detalle Técnico y Método de 5 Pasos (INC-001 — Mayor Prioridad)

1. **Reproducir:** Al ejecutar `flutter analyze` tras integrar `TaskApp` en `lib/main.dart`, la consola reportó `1 issue found` en `test/widget_test.dart:16:35`.
2. **Leer:** Mensaje de error: `The name 'MyApp' isn't a class. Try correcting the name to match an existing class - creation_with_non_type`.
3. **Hipótesis:** El archivo de prueba por defecto generado por `flutter create` seguía apuntando al widget de ejemplo `MyApp`, el cual fue reemplazado por `TaskApp` y las pruebas dedicadas en `test/unit/` y `test/widget/`.
4. **Comprobar:** Se inspeccionó `test/widget_test.dart` confirmando que no probaba ningún flujo real de la aplicación actual.
5. **Corregir y proteger:** Se eliminó el archivo obsoleto `test/widget_test.dart`, se implementaron `test/unit/validators_test.dart` y `test/widget/home_screen_test.dart` con `FakeTaskRepository`, y se ejecutó prueba de regresión con `flutter analyze` (`No issues found!`) y `flutter test` (`All tests passed!`).
   - **Evidencia antes/después:** `evidencias/pruebas-y-analisis/01-analyze-correccion-inc001.png`
   - **Commit de corrección:** `fix: INC-001 eliminar widget_test obsoleto e integrar pruebas unitarias y de widget`