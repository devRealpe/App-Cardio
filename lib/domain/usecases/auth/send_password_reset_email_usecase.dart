import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase({required this.repository});

  Future<Either<Failure, void>> call({required String email}) async {
    return await repository.sendPasswordResetEmail(email: email);
  }
}
