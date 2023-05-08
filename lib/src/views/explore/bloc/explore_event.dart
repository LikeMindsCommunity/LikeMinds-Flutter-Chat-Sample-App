part of 'explore_bloc.dart';

abstract class ExploreEvent {}

class InitExploreEvent extends ExploreEvent {}

class RefreshExploreEvent extends ExploreEvent {}

class PinSpaceEvent extends ExploreEvent {
  final String spaceId;
  final bool isPinned;

  PinSpaceEvent(this.spaceId, this.isPinned);
}
