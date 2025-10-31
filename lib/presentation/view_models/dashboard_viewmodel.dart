// lib/presentation/view_models/dashboard_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/usecases/get_all_cycles.dart';
import 'package:laour_cycle_manager/domain/usecases/get_current_user.dart';

// [복원] 오늘의 할 일을 나타내는 데이터 클래스
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
  UserProfile? _userProfile;
  List<Cycle> _cycles = [];
  List<DailyTask> _tasks = []; // [복원] 오늘의 할 일 목록
  StreamSubscription? _cycleSubscription;
  StreamSubscription? _userSubscription;

  // UI에서 상태를 읽기 위한 getter
  bool get isLoading => _isLoading;
  UserProfile? get userProfile => _userProfile;
  List<Cycle> get cycles => _cycles;
  List<DailyTask> get tasks => _tasks; // [복원] 오늘의 할 일 getter

  void _listenToDataChanges() {
    _userSubscription?.cancel();
    _userSubscription = _getCurrentUserUseCase().listen((UserProfile? user) {
      _userProfile = user;
      
      if (user != null) {
        _cycleSubscription?.cancel();
        _cycleSubscription = _getAllCyclesUseCase(user.uid).listen((cycleData) {
          _cycles = cycleData;
          _generateDailyTasks(cycleData); // [수정] 사이클 데이터를 받아 할 일 목록 생성
          _isLoading = false;
          notifyListeners();
        });
      } else {
        _userProfile = null;
        _cycles = [];
        _tasks = []; // [수정] 로그아웃 시 할 일 목록도 초기화
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // [복원] '오늘의 할 일' 목록을 생성하는 로직
  void _generateDailyTasks(List<Cycle> cycles) {
    final newTasks = <DailyTask>[];
    for (var cycle in cycles) {
      // TODO: 각 사이클 별로 할 일이 필요한지 판단하는 실제 로직 구현 필요
      newTasks.add(DailyTask(
        cycle: cycle,
        description: "'${cycle.name}' 어제 주문 결과 입력",
      ));
      newTasks.add(DailyTask(
        cycle: cycle,
        description: "'${cycle.name}' 오늘 주문 등록",
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