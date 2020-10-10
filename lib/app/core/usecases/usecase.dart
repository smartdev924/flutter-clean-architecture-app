import 'package:dartz/dartz.dart';
import '../models/failure.dart';

// ignore: one_member_abstracts
abstract class UseCase<Type> {
  Future<Either<Failure, Type>> call();
}
