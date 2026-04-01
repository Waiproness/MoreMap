import 'package:flutter/material.dart';

class CircularMapButton extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onPressed;

  const CircularMapButton({
    super.key,
    required this.iconData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), 
            blurRadius: 5, 
            offset: const Offset(0, 2)
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(iconData, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }
}