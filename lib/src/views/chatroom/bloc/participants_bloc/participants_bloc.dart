import 'package:equatable/equatable.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:bloc/bloc.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';

part 'participants_event.dart';
part 'participants_state.dart';

class ParticipantsBloc extends Bloc<ParticipantsEvent, ParticipantsState> {
  ParticipantsBloc() : super(const ParticipantsInitial()) {
    on<GetParticipants>((event, emit) async {
      if (event.getParticipantsRequest.page == 1) {
        emit(
          const ParticipantsLoading(),
        );
      } else {
        emit(
          const ParticipantsPaginationLoading(),
        );
      }
      try {
        final LMResponse<GetParticipantsResponse> response =
            await locator<LikeMindsService>().getParticipants(
          event.getParticipantsRequest,
        );
        if (response.success) {
          GetParticipantsResponse getParticipantsResponse = response.data!;
          if (getParticipantsResponse.success) {
            emit(
              ParticipantsLoaded(
                getParticipantsResponse: getParticipantsResponse,
              ),
            );
          } else {
            print(getParticipantsResponse.errorMessage);
            emit(
              ParticipantsError(
                getParticipantsResponse.errorMessage!,
              ),
            );
          }
        } else {
          print(response.errorMessage);
          emit(
            ParticipantsError(
              response.errorMessage!,
            ),
          );
        }
      } catch (e) {
        print(e.toString());
        emit(
          const ParticipantsError(
            'An error occurred',
          ),
        );
      }
    });
  }
}
