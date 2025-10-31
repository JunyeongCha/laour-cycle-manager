// lib/domain/entities/cycle.dart

import 'package:equatable/equatable.dart';

enum CycleStatus {
  inProgress,
  completed,
  paused,
  stopped,
}

class Cycle extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String ticker;
  
  final double totalInvestmentAmount;
  final int divisionCount;
  final double targetProfitPercentage;
  
  final CycleStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Cycle({
    required this.id,
    required this.userId,
    required this.name,
    required this.ticker,
    required this.totalInvestmentAmount,
    required this.divisionCount,
    required this.targetProfitPercentage,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  double get amountPerDivision => totalInvestmentAmount / divisionCount;

  // [추가된 기능] 객체를 복사하면서 특정 값만 변경하는 메소드
  Cycle copyWith({
    String? id,
    String? userId,
    String? name,
    String? ticker,
    double? totalInvestmentAmount,
    int? divisionCount,
    double? targetProfitPercentage,
    CycleStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Cycle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      ticker: ticker ?? this.ticker,
      totalInvestmentAmount: totalInvestmentAmount ?? this.totalInvestmentAmount,
      divisionCount: divisionCount ?? this.divisionCount,
      targetProfitPercentage: targetProfitPercentage ?? this.targetProfitPercentage,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        ticker,
        totalInvestmentAmount,
        divisionCount,
        targetProfitPercentage,
        status,
        createdAt,
        completedAt,
      ];
}