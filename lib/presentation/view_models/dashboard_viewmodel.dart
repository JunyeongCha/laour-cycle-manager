// lib/presentation/view_models/dashboard_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/order_guide.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/repositories/cycle_repository.dart';
import 'package:laour_cycle_manager/domain/usecases/get_all_cycles.dart';
import 'package:laour_cycle_manager/domain/usecases/get_current_user.dart';

// [수정] 할 일에 OrderGuide를 포함시켜 어떤 주문인지 알 수 있도록 함
class DailyTask {
  final Cycle cycle;
  final String description;
  final OrderGuide guide; // 오늘의 미션 정보
  final TaskType type;
  bool isCompleted;

  DailyTask({
    required this.cycle,
    required this.description,
    required this.guide,
    required this.type,
    this.isCompleted = false,
  });
}

enum TaskType { enterResult, placeOrder }

@injectable
class DashboardViewModel extends ChangeNotifier {
  final GetAllCycles _getAllCyclesUseCase;
  final GetCurrentUser _getCurrentUserUseCase;
  final CycleRepository _cycleRepository;

  DashboardViewModel(
    this._getAllCyclesUseCase,
    this._getCurrentUserUseCase,
    this._cycleRepository,
  ) {
    _listenToDataChanges();
  }

  bool _isLoading = true;
  UserProfile? _userProfile;
  List<Cycle> _cycles = [];
  List<DailyTask> _tasks = [];
  StreamSubscription? _cycleSubscription;
  StreamSubscription? _userSubscription;

  bool get isLoading => _isLoading;
  UserProfile? get userProfile => _userProfile;
  List<Cycle> get cycles => _cycles;
  List<DailyTask> get tasks => _tasks;

  void _listenToDataChanges() {
    _userSubscription?.cancel();
    _userSubscription = _getCurrentUserUseCase().listen((UserProfile? user) {
      _userProfile = user;
      
      if (user != null) {
        _cycleSubscription?.cancel();
        _cycleSubscription = _getAllCyclesUseCase(user.uid).listen((cycleData) async {
          _cycles = cycleData;
          await _generateDailyTasks(cycleData);
          _isLoading = false;
          notifyListeners();
        });
      } else {
        _userProfile = null;
        _cycles = [];
        _tasks = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // [핵심 수정] '오늘의 할 일' 목록 생성 시 OrderGuide를 함께 생성
  Future<void> _generateDailyTasks(List<Cycle> cycles) async {
    final newTasks = <DailyTask>[];
    final today = DateUtils.dateOnly(DateTime.now());

    for (var cycle in cycles) {
      if (cycle.status != CycleStatus.inProgress) continue;

      // TODO: 실제 주가 API 연동 필요
      const double lastClosePrice = 54.0; 

      final tradeRecords = await _cycleRepository.getTradeRecords(cycle.id);
      final orderGuide = _determineOrderGuide(cycle, lastClosePrice, tradeRecords);

      bool needsResultEntry = false;
      if (tradeRecords.isNotEmpty) {
        final lastTradeDate = DateUtils.dateOnly(tradeRecords.last.timestamp);
        if (lastTradeDate.isBefore(today)) {
          needsResultEntry = true;
        }
      }

      if (needsResultEntry) {
        newTasks.add(DailyTask(
          cycle: cycle,
          description: "'${cycle.name}' 어제 주문 결과 입력",
          guide: orderGuide, // 계산된 OrderGuide 전달
          type: TaskType.enterResult,
        ));
      }
      
      newTasks.add(DailyTask(
        cycle: cycle,
        description: "'${cycle.name}' 오늘 주문 등록",
        guide: orderGuide,
        type: TaskType.placeOrder,
      ));
    }
    _tasks = newTasks;
  }

  // OrderGuide를 결정하는 로직 (CycleDetailViewModel에서 가져와 단순화)
  OrderGuide _determineOrderGuide(Cycle cycle, double lastClosePrice, List<dynamic> tradeRecords) {
    // 40회 매수가 끝났는지 확인
    final plannedTradeCount = tradeRecords.where((r) => r.isPlanned).length;
    if (plannedTradeCount >= cycle.divisionCount) {
        return OrderGuide(
            action: OrderActionType.addFunds,
            ticker: cycle.ticker,
            message: '모든 분할 매수가 완료되었습니다.',
        );
    }

    final double quantityToBuy = cycle.amountPerDivision / lastClosePrice;
    
    return OrderGuide(
      action: OrderActionType.locBuy,
      ticker: cycle.ticker,
      message: '지정가(LOC) 매수 주문을 넣으세요.',
      price: lastClosePrice,
      quantity: quantityToBuy,
    );
  }

  void toggleTaskCompletion(DailyTask task) {
      task.isCompleted = !task.isCompleted;
      notifyListeners();
  }

  @override
  void dispose() {
    _cycleSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}