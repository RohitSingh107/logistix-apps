/// base_model.dart - Base Data Model Abstract Class
/// 
/// Purpose:
/// - Provides a common base class for all data models in the application
/// - Enforces consistent structure and behavior across all models
/// - Integrates with Equatable for value comparison and equality checks
/// 
/// Key Logic:
/// - Extends Equatable to provide automatic equality comparison
/// - Defines abstract toJson() method that all models must implement
/// - Provides default props implementation for Equatable
/// - Serves as foundation for consistent model architecture
/// - Ensures all models can be serialized to JSON format

import 'package:equatable/equatable.dart';

abstract class BaseModel extends Equatable {
  const BaseModel();

  Map<String, dynamic> toJson();
  
  @override
  List<Object?> get props => [];
} 