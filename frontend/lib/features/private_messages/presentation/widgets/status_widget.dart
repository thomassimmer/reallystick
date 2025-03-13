import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final bool isSeen;

  const StatusWidget({super.key, required this.isSeen});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Icon(
          Icons.check,
          size: 16,
          color: isSeen ? Colors.blue : Colors.grey,
        ),
        if (isSeen)
          Transform.translate(
            offset: const Offset(4, 0), // Adjust this for spacing
            child: Icon(
              Icons.check,
              size: 16,
              color: Colors.blue,
            ),
          ),
      ],
    );
  }
}
