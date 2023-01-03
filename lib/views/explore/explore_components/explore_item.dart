import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/views/explore/explore_components/join_button.dart';
import 'package:group_chat_example/data/models/explore/space_model.dart';

class ExploreItem extends StatelessWidget {
  const ExploreItem({
    Key? key,
    required this.space,
    required this.onTap,
    required this.refresh,
  }) : super(key: key);

  final SpaceModel space;
  final Function() onTap;
  final Function() refresh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: SizedBox(
        height: 120,
        // color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        space.imageUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                  )),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                space.name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    color: Colors.grey[600],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    space.members.toString(),
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.message_outlined,
                                    color: Colors.grey[600],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    space.messages.toString(),
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        JoinButton(
                          isJoined: space.isJoined,
                          onTap: () {
                            space.isJoined = !space.isJoined;
                            refresh();
                          },
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      space.description,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
