// lib/domain/repositories/cycle_repository.dart

import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/trade_record.dart';

// 사이클 및 거래 기록 관련 기능의 '설계도' 역할을 하는 추상 클래스입니다.
abstract class CycleRepository {
  
  // 새로운 사이클을 생성(저장)하는 기능
  Future<void> createNewCycle(Cycle cycle);
  
  Future<void> updateCycle(Cycle cycle);

  // 특정 사용자의 모든 사이클 목록을 실시간으로 가져오는 기능
  Stream<List<Cycle>> getAllCycles(String userId);

  // 특정 사이클에 속한 모든 거래 기록을 가져오는 기능
  Future<List<TradeRecord>> getTradeRecords(String cycleId);

  // 새로운 거래 기록을 추가(저장)하는 기능
  Future<void> addTradeRecord(TradeRecord tradeRecord);
  
  // TODO: 앞으로 만들 사이클 수정, 삭제 등의 기능 설계도를 여기에 추가할 수 있습니다.
}