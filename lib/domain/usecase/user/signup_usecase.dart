import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/user_repository.dart';

/// Use case params for signup.
class SignupParams {
  final String fullName;
  final String email;
  final String password;

  SignupParams({
    required this.fullName,
    required this.email,
    required this.password,
  });
}

/// Use case that performs user registration (signup).
/// Returns a map with { success, message, userId }.
class SignupUseCase implements UseCase<Map<String, dynamic>, SignupParams> {
  final UserRepository _userRepository;

  SignupUseCase(this._userRepository);

  @override
  Future<Map<String, dynamic>> call({required SignupParams params}) async {
    return _userRepository.signup(params.fullName, params.email, params.password);
  }
}
