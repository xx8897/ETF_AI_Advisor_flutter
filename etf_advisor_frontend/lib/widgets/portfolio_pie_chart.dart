import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class PortfolioPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> portfolio;

  const PortfolioPieChart({super.key, required this.portfolio});

  @override
  State<PortfolioPieChart> createState() => _PortfolioPieChartState();
}

class _PortfolioPieChartState extends State<PortfolioPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Defensive check: If portfolio is empty or has no valid data, don't render the chart.
    if (widget.portfolio.isEmpty || widget.portfolio.every((e) => e['allocation'] == null)) {
      return const Center(child: Text('無有效的配置數據'));
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sections: widget.portfolio.asMap().entries.map((entry) {
          final index = entry.key;
          final etf = entry.value;
          final isTouched = index == touchedIndex;
          final fontSize = isTouched ? 16.0 : 12.0;
          final radius = isTouched ? 60.0 : 50.0;
          final color = Colors.primaries[index % Colors.primaries.length];

          final allocationText = etf['allocation']?.toString() ?? '?';
          // Parse the string value to a double for the chart value
          final allocationValue = double.tryParse(allocationText) ?? 0.0;

          return PieChartSectionData(
            color: color,
            value: allocationValue,
            title: '$allocationText%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}