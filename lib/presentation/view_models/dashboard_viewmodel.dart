// lib/presentation/view_models/dashboard_viewmodel.dart

import 'dart:async';
import 'package.flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/usecases/get_all_cycles.dart';
import 'package:laour_cycle_manager/domain/usecases/get_current_user.dart';

// 오늘의 할 일을 나타내는 간단한 데이터 클래스입니다.
class DailyTask {
  final Cycle cycle;
  final String description;
  final bool isCompleted;

  DailyTask({
    required this.cycle,
    required this.description,
    this.isCompleted = false,
  });
}

@injectable
class DashboardViewModel extends ChangeNotifier {
  final GetAllCycles _getAllCyclesUseCase;
  final GetCurrentUser _getCurrentUserUseCase;

  DashboardViewModel(this._getAllCyclesUseCase, this._getCurrentUserUseCase) {
    _listenToDataChanges();
  }

  // 화면 상태 변수들
  bool _isLoading = true;
  String? _userName;
  List<DailyTask> _tasks = [];
  StreamSubscription? _cycleSubscription;
  StreamSubscription? _userSubscription;

  // UI에서 상태를 읽기 위한 getter
  bool get isLoading => _isLoading;
  String? get userName => _userName;
  List<DailyTask> get tasks => _tasks;

  // 사용자 및 사이클 데이터의 변경을 감지하는 리스너 설정
  void _listenToDataChanges() {
    _userSubscription = _getCurrentUserUseCase().listen((UserProfile? user) {
      if (user != null) {
        _userName = user.name; // 사용자 이름 설정
        
        _cycleSubscription?.cancel();
        _cycleSubscription = _getAllCyclesUseCase(user.uid).listen((cycles) {
          // 사이클 목록이 변경될 때마다 '오늘의 할 일'을 다시 계산합니다.
          _generateDailyTasks(cycles);
          _isLoading = false;
          notifyListeners();
        });
      } else {
        // 로그아웃 시 데이터 초기화
        _userName = null;
        _tasks = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // '오늘의 할 일' 목록을 생성하는 핵심 로직
  void _generateDailyTasks(List<Cycle> cycles) {
    final newTasks = <DailyTask>[];
    for (var cycle in cycles) {
      // TODO: 여기에 각 사이클 별로 '어제 결과 입력'이 필요한지,
      // '오늘 주문 등록'이 필요한지 판단하는 로직을 구현해야 합니다.
      // 지금은 예시로 모든 사이클에 대해 두 가지 할 일을 모두 추가합니다.
      
      newTasks.add(DailyTask(
        cycle: cycle,
        description: "'${cycle.name}' 어제 주문 결과 입력하기",
      ));
      newTasks.add(DailyTask(
        cycle: cycle,
        description: "'${cycle.name}' 오늘 주문 등록하기",
      ));
    }
    _tasks = newTasks;
  }

  @override
  void dispose() {
    _cycleSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}