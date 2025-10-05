import 'package:flutter/material.dart';

class ChatFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ChatFloatingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(
        Icons.chat_bubble_outline,
        color: Colors.white,
      ),
    );
  }
}
