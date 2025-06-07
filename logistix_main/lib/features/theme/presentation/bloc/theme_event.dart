import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ChangeThemeEvent extends ThemeEvent {
  final String themeName;

  const ChangeThemeEvent(this.themeName);

  @override
  List<Object> get props => [themeName];
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
} 