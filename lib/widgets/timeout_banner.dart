import 'package:flutter/material.dart';

/// Re-prompt banner shown when the user runs out of time to pronounce a
/// word. Slides down from the top; swipe up or wait it out to dismiss.
/// Kept separate from [WordPracticeScreen] so it stays testable without
/// the rest of that screen's plugin wiring.
class TimeoutBanner extends StatelessWidget {
  final bool visible;
  final VoidCallback onDismiss;
  final String message;

  const TimeoutBanner({
    super.key,
    required this.visible,
    required this.onDismiss,
    this.message = 'Please speak louder and try again!',
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        offset: visible ? Offset.zero : const Offset(0, -1.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1 : 0,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < 0) {
                    onDismiss();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic_off, color: Colors.orange.shade800),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          message,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
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
