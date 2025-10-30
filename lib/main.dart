// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/presentation/view_models/theme_provider.dart';
import 'package:laour_cycle_manager/routes/app_router.dart'; // [추가] 라우터 파일 임포트
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // MaterialApp을 MaterialApp.router로 변경하여 GoRouter를 사용합니다.
          return MaterialApp.router(
            // [추가] 글자 크기 조절을 위한 MediaQuery 재정의
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(themeProvider.fontScale),
                ),
                child: child!,
              );
            },
            
            // [수정] routerConfig 프로퍼티에 우리가 만든 라우터를 연결합니다.
            routerConfig: router,

            title: 'Laour Cycle Manager',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            // home 프로퍼티는 routerConfig와 함께 사용할 수 없으므로 삭제됩니다.
          );
        },
      ),
    );
  }
}