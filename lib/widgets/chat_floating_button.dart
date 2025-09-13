import 'package:flutter/material.dart';

class ChatFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const ChatFloatingButton({
    Key? key, 
    required this.onPressed,
  }) : super(key: key);
  
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