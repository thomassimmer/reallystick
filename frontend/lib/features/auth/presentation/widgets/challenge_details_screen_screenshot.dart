import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/presentation/screens/root_screen.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/challenges/presentation/screens/challenge_detail_screen.dart';
import 'package:reallystick/features/challenges/presentation/screens/list_daily_trackings_modal.dart';

class ChallengeDetailsScreenScreenshot extends StatelessWidget {
  final bool previewForDailyObjectives;
  final bool previewForDiscussion;

  const ChallengeDetailsScreenScreenshot({
    required this.previewForDailyObjectives,
    required this.previewForDiscussion,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = checkIfLargeScreen(context);

    return IgnorePointer(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: RootScreen(
                      previewMode: true,
                      previewTab: 1,
                      child: ChallengeDetailsScreen(
                        challengeId: previewForDiscussion ? '2' : '1',
                        challengeParticipationId:
                            previewForDiscussion ? '2' : '1',
                        previewMode: true,
                        previewForDailyObjectives: previewForDailyObjectives,
                        previewForDiscussion: previewForDiscussion,
                      ),
                    ),
                  ),
                ),
              ),
              if (previewForDailyObjectives) ...[
                // Dark scrim overlay
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isLargeScreen ? 80 : 4,
                    0,
                    isLargeScreen ? 0 : 4,
                    4,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16.0),
                          bottom: Radius.circular(8.0),
                        ),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: 700,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: max(
                              16.0, MediaQuery.of(context).viewInsets.bottom),
                          left: 16.0,
                          right: 16.0,
                          top: 16.0,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListDailyTrackingsModal(
                                datetime:
                                    DateTime.now().subtract(Duration(days: 1)),
                                challenge: getChallengeStateForPreview(context)
                                    .challenges['1']!,
                                challengeParticipation:
                                    getChallengeStateForPreview(context)
                                        .challengeParticipations[0],
                                previewMode: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
