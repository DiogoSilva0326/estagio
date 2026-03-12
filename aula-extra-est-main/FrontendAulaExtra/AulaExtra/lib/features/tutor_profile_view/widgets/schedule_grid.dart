import 'package:flutter/material.dart';

class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({super.key});

  static const _dayWidth = 181.803;
  static const _radius = 10.908;

  @override
  Widget build(BuildContext context) {
    Widget dayColumn(String day, List<String> times) {
      return Container(
        width: _dayWidth,
        height: 198.532,
        padding: const EdgeInsets.only(left: 14.181, right: 14.181, top: 14.181, bottom: 1.091),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.091),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 26.18,
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 17.453,
                    height: 26.18 / 17.453,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.727),
            for (final t in times) ...[
              Container(
                height: 30.543,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(4.363),
                ),
                child: Center(
                  child: Text(
                    t,
                    style: const TextStyle(
                      fontSize: 15.272,
                      height: 21.817 / 15.272,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF008236),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4.363),
            ],
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          dayColumn('Seg', const ['09:00', '14:00', '16:00']),
          const SizedBox(width: 17.09),
          dayColumn('Ter', const ['10:00', '15:00']),
          const SizedBox(width: 17.09),
          dayColumn('Qua', const ['09:00', '14:00', '16:00', '18:00']),
          const SizedBox(width: 17.09),
          dayColumn('Qui', const ['10:00', '15:00']),
          const SizedBox(width: 17.09),
          dayColumn('Sex', const ['09:00', '14:00']),
          const SizedBox(width: 17.09),
          dayColumn('Sáb', const ['10:00', '11:00']),
          const SizedBox(width: 17.09),
          dayColumn('Dom', const ['10:00', '11:00']),
        ],
      ),
    );
  }
}
