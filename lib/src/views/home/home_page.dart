import 'package:flutter_svg/svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/asset_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/bloc/home_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_components/chat_item.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_components/skeleton_list.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? communityName;
  String? userName;
  User? user;
  HomeBloc? homeBloc;
  ValueNotifier<bool> rebuildPagedList = ValueNotifier(false);
  PagingController<int, ChatItem> homeFeedPagingController =
      PagingController(firstPageKey: 1);

  int _pageKey = 1;

  @override
  void initState() {
    super.initState();

    UserLocalPreference userLocalPreference = UserLocalPreference.instance;
    userName = userLocalPreference.fetchUserData().name;
    communityName = userLocalPreference.fetchCommunityData()["community_name"];
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc!.add(
      InitHomeEvent(
        page: _pageKey,
      ),
    );
    _addPaginationListener();
  }

  _addPaginationListener() {
    homeFeedPagingController.addPageRequestListener(
      (pageKey) {
        homeBloc!.add(
          InitHomeEvent(
            page: pageKey,
          ),
        );
      },
    );
  }

  updatePagingControllers(HomeState state) {
    if (state is HomeLoaded) {
      List<ChatItem> chatItems = getChats(context, state.response);
      _pageKey++;
      if (state.response.chatroomsData == null ||
          state.response.chatroomsData!.isEmpty ||
          state.response.chatroomsData!.length < 50) {
        homeFeedPagingController.appendLastPage(chatItems);
      } else {
        homeFeedPagingController.appendPage(chatItems, _pageKey);
      }
    } else if (state is UpdateHomeFeed) {
      List<ChatItem> chatItems = getChats(context, state.response);
      _pageKey = 2;
      homeFeedPagingController.nextPageKey = _pageKey;
      homeFeedPagingController.itemList = chatItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          width: 100.w,
          color: LMBranding.instance.headerColor,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.h,
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    alignment: Alignment.center,
                    child: Text(
                      communityName ?? "Chatrooms",
                      style: LMBranding.instance.fonts.medium
                          .copyWith(fontSize: 14.sp, color: kWhiteColor),
                    ),
                  ),
                  //   communityName ??
                  // ),
                  PictureOrInitial(
                    fallbackText: userName ?? "..",
                    size: 30.sp,
                    imageUrl: user?.imageUrl,
                    backgroundColor: LMTheme.buttonColor == LMTheme.headerColor
                        ? kSecondaryColor
                        : LMTheme.buttonColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            router.push(exploreRoute);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 42.sp,
                  width: 42.sp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        kAssetExploreIcon,
                        color: LMTheme.buttonColor,
                        width: 8.w,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                  ),
                  child: Text(
                    'Explore chatrooms',
                    style: LMTheme.bold.copyWith(fontSize: 12.sp),
                  ),
                ),
                const Spacer(),
                FutureBuilder(
                    future: locator<LikeMindsService>().getExploreTabCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      }
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        if (snapshot.data!.success) {
                          GetExploreTabCountResponse response =
                              snapshot.data!.data!;
                          if (response.unseenChannelCount == 0) {
                            return Container();
                          } else {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                  color: LMTheme.buttonColor,
                                  borderRadius: BorderRadius.circular(
                                    10.0,
                                  ),
                                  shape: BoxShape.rectangle),
                              child: Text(
                                '${response.unseenChannelCount} new',
                                style:
                                    LMTheme.bold.copyWith(color: kWhiteColor),
                              ),
                            );
                          }
                        } else {
                          const SizedBox();
                        }
                      }
                      return const SizedBox();
                    })
              ],
            ),
          ),
        ),
        Expanded(
          child: BlocConsumer<HomeBloc, HomeState>(
            bloc: homeBloc,
            listener: (context, state) {
              updatePagingControllers(state);
            },
            buildWhen: (previous, current) {
              if (previous is HomeLoaded && current is HomeLoading) {
                return false;
              } else if (previous is UpdateHomeFeed && current is HomeLoading) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state is HomeLoading) {
                return const SkeletonChatList();
              } else if (state is HomeError) {
                return Center(
                  child: Text(state.message),
                );
              } else if (state is HomeLoaded ||
                  state is UpdateHomeFeed ||
                  state is UpdatedHomeFeed) {
                return SafeArea(
                  top: false,
                  child: ValueListenableBuilder(
                      valueListenable: rebuildPagedList,
                      builder: (context, _, __) {
                        return PagedListView<int, ChatItem>(
                          pagingController: homeFeedPagingController,
                          padding: EdgeInsets.zero,
                          physics: const ClampingScrollPhysics(),
                          builderDelegate: PagedChildBuilderDelegate<ChatItem>(
                            newPageProgressIndicatorBuilder: (_) =>
                                const SizedBox(),
                            noItemsFoundIndicatorBuilder: (context) =>
                                const SizedBox(),
                            itemBuilder: (context, item, index) {
                              return item;
                            },
                          ),
                        );
                      }),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    ));
  }

  List<ChatItem> getChats(BuildContext context, GetHomeFeedResponse response) {
    List<ChatItem> chats = [];
    final List<ChatRoom> chatrooms = response.chatroomsData ?? [];
    final Map<String, Conversation> lastConversations =
        response.conversationMeta ?? {};
    final Map<int, User> userMeta = response.userMeta ?? {};

    for (int i = 0; i < chatrooms.length; i++) {
      final Conversation conversation =
          lastConversations[chatrooms[i].lastConversationId.toString()]!;
      chats.add(
        ChatItem(
          chatroom: chatrooms[i],
          conversation: conversation,
          attachmentsMeta: response
                  .conversationAttachmentsMeta?[conversation.id.toString()] ??
              [],
          user: userMeta[conversation.member?.id ?? conversation.userId],
        ),
      );
    }

    return chats;
  }
}

Widget getShimmer() => Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade300,
      period: const Duration(seconds: 2),
      direction: ShimmerDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 12,
        ),
        child: Container(
          height: 16,
          width: 32.w,
          color: kWhiteColor,
        ),
      ),
    );
