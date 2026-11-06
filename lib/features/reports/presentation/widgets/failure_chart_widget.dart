import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/report_models.dart';

const List<Color> chartPalette = [
  Color(0xFF0B5FA5),
  Color(0xFF00A3A3),
  Color(0xFFEF6C00),
  Color(0xFF6A1B9A),
  Color(0xFF2E7D32),
  Color(0xFFC62828),
  Color(0xFF546E7A),
];

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({super.key, required this.points, this.height = 240});

  final List<TrendPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Sin datos de tendencia para el periodo.')),
      );
    }

    final maxY = points
        .map((p) => p.total)
        .fold<int>(0, (prev, value) => value > prev ? value : prev);
    final top = (maxY <= 4 ? 4 : maxY + 1).toDouble();
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: top,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: top <= 8 ? 1 : (top / 5).ceilToDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: top <= 8 ? 1 : (top / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: points.length <= 7
                    ? 1
                    : (points.length / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  final dia = points[index].dia;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _shortDate(dia),
                      style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map(
                    (spot) => LineTooltipItem(
                      '${_shortDate(points[spot.x.round()].dia)}\n'
                      'Creados: ${spot.y.toInt()}',
                      const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].total.toDouble()),
              ],
              isCurved: true,
              curveSmoothness: 0.25,
              color: chartPalette.first,
              barWidth: 3,
              dotData: FlDotData(show: points.length <= 10),
              belowBarData: BarAreaData(
                show: true,
                color: chartPalette.first.withValues(alpha: 0.12),
              ),
            ),
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].atendidos.toDouble()),
              ],
              isCurved: true,
              curveSmoothness: 0.25,
              color: chartPalette[4],
              barWidth: 2,
              dashArray: const [6, 4],
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.day}/${date.month}';
  }
}

class DistributionPieChart extends StatelessWidget {
  const DistributionPieChart({
    super.key,
    required this.data,
    this.height = 240,
    this.labelBuilder,
    this.colors = chartPalette,
  });

  final List<CountByKey> data;
  final double height;
  final String Function(String clave)? labelBuilder;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (prev, item) => prev + item.total);
    if (total == 0) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Sin datos para mostrar.')),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 42,
                sections: [
                  for (var i = 0; i < data.length; i++)
                    PieChartSectionData(
                      value: data[i].total.toDouble(),
                      color: colors[i % colors.length],
                      radius: 42,
                      title: data[i].total.toString(),
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < data.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              labelBuilder?.call(data[i].clave) ?? data[i].clave,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Text(
                            '${data[i].total}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryBarChart extends StatelessWidget {
  const CategoryBarChart({
    super.key,
    required this.data,
    this.height = 260,
    this.maxBars = 7,
  });

  final List<CountByKey> data;
  final double height;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    final items = data.take(maxBars).toList();
    if (items.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Sin datos para mostrar.')),
      );
    }

    final maxValue = items
        .map((item) => item.total)
        .fold<int>(0, (prev, value) => value > prev ? value : prev);
    final top = (maxValue <= 4 ? 4 : maxValue + 1).toDouble();
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: top,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: top <= 8 ? 1 : (top / 4).ceilToDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: top <= 8 ? 1 : (top / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= items.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: SizedBox(
                      width: 56,
                      child: Text(
                        items[index].clave,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${items[groupIndex].clave}\n${rod.toY.toInt()} ticket(s)',
                const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < items.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: items[i].total.toDouble(),
                    width: 22,
                    color: chartPalette[i % chartPalette.length],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class SatisfactionBarChart extends StatelessWidget {
  const SatisfactionBarChart({super.key, required this.data, this.height = 200});

  final List<CountByKey> data;
  final double height;

  static const _colors = [
    Color(0xFFC62828),
    Color(0xFFEF6C00),
    Color(0xFFF9A825),
    Color(0xFF7CB342),
    Color(0xFF2E7D32),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Aun no hay encuestas respondidas.')),
      );
    }

    final maxValue = data
        .map((item) => item.total)
        .fold<int>(0, (prev, value) => value > prev ? value : prev);
    final top = (maxValue <= 3 ? 3 : maxValue + 1).toDouble();
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: top,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: top <= 6 ? 1 : (top / 4).ceilToDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: top <= 6 ? 1 : (top / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final level = int.tryParse(data[index].clave) ?? index + 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '$level★',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].total.toDouble(),
                    width: 26,
                    color: _colors[
                        ((int.tryParse(data[i].clave) ?? (i + 1)) - 1).clamp(0, 4)],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ChartLegendDot extends StatelessWidget {
  const ChartLegendDot({
    super.key,
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

String formatTrendLabel(String dia) {
  final date = DateTime.tryParse(dia);
  if (date == null) return dia;
  return formatFechaCorta(date.toIso8601String());
}
