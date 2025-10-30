// lib/presentation/screens/settings/my_info_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 숫자 포맷팅을 위한 패키지
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/usecases/get_current_user.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GetCurrentUser Usecase를 DI 컨테이너에서 가져옵니다.
    final getCurrentUser = getIt<GetCurrentUser>();
    
    // StreamBuilder를 사용하여 실시간으로 사용자 정보를 가져옵니다.
    // 정보가 변경되면 화면이 자동으로 다시 그려집니다.
    return StreamBuilder<UserProfile?>(
      stream: getCurrentUser(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('내 정보'),
          ),
          body: Builder( // Scaffold의 context를 사용하기 위해 Builder 위젯 추가
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
              }

              final user = snapshot.data!;
              
              // 목표 달성률 계산 (0으로 나누는 오류 방지)
              final double progress = (user.targetGoal > 0) ? (user.totalEarnings / user.targetGoal) : 0.0;
              // 숫자 포맷을 원화(₩)로 변경
              final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildInfoTile(
                    icon: Icons.badge_outlined,
                    title: '이름',
                    content: user.name ?? '이름 없음',
                  ),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: '이메일',
                    content: user.email,
                  ),
                  const Divider(height: 32, thickness: 1),
                  
                  // [추가] 목표 달성률 섹션
                  Text(
                    '💰 목표 달성률',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // 달성 금액 및 목표 금액 표시
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(user.totalEarnings),
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        currencyFormat.format(user.targetGoal),
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 프로그레스 바
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0), // 값은 0과 1 사이로 제한
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),

                  // 퍼센트 표시
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  // TODO: 2차 목표 설정 및 달성률 표시 기능 추가 예정
                ],
              );
            },
          ),
        );
      },
    );
  }
  
  // 정보 타일을 만드는 헬퍼 위젯
  Widget _buildInfoTile({required IconData icon, required String title, required String content}) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(
        content,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}