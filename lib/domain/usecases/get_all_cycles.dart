// lib/domain/usecases/get_all_cycles.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/repositories/cycle_repository.dart';

@lazySingleton
class GetAllCycles {
  final CycleRepository repository;

  GetAllCycles(this.repository);

  // 이 기능은 사용자 ID를 받아, 해당 사용자의 모든 사이클 목록을
  // 실시간 스트림(Stream)으로 반환합니다. 데이터베이스에 변경이 생기면
  // 화면이 자동으로 업데이트됩니다.
  Stream<List<Cycle>> call(String userId) {
    return repository.getAllCycles(userId);
  }
}