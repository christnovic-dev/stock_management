import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StockChart extends StatelessWidget {
  const StockChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 30)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 80)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 50)]),
          ],
        ),
      ),
    );
  }
}
