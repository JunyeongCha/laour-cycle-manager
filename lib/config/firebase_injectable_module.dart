// lib/config/firebase_injectable_module.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

// @module: "이 클래스는 기본 재료(부품)들을 제공하는 특별한 목록이야!"
// 라고 알려주는 스티커입니다.
@module
abstract class FirebaseInjectableModule {
  
  // 누군가 FirebaseAuth가 필요하다고 하면,
  // FirebaseAuth.instance를 만들어서 줘!
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  // 누군가 FirebaseFirestore가 필요하다고 하면,
  // FirebaseFirestore.instance를 만들어서 줘!
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}