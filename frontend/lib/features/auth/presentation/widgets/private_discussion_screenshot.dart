import 'package:flutter/material.dart';
import 'package:reallystick/core/presentation/screens/root_screen.dart';
import 'package:reallystick/features/private_messages/presentation/screens/private_discussion_screen.dart';

class PrivateDiscussionScreenshot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: MediaQuery.removePadding(
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
                  previewTab: 2,
                  child: PrivateDiscussionScreen(
                    discussionId: '1',
                    previewMode: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
