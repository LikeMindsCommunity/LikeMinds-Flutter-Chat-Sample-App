part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class InitHomeEvent extends HomeEvent {
  InitHomeEvent();
}

class ReloadHomeEvent extends HomeEvent {}
