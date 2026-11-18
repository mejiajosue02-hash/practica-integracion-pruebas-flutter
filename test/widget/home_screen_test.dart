import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';

class FakeTaskRepository implements TaskRepository {
  final List<TaskItem> _tasks = [];
  final _controller = StreamController<List<TaskItem>>.broadcast();

  @override
  Stream<List<TaskItem>> getTasks(String userId) async* {
    yield List.from(_tasks);
    yield* _controller.stream;
  }

  @override
  Future<void> addTask(String title, String userId) async {
    _tasks.add(TaskItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      completed: false,
      userId: userId,
    ));
    _controller.add(List.from(_tasks));
  }

  @override
  Future<void> toggleTask(String id, bool currentStatus) async {}

  @override
  Future<void> deleteTask(String id) async {}
}

void main() {
  testWidgets('HomeScreen muestra estado vacío, valida entrada vacía y agrega tarea', (WidgetTester tester) async {
    final fakeRepo = FakeTaskRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          userId: 'test-user',
          userEmail: 'test@utec.edu.sv',
          repository: fakeRepo,
          onLogoutOverride: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verifica estado inicial vacío
    expect(find.text('No hay tareas registradas aún.'), findsOneWidget);

    // 2. Intenta agregar tarea vacía (caso negativo)
    await tester.tap(find.byKey(const Key('addTaskButton')));
    await tester.pump();
    expect(find.text('El título de la tarea no puede estar vacío'), findsOneWidget);

    // 3. Escribe una tarea válida y la agrega
    await tester.enterText(find.byKey(const Key('taskInputField')), 'Estudiar para parcial');
    await tester.tap(find.byKey(const Key('addTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Estudiar para parcial'), findsOneWidget);
  });
}