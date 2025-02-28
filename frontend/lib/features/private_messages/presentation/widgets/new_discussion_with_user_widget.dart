import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';

class NewDiscussionWithUserWidget extends StatelessWidget {
  final UserPublicData user;

  const NewDiscussionWithUserWidget({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.goNamed(
          'newDiscussion',
          pathParameters: {
            'recipientId': user.id,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
