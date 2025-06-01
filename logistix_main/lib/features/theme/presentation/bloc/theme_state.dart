import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final String themeName;

  const ThemeLoaded({required this.themeName});

  @override
  List<Object> get props => [themeName];
} 