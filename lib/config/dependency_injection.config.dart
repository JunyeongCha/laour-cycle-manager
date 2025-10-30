// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../data/datasources/remote/auth_remote_datasource.dart' as _i633;
import '../data/datasources/remote/cycle_remote_datasource.dart' as _i916;
import '../data/repositories/auth_repository_impl.dart' as _i74;
import '../data/repositories/cycle_repository_impl.dart' as _i0;
import '../domain/usecases/add_manual_trade.dart' as _i549;
import '../domain/usecases/add_new_cycle.dart' as _i616;
import '../domain/usecases/calculate_portfolio.dart' as _i561;
import '../domain/usecases/get_all_cycles.dart' as _i960;
import '../domain/usecases/get_current_user.dart' as _i8;
import '../domain/usecases/sign_in.dart' as _i98;
import '../domain/usecases/sign_out.dart' as _i1007;
import '../domain/usecases/sign_up.dart' as _i188;
import '../domain/usecases/update_trade_result.dart' as _i512;
import '../presentation/view_models/add_new_cycle_viewmodel.dart' as _i792;
import '../presentation/view_models/auth_gate_viewmodel.dart' as _i516;
import '../presentation/view_models/cycle_detail_viewmodel.dart' as _i327;
import '../presentation/view_models/cycle_list_viewmodel.dart' as _i149;
import '../presentation/view_models/dashboard_viewmodel.dart' as _i570;
import '../presentation/view_models/manual_trade_viewmodel.dart' as _i826;
import '../presentation/view_models/settings_viewmodel.dart' as _i697;
import '../presentation/view_models/sign_in_viewmodel.dart' as _i524;
import '../presentation/view_models/sign_up_viewmodel.dart' as _i349;
import '../presentation/view_models/trade_result_viewmodel.dart' as _i287;
import 'firebase_injectable_module.dart' as _i574;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final firebaseInjectableModule = _$FirebaseInjectableModule();
  gh.lazySingleton<_i59.FirebaseAuth>(
      () => firebaseInjectableModule.firebaseAuth);
  gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseInjectableModule.firestore);
  gh.lazySingleton<_i549.AddManualTrade>(
      () => _i549.AddManualTrade(gh<InvalidType>()));
  gh.lazySingleton<_i616.AddNewCycle>(
      () => _i616.AddNewCycle(gh<InvalidType>()));
  gh.lazySingleton<_i561.CalculatePortfolio>(
      () => _i561.CalculatePortfolio(gh<InvalidType>()));
  gh.lazySingleton<_i960.GetAllCycles>(
      () => _i960.GetAllCycles(gh<InvalidType>()));
  gh.lazySingleton<_i8.GetCurrentUser>(
      () => _i8.GetCurrentUser(gh<InvalidType>()));
  gh.lazySingleton<_i98.SignIn>(() => _i98.SignIn(gh<InvalidType>()));
  gh.lazySingleton<_i1007.SignOut>(() => _i1007.SignOut(gh<InvalidType>()));
  gh.lazySingleton<_i188.SignUp>(() => _i188.SignUp(gh<InvalidType>()));
  gh.lazySingleton<_i512.UpdateTradeResult>(
      () => _i512.UpdateTradeResult(gh<InvalidType>()));
  gh.factory<_i524.SignInViewModel>(
      () => _i524.SignInViewModel(gh<_i98.SignIn>()));
  gh.factory<_i287.TradeResultViewModel>(
      () => _i287.TradeResultViewModel(gh<_i512.UpdateTradeResult>()));
  gh.factory<_i516.AuthGateViewModel>(
      () => _i516.AuthGateViewModel(gh<_i8.GetCurrentUser>()));
  gh.lazySingleton<_i916.CycleRemoteDataSource>(
      () => _i916.CycleRemoteDataSource(gh<_i974.FirebaseFirestore>()));
  gh.factory<_i792.AddNewCycleViewModel>(() => _i792.AddNewCycleViewModel(
        gh<_i616.AddNewCycle>(),
        gh<_i8.GetCurrentUser>(),
      ));
  gh.factory<_i149.CycleListViewModel>(() => _i149.CycleListViewModel(
        gh<_i960.GetAllCycles>(),
        gh<_i8.GetCurrentUser>(),
      ));
  gh.factory<_i570.DashboardViewModel>(() => _i570.DashboardViewModel(
        gh<_i960.GetAllCycles>(),
        gh<_i8.GetCurrentUser>(),
      ));
  gh.factory<_i697.SettingsViewModel>(
      () => _i697.SettingsViewModel(gh<_i1007.SignOut>()));
  gh.factory<_i327.CycleDetailViewModel>(
      () => _i327.CycleDetailViewModel(gh<_i561.CalculatePortfolio>()));
  gh.lazySingleton<_i633.AuthRemoteDataSource>(() => _i633.AuthRemoteDataSource(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ));
  gh.factory<_i349.SignUpViewModel>(
      () => _i349.SignUpViewModel(gh<_i188.SignUp>()));
  gh.lazySingleton<_i0.CycleRepositoryImpl>(
      () => _i0.CycleRepositoryImpl(gh<_i916.CycleRemoteDataSource>()));
  gh.factory<_i826.ManualTradeViewModel>(
      () => _i826.ManualTradeViewModel(gh<_i549.AddManualTrade>()));
  gh.lazySingleton<_i74.AuthRepositoryImpl>(() => _i74.AuthRepositoryImpl(
        gh<_i633.AuthRemoteDataSource>(),
        gh<_i974.FirebaseFirestore>(),
      ));
  return getIt;
}

class _$FirebaseInjectableModule extends _i574.FirebaseInjectableModule {}
