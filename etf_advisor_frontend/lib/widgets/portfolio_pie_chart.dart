import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PortfolioPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> portfolio;

  const PortfolioPieChart({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface);

    // Generate a list of colors for the pie chart sections
    final List<Color> chartColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary ?? Colors.green,
      Colors.blueGrey,
    ];

    return PieChart(
      PieChartData(
        sections: List.generate(portfolio.length, (i) {
          final etf = portfolio[i];
          final isTouched = false; // Placeholder for interactivity
          final fontSize = isTouched ? 16.0 : 12.0;
          final radius = isTouched ? 60.0 : 50.0;
          final color = chartColors[i % chartColors.length];

          return PieChartSectionData(
            color: color,
            value: (etf['allocation'] as int).toDouble(),
            title: '''${etf['etf_code']}
${etf['allocation']}%''',
            radius: radius,
            titleStyle: textStyle.copyWith(fontSize: fontSize),
          );
        }),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
