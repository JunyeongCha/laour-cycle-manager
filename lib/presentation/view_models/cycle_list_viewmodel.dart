// lib/presentation/view_models/cycle_list_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/usecases/get_all_cycles.dart';
import 'package:laour_cycle_manager/domain/usecases/get_current_user.dart';

@injectable
class CycleListViewModel extends ChangeNotifier {
  final GetAllCycles _getAllCyclesUseCase;
  final GetCurrentUser _getCurrentUserUseCase;

  // Constructor to inject the required Usecases.
  CycleListViewModel(this._getAllCyclesUseCase, this._getCurrentUserUseCase) {
    _listenToCycles();
  }

  // State variables
  bool _isLoading = true;
  List<Cycle> _cycles = [];
  StreamSubscription? _cycleSubscription;
  StreamSubscription? _userSubscription;

  // Getters for the UI to read the state.
  bool get isLoading => _isLoading;
  List<Cycle> get cycles => _cycles;

  // This private method sets up the listeners.
  void _listenToCycles() {
    // First, listen for the current user.
    _userSubscription = _getCurrentUserUseCase().listen((UserProfile? user) {
      // If a user is logged in,
      if (user != null) {
        // Cancel any previous cycle subscription to avoid memory leaks.
        _cycleSubscription?.cancel();
        // Start listening to the stream of cycles for this user.
        _cycleSubscription = _getAllCyclesUseCase(user.uid).listen((cycleData) {
          _cycles = cycleData;
          _isLoading = false;
          notifyListeners(); // Update the UI with the new list of cycles.
        });
      } else {
        // If the user logs out, clear the data.
        _cycles = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // This is called when the ViewModel is no longer needed to prevent memory leaks.
  @override
  void dispose() {
    _cycleSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}