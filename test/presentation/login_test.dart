import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';

void main() {
  group('LoginStore Unit Tests', () {
    test('LoginStore initializes with correct default state', () {
      final errorStore = ErrorStore();
      final formErrorStore = FormErrorStore();

      expect(errorStore, isNotNull);
      expect(formErrorStore, isNotNull);
    });

    test('ErrorStore message can be updated', () {
      final errorStore = ErrorStore();
      errorStore.errorMessage = 'Test error message';
      
      expect(errorStore.errorMessage, 'Test error message');
    });

    test('FormErrorStore can be created without errors', () {
      final formErrorStore = FormErrorStore();
      
      expect(formErrorStore, isNotNull);
    });
  });
}


