part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  // final List<ChatItem> chats;

  // HomeLoaded(this.chats);
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
