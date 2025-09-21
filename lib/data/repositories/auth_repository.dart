// data/repository/record_repository.dart
import 'package:dartz/dartz.dart';
import '../../domain/core/failures.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {

  Future<Either<Failure, void>> login(Map<String, String> data);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;


  AuthRepositoryImpl({  
    required this.authService,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> login(data) async {
    try {
      final tokens = await authService.login(data:data);
      return Right(tokens);

    } on AuthServiceException catch (e) {
      return Left(_handleServiceException(e));
    } catch (e) {
      return Left(const UnexpectedFailure(message: 'Unexpected error occurred'));
    }
  }




  Failure _handleServiceException(AuthServiceException e) {
    switch (e.statusCode) {
      case 401:
        return UnauthorizedFailure(message: e.message);
      case 403:
        return const UnauthorizedFailure(message: 'Access denied');
      case 404:
        return NotFoundFailure(message: e.message);
      case 422:
        return ValidationFailure(message: e.message);
      case 500:
        return ServerFailure(message: e.message, statusCode: e.statusCode);
      default:
        return ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }
}