import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/models/space_model.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  ExploreBloc() : super(ExploreInitial()) {
    on<ExploreEvent>((event, emit) async {
      if (event is InitExploreEvent) {
        emit(ExploreLoading());
        await Future.delayed(const Duration(seconds: 2), () {
          emit(ExploreLoaded(getData()));
        });
      } else if (event is RefreshExploreEvent) {
        emit(ExploreLoading());
        await Future.delayed(const Duration(seconds: 2), () {
          emit(ExploreLoaded(getData()));
        });
      } else if (event is PinSpaceEvent) {
        emit(ExploreLoading());
        await Future.delayed(const Duration(seconds: 2), () {
          emit(ExploreLoaded(getData()));
        });
      }
    });
  }

  List<SpaceModel> getData() {
    List<SpaceModel> spaces = [];

    for (int i = 0; i < 10; i++) {
      spaces.add(SpaceModel(
        name: 'MM Space $i',
        description:
            'Description $i Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        imageUrl: 'https://picsum.photos/400/400',
        id: '$i',
        isPinned: false,
        members: (i * 5),
        messages: i * 5,
      ));
    }

    return spaces;
  }
}
