part of 'explore_bloc.dart';

abstract class ExploreState {}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final List<SpaceModel> spaces;

  ExploreLoaded(this.spaces);
}
