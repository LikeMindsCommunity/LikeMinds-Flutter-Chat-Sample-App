part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class InitHomeEvent extends HomeEvent {
  int page;
  InitHomeEvent({required this.page});
}

class ReloadHomeEvent extends HomeEvent {
  final GetHomeFeedResponse response;

  ReloadHomeEvent({required this.response});
}

class UpdateHomeEvent extends HomeEvent {
  UpdateHomeEvent();
}
