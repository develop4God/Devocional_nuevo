import 'dart:async';

import 'package:devocional_nuevo/utils/time_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeAccelerationBanner extends StatefulWidget {
  final AcceleratedTimeProvider accelerated;
  static const bool showBanner =
      bool.fromEnvironment('TIME_ACCEL', defaultValue: false);

  const TimeAccelerationBanner({super.key, required this.accelerated});

  @override
  State<TimeAccelerationBanner> createState() => _TimeAccelerationBannerState();
}

class _TimeAccelerationBannerState extends State<TimeAccelerationBanner> {
  late Timer _timer;
  DateTime _virtualNow = DateTime.now();

  @override
  void initState() {
    super.initState();
    _virtualNow = widget.accelerated.virtualNow;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _virtualNow = widget.accelerated.virtualNow;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!TimeAccelerationBanner.showBanner) return const SizedBox.shrink();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      color: colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '🚀 Tiempo acelerado: ${widget.accelerated.accelerationFactor} | Ahora virtual: '
              '${DateFormat('yyyy-MM-dd HH:mm').format(_virtualNow)}',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
