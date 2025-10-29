// lib/config/dependency_injection.dart

import 'package.get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import the generated file
import 'dependency_injection.config.dart';

// GetIt is a service locator that we use for dependency injection.
final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
void configureDependencies() => $initGetIt(getIt);