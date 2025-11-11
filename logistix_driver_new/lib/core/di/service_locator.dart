/// service_locator.dart - Dependency Injection Container
/// 
/// Purpose:
/// - Manages dependency injection using GetIt service locator pattern
/// - Registers and provides access to all application services and repositories
/// - Configures singleton and factory patterns for different dependency types
/// 
/// Key Logic:
/// - Sets up SharedPreferences for persistent storage
/// - Registers Dio HTTP client for network operations
/// - Configures all service layer dependencies (AuthService, BookingService)
/// - Sets up ApiClient with proper authentication handling
/// - Registers repository implementations for all features
/// - Configures BLoC instances as factories for proper lifecycle management
/// - Provides central configuration for use cases and business logic
/// - Maintains dependency order to avoid circular dependencies
library;

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../services/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/trip/data/repositories/trip_repository_impl.dart';
import '../../features/trip/domain/repositories/trip_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/driver/data/repositories/driver_repository_impl.dart';
import '../../features/driver/domain/repositories/driver_repository.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/trip/presentation/bloc/trip_bloc.dart';
import '../services/ride_action_service.dart';
import '../services/trip_status_service.dart';
import 'package:dio/dio.dart';
import '../repositories/user_repository_impl.dart';
import '../repositories/user_repository.dart';
import '../services/location_service.dart';
import '../services/background_location_service.dart';
import '../services/language_service.dart';
import '../services/vehicle_service.dart';
import '../services/driver_document_service.dart';

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

  serviceLocator.registerLazySingleton<LocationService>(
    () => LocationService(),
  );

  serviceLocator.registerLazySingleton<BackgroundLocationService>(
    () => BackgroundLocationService(),
  );

  serviceLocator.registerLazySingleton<LanguageService>(
    () => LanguageService(),
  );

  // Network
  serviceLocator.registerLazySingleton<ApiClient>(
    () => ApiClient(serviceLocator()),
  );

  serviceLocator.registerLazySingleton<DriverDocumentService>(
    () => DriverDocumentService(serviceLocator<ApiClient>()),
  );

  serviceLocator.registerLazySingleton<VehicleService>(
    () => VehicleService(),
  );

  // Repositories
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
  );

  serviceLocator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(serviceLocator()),
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

  serviceLocator.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(serviceLocator(), serviceLocator()),
  );

  serviceLocator.registerLazySingleton<RideActionService>(
    () => RideActionService(serviceLocator()),
  );

  serviceLocator.registerLazySingleton<TripStatusService>(
    () => TripStatusService(serviceLocator()),
  );

  // Use Cases
  // serviceLocator.registerLazySingleton(() => LoginUseCase(serviceLocator()));

  // Blocs
  serviceLocator.registerFactory(() => AuthBloc(serviceLocator(), serviceLocator()));
  serviceLocator.registerFactory(() => WalletBloc(serviceLocator()));
  serviceLocator.registerFactory(() => NotificationBloc(serviceLocator()));
  serviceLocator.registerFactory(() => TripBloc(serviceLocator()));
} 