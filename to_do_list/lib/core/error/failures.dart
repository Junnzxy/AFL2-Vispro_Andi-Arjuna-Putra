import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Gagal mengakses data penyimpanan.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validasi tugas gagal.']);
}

