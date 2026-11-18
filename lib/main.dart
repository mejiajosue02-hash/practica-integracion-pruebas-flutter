import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TaskApp());
}

// ==========================================
// 1. VALIDADORES PUROS (Para Pruebas Unitarias)
// ==========================================
class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.trim().length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  static String? validateTaskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El título de la tarea no puede estar vacío';
    }
    return null;
  }
}

// ==========================================
// 2. MODELO Y REPOSITORIOS (Real + Fake)
// ==========================================
class TaskItem {
  final String id;
  final String title;
  final bool completed;
  final String userId;

  TaskItem({
    required this.id,
    required this.title,
    required this.completed,
    required this.userId,
  });

  factory TaskItem.fromMap(String id, Map<String, dynamic> data) {
    return TaskItem(
      id: id,
      title: data['title'] ?? '',
      completed: data['completed'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
      'userId': userId,
    };
  }
}

abstract class TaskRepository {
  Stream<List<TaskItem>> getTasks(String userId);
  Future<void> addTask(String title, String userId);
  Future<void> toggleTask(String id, bool currentStatus);
  Future<void> deleteTask(String id);
}

class FirestoreTaskRepository implements TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<List<TaskItem>> getTasks(String userId) {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TaskItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> addTask(String title, String userId) async {
    await _db.collection('tasks').add({
      'title': title.trim(),
      'completed': false,
      'userId': userId,
    });
  }

  @override
  Future<void> toggleTask(String id, bool currentStatus) async {
    await _db.collection('tasks').doc(id).update({'completed': !currentStatus});
  }

  @override
  Future<void> deleteTask(String id) async {
    await _db.collection('tasks').doc(id).delete();
  }
}

// ==========================================
// 3. APLICACIÓN Y PANTALLAS
// ==========================================
class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Tareas UTEC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(
              userId: snapshot.data!.uid,
              userEmail: snapshot.data!.email ?? '',
              repository: FirestoreTaskRepository(),
            );
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _errorMessage;

  String _translateAuthError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Credenciales incorrectas. Verifica tu correo y contraseña.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'network-request-failed':
        return 'Error de red. Revisa tu conexión a internet.';
      default:
        return 'Error de autenticación ($code).';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _translateAuthError(e.code));
    } catch (e) {
      setState(() => _errorMessage = 'Ocurrió un error inesperado.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Iniciar Sesión' : 'Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                key: const Key('emailField'),
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
                validator: AppValidators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('passwordField'),
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                validator: AppValidators.validatePassword,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      key: const Key('submitAuthButton'),
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Ingresar' : 'Registrarse'),
                    ),
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  _errorMessage = null;
                }),
                child: Text(_isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final TaskRepository repository;
  final VoidCallback? onLogoutOverride;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.repository,
    this.onLogoutOverride,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _addTask() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.repository.addTask(_taskCtrl.text, widget.userId);
    _taskCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            icon: const Icon(Icons.logout),
            tooltip: 'Salir',
            onPressed: widget.onLogoutOverride ?? () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('taskInputField'),
                      controller: _taskCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Nueva tarea...',
                        border: OutlineInputBorder(),
                      ),
                      validator: AppValidators.validateTaskTitle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    key: const Key('addTaskButton'),
                    onPressed: _addTask,
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TaskItem>>(
              stream: widget.repository.getTasks(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar las tareas.'));
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return const Center(child: Text('No hay tareas registradas aún.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      leading: Checkbox(
                        value: task.completed,
                        onChanged: (_) => widget.repository.toggleTask(task.id, task.completed),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => widget.repository.deleteTask(task.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}