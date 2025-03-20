import 'package:fpdart/fpdart.dart';
import 'package:gzresturent/core/failure.dart';


typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
typedef StreamEither<T> = Stream<Either<Failure, T>>;