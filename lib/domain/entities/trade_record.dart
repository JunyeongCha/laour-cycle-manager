// lib/domain/entities/trade_record.dart

import 'package.equatable/equatable.dart';

// 거래의 종류를 명확하게 구분하기 위한 열거형(Enum)입니다.
enum TradeType {
  locBuy,      // 계획된 지정가(LOC) 매수
  manualBuy,   // 수동 추가 매수
  profitSell,  // 목표 수익률 달성으로 인한 전량 매도
  manualSell,  // 수동 임의 매도
}

class TradeRecord extends Equatable {
  final String id; // 거래의 고유 ID
  final String cycleId; // 이 거래가 속한 사이클의 ID

  final TradeType type; // 거래 종류
  final double price; // 주당 체결 가격
  final double quantity; // 체결 수량
  final DateTime timestamp; // 거래 체결 시각

  // 이 거래가 N/40회 카운트에 포함되는 '계획된' 거래인지 여부.
  // 수동 거래 관리를 위한 핵심 로직입니다. [cite: 74]
  final bool isPlanned;

  const TradeRecord({
    required this.id,
    required this.cycleId,
    required this.type,
    required this.price,
    required this.quantity,
    required this.timestamp,
    required this.isPlanned,
  });

  // 총 거래 금액을 계산하는 편의용 getter
  double get totalAmount => price * quantity;

  @override
  List<Object?> get props => [
        id,
        cycleId,
        type,
        price,
        quantity,
        timestamp,
        isPlanned,
      ];
}