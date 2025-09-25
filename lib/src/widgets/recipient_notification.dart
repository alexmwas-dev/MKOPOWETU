import 'package:flutter/material.dart';

class RecipientNotification extends StatefulWidget {
  final String message;

  const RecipientNotification({super.key, required this.message});

  @override
  State<RecipientNotification> createState() => _RecipientNotificationState();
}

class _RecipientNotificationState extends State<RecipientNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.green.shade100, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_up_outlined,
                    color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
