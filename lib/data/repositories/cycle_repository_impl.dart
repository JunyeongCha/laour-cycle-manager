// lib/data/repositories/cycle_repository_impl.dart

import 'package:injectable/injectable.dart'; // 1. Injectable 패키지 임포트
import 'package:laour_cycle_manager/data/datasources/remote/cycle_remote_datasource.dart';
import 'package:laour_cycle_manager/data/models/cycle_model.dart';
import 'package:laour_cycle_manager/data/models/trade_record_model.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/trade_record.dart';
import 'package:laour_cycle_manager/domain/repositories/cycle_repository.dart';

// 2. @LazySingleton 스티커를 붙여 CycleRepository 타입으로 등록되도록 지정합니다.
@LazySingleton(as: CycleRepository)
class CycleRepositoryImpl implements CycleRepository {
  final CycleRemoteDataSource remoteDataSource;

  CycleRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createNewCycle(Cycle cycle) {
    final cycleModel = CycleModel.fromEntity(cycle);
    return remoteDataSource.createNewCycle(cycleModel);
  }

  @override
  Stream<List<Cycle>> getAllCycles(String userId) {
    final cycleModelStream = remoteDataSource.getAllCycles(userId);
    return cycleModelStream.map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<void> addTradeRecord(TradeRecord tradeRecord) {
    final tradeRecordModel = TradeRecordModel.fromEntity(tradeRecord);
    return remoteDataSource.addTradeRecord(tradeRecordModel);
  }

  @override
  Future<List<TradeRecord>> getTradeRecords(String cycleId) async {
    final tradeRecordModels = await remoteDataSource.getTradeRecords(cycleId);
    return tradeRecordModels.map((model) => model.toEntity()).toList();
  }
}