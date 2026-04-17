import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/user_repository.dart';

class SignupUseCase implements UseCase<dynamic, SignupParams> {
  final UserRepository _userRepository;

  SignupUseCase(this._userRepository);

  @override
  Future<dynamic> call({required SignupParams params}) {
    return _userRepository.signup(
      params.fullName,
      params.email,
      params.password,
    );
  }
}

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
