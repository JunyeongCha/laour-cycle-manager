// lib/data/datasources/remote/cycle_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart'; // [핵심 수정] 빠져있던 '스티커 설명서' 임포트
import 'package:laour_cycle_manager/data/models/cycle_model.dart';
import 'package:laour_cycle_manager/data/models/trade_record_model.dart';

@lazySingleton
class CycleRemoteDataSource {
  final FirebaseFirestore _firestore;

  static const String _cyclesCollection = 'cycles';
  static const String _tradeRecordsSubcollection = 'trade_records';

  CycleRemoteDataSource(this._firestore);

  Future<void> createNewCycle(CycleModel cycle) async {
    try {
      await _firestore.collection(_cyclesCollection).add(cycle.toJson());
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> updateCycle(CycleModel cycle) async {
    try {
      await _firestore.collection(_cyclesCollection).doc(cycle.id).update(cycle.toJson());
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<List<CycleModel>> getAllCycles(String userId) {
    return _firestore
        .collection(_cyclesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CycleModel.fromSnapshot(doc)).toList();
    });
  }

  Future<List<TradeRecordModel>> getTradeRecords(String cycleId) async {
    try {
      final snapshot = await _firestore
          .collection(_cyclesCollection)
          .doc(cycleId)
          .collection(_tradeRecordsSubcollection)
          .orderBy('timestamp', descending: false)
          .get();
      
      return snapshot.docs.map((doc) => TradeRecordModel.fromSnapshot(doc)).toList();
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> addTradeRecord(TradeRecordModel tradeRecord) async {
    try {
      await _firestore
          .collection(_cyclesCollection)
          .doc(tradeRecord.cycleId)
          .collection(_tradeRecordsSubcollection)
          .add(tradeRecord.toJson());
    } on FirebaseException {
      rethrow;
    }
  }
}