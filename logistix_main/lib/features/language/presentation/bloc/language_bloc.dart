import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/language_service.dart';

// Events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

class LoadLanguageEvent extends LanguageEvent {}

class ChangeLanguageEvent extends LanguageEvent {
  final String language;

  const ChangeLanguageEvent(this.language);

  @override
  List<Object?> get props => [language];
}

// States
abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final String currentLanguage;
  final Locale currentLocale;

  const LanguageLoaded({
    required this.currentLanguage,
    required this.currentLocale,
  });

  @override
  List<Object?> get props => [currentLanguage, currentLocale];
}

class LanguageError extends LanguageState {
  final String message;

  const LanguageError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageInitial()) {
    on<LoadLanguageEvent>(_onLoadLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onLoadLanguage(
    LoadLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());
    try {
      final language = await LanguageService.getLanguage();
      final locale = await LanguageService.getLocale();
      emit(LanguageLoaded(
        currentLanguage: language,
        currentLocale: locale,
      ));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());
    try {
      await LanguageService.setLanguage(event.language);
      final locale = await LanguageService.getLocale();
      emit(LanguageLoaded(
        currentLanguage: event.language,
        currentLocale: locale,
      ));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }
} 