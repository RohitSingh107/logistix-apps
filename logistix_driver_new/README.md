# Logistix - Logistics Management Application

Logistix is a comprehensive logistics management application built with Flutter, designed to streamline the process of booking and managing logistics services. The application supports both customer and driver interfaces, providing a seamless experience for all users.

## Features

### Customer Features
- User authentication with OTP
- Booking management
- Real-time trip tracking
- Wallet management
- Payment processing
- Trip history

### Driver Features
- Driver profile management
- Booking acceptance
- Trip status updates
- Earnings tracking
- Rating system



## Project Repository Structure

```
logistix-apps/
├── logistix_main/              # Main application
│   ├── lib/
│   │   ├── core/              # Core functionality
│   │   │   ├── di/
│   │   │   │   └── service_locator.dart
│   │   │   ├── models/
│   │   │   │   ├── base_model.dart
│   │   │   │   ├── booking_model.dart
│   │   │   │   ├── driver_model.dart
│   │   │   │   ├── trip_model.dart
│   │   │   │   ├── user_model.dart
│   │   │   │   └── wallet_model.dart
│   │   │   ├── network/
│   │   │   │   └── api_client.dart
│   │   │   └── services/
│   │   │       ├── api_endpoints.dart
│   │   │       └── auth_service.dart
│   │   │
│   │   └── features/          # Feature modules
│   │       ├── auth/
│   │       │   ├── data/
│   │       │   │   └── repositories/
│   │       │   │       └── auth_repository_impl.dart
│   │       │   └── domain/
│   │       │       └── repositories/
│   │       │           └── auth_repository.dart
│   │       ├── booking/
│   │       │   ├── data/
│   │       │   │   └── repositories/
│   │       │   │       └── booking_repository_impl.dart
│   │       │   └── domain/
│   │       │       └── repositories/
│   │       │           └── booking_repository.dart
│   │       ├── driver/
│   │       │   ├── data/
│   │       │   │   └── repositories/
│   │       │   │       └── driver_repository_impl.dart
│   │       │   └── domain/
│   │       │       └── repositories/
│   │       │           └── driver_repository.dart
│   │       ├── trip/
│   │       │   ├── data/
│   │       │   │   └── repositories/
│   │       │   │       └── trip_repository_impl.dart
│   │       │   └── domain/
│   │       │       └── repositories/
│   │       │           └── trip_repository.dart
│   │       └── wallet/
│   │           ├── data/
│   │           │   └── repositories/
│   │           │       └── wallet_repository_impl.dart
│   │           └── domain/
│   │               └── repositories/
│   │                   └── wallet_repository.dart
│   │
│   ├── test/                  # Test files
│   ├── assets/               # Static assets
│   │   ├── images/
│   │   └── icons/
│   ├── pubspec.yaml          # Dependencies
│   └── README.md            # Project documentation
│
├── logistix_driver/          # Driver application
│   └── ...                  # Similar structure to main app
│
├── .gitignore
├── LICENSE
└── README.md                # Main documentation
```

## Architecture

The application follows Clean Architecture principles with a feature-based organization:

```
lib/
├── core/                 # Core functionality
│   ├── di/              # Dependency injection
│   ├── models/          # Core data models
│   ├── network/         # Network handling
│   └── services/        # Core services
│
└── features/            # Feature modules
    ├── auth/            # Authentication
    ├── booking/         # Booking management
    ├── driver/          # Driver features
    ├── trip/            # Trip management
    └── wallet/          # Wallet management
```

logistix_main/
├── lib/
│   ├── core/                 # Core functionality shared across features
│   │   ├── di/              # Dependency injection
│   │   ├── models/          # Core data models
│   │   ├── network/         # Network related code
│   │   └── services/        # Core services
│   │
│   └── features/            # Feature modules
│       ├── auth/            # Authentication feature
│       ├── booking/         # Booking feature
│       ├── driver/          # Driver feature
│       ├── trip/            # Trip feature
│       └── wallet/          # Wallet feature

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/logistix-apps.git
cd logistix-apps
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code:
```bash
flutter pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

## Project Structure

### Core Components

#### Models
- Data classes representing application entities
- JSON serialization support
- Equatable implementation for value comparison

#### Services
- Authentication service
- API endpoint management
- Token management

#### Network
- API client implementation
- Interceptor management
- Error handling

### Feature Modules

Each feature module contains:
- Data layer (repositories)
- Domain layer (interfaces)
- Presentation layer (UI)

## Dependencies

### Core Dependencies
- `flutter_bloc`: State management
- `dio`: Network requests
- `shared_preferences`: Local storage
- `hive`: Local database
- `json_annotation`: JSON serialization
- `jwt_decoder`: JWT token handling

### UI Dependencies
- `flutter_screenutil`: Responsive UI
- `cached_network_image`: Image caching
- `cupertino_icons`: iOS-style icons

## API Integration

The application integrates with a RESTful API backend. Key endpoints include:

- Authentication: `/api/users/`
- Booking: `/api/booking/`
- Trip: `/api/trip/`
- Wallet: `/api/payments/wallet/`
- Driver: `/api/users/driver/`

## Development

### Code Generation
After modifying models, run:
```bash
flutter pub run build_runner build
```

### Testing
Run tests using:
```bash
flutter test
```

### Building
For Android:
```bash
flutter build apk
```

For iOS:
```bash
flutter build ios
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@logistix.com or create an issue in the repository.

## Acknowledgments

- Flutter team for the amazing framework
- All contributors who have helped shape this project