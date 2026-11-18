import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';

void main() {
  group('Pruebas Unitarias - Validadores y Modelos', () {
    test('Validador de correo rechaza vacío y formato inválido', () {
      expect(AppValidators.validateEmail(''), 'El correo es obligatorio');
      expect(AppValidators.validateEmail('correo_sin_arroba'), 'Ingrese un correo válido');
      expect(AppValidators.validateEmail('carlos@utec.edu.sv'), null);
    });

    test('Validador de contraseña exige mínimo 6 caracteres', () {
      expect(AppValidators.validatePassword(''), 'La contraseña es obligatoria');
      expect(AppValidators.validatePassword('123'), 'Mínimo 6 caracteres');
      expect(AppValidators.validatePassword('123456'), null);
    });

    test('Mapeo de modelo TaskItem desde y hacia Map funciona correctamente', () {
      final task = TaskItem.fromMap('doc1', {
        'title': 'Entregar práctica',
        'completed': true,
        'userId': 'user123',
      });
      expect(task.id, 'doc1');
      expect(task.title, 'Entregar práctica');
      expect(task.completed, true);
      expect(task.toMap()['userId'], 'user123');
    });
  });
}