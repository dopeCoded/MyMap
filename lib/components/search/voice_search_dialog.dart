import 'package:flutter/material.dart';

class VoiceSearchDialog extends StatelessWidget {
  const VoiceSearchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('お話しください', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.mic, size: 64, color: Colors.red),
            ),
            const SizedBox(height: 60),
            const Text('日本語', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
