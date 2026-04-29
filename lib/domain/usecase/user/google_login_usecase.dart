import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/user_repository.dart';

/// Use case that performs Google OAuth login.
/// Returns the JWT access token on success.
class GoogleLoginUseCase implements UseCase<String, void> {
  final UserRepository _userRepository;

  GoogleLoginUseCase(this._userRepository);

  @override
  Future<String> call({required void params}) async {
    return _userRepository.loginWithGoogle();
  }
}
