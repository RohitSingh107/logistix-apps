import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../services/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/trip/data/repositories/trip_repository_impl.dart';
import '../../features/trip/domain/repositories/trip_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/driver/data/repositories/driver_repository_impl.dart';
import '../../features/driver/domain/repositories/driver_repository.dart';
import '../../features/vehicle_estimation/data/repositories/vehicle_estimation_repository.dart';
import '../../features/vehicle_estimation/domain/repositories/vehicle_estimation_repository_interface.dart';
import '../../features/vehicle_estimation/domain/usecases/get_vehicle_estimates.dart';
import '../../features/booking/data/services/booking_service.dart';
import 'package:dio/dio.dart';
import '../repositories/user_repository_impl.dart';
import '../repositories/user_repository.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Dio
  serviceLocator.registerLazySingleton<Dio>(() => Dio());

  // Services
  serviceLocator.registerLazySingleton<AuthService>(
    () => AuthService(serviceLocator(), serviceLocator()),
  );

  serviceLocator.registerLazySingleton<BookingService>(
    () => BookingService(serviceLocator()),
  );

  // Network
  serviceLocator.registerLazySingleton<ApiClient>(
    () => ApiClient(serviceLocator()),
  );

  // Repositories
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
  );

  serviceLocator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(serviceLocator()),
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

  serviceLocator.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerLazySingleton<VehicleEstimationRepositoryInterface>(
    () => VehicleEstimationRepository(serviceLocator()),
  );

  // Use Cases
  serviceLocator.registerLazySingleton<GetVehicleEstimates>(
    () => GetVehicleEstimates(serviceLocator()),
  );

  // Use Cases
  // serviceLocator.registerLazySingleton(() => LoginUseCase(serviceLocator()));

  // Blocs
  serviceLocator.registerFactory(() => AuthBloc(serviceLocator(), serviceLocator()));
  serviceLocator.registerFactory(() => WalletBloc(serviceLocator()));
} 