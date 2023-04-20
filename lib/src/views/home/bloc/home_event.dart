part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class InitHomeEvent extends HomeEvent {}

class ReloadHomeEvent extends HomeEvent {}
