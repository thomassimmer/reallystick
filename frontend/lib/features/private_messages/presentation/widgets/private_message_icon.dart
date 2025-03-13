import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_states.dart';

class PrivateMessageIcon extends StatelessWidget {
  final IconData iconData;

  const PrivateMessageIcon({
    super.key,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrivateDiscussionBloc, PrivateDiscussionState>(
      builder: (context, privateDiscussionState) {
        final unseenMessages = privateDiscussionState.discussions.values
            .map((d) => d.unseenMessages)
            .fold(0, (sum, v) => sum + v);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.message_outlined),
            if (unseenMessages > 0)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      unseenMessages > 99 ? '99+' : '$unseenMessages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
