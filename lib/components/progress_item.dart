import 'package:flutter/material.dart';

class ProgressItem extends StatelessWidget {
  final String label;
  final double progress;
  final String progressText;

  const ProgressItem({
    super.key,
    required this.label,
    required this.progress,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2430),
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2430),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Color(0xFFDCE6D8),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF4D2A86),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
