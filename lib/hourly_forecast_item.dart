import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final String temperature;
  final IconData icon;
  final Color iconColor;
  final bool isCurrent;

  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.temperature,
    required this.icon,
    this.iconColor = Colors.white,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: isCurrent 
            ? Colors.blueAccent.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent 
              ? Colors.blueAccent.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: isCurrent ? [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Icon(
            icon,
            size: 30,
            color: iconColor,
          ),
          const SizedBox(height: 12),
          Text(
            '$temperature°C',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}