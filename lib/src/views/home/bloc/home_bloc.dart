import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async {
      emit(HomeLoading());
      if (event is InitHomeEvent) {
        emit(HomeLoading());
        //Perform logic
        final response =
            await locator<LikeMindsService>().getHomeFeed(GetHomeFeedRequest());
        if (response.success) {
          emit(HomeLoaded(response: response.data!));
        } else {
          HomeError(response.errorMessage!);
        }
      }

      if (event is ReloadHomeEvent) {
        emit(HomeLoading());
      }
    });
  }
}
