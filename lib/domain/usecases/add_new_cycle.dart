// lib/domain/usecases/add_new_cycle.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/repositories/cycle_repository.dart';

@lazySingleton
class AddNewCycle {
  final CycleRepository repository;

  AddNewCycle(this.repository);

  // Cycle 객체를 파라미터로 받아 repository에 저장을 위임합니다.
  Future<void> call(Cycle cycle) {
    return repository.createNewCycle(cycle);
  }
}