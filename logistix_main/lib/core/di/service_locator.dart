import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../services/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/trip/data/repositories/trip_repository_impl.dart';
import '../../features/trip/domain/repositories/trip_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Services
  serviceLocator.registerLazySingleton<AuthService>(
    () => AuthService(serviceLocator(), serviceLocator()),
  );

  // Network
  serviceLocator.registerLazySingleton<ApiClient>(
    () => ApiClient(serviceLocator()),
  );

  // Repositories
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
  );

  serviceLocator.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(serviceLocator()),
  );

  // Use Cases
  // serviceLocator.registerLazySingleton(() => LoginUseCase(serviceLocator()));

  // Blocs
  // serviceLocator.registerFactory(() => AuthBloc(serviceLocator()));
} 