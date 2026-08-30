import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:baixou/core/theme/app_theme.dart';
import 'package:baixou/features/products/domain/entities/price_history_item.dart';

class PriceHistoryChart extends StatelessWidget {
  final List<PriceHistoryItem> history;

  const PriceHistoryChart({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _buildPlaceholder('Nenhum histórico de preço disponível.');
    }

    if (history.length < 2) {
      return _buildPlaceholder('Histórico inicial registrado. Aguardando novas raspagens para traçar o gráfico.');
    }

    // Sort history by date to ensure line goes left-to-right
    final sortedHistory = List<PriceHistoryItem>.from(history)
      ..sort((a, b) => a.scrapedAt.compareTo(b.scrapedAt));

    final spots = <FlSpot>[];
    double minPrice = sortedHistory[0].price;
    double maxPrice = sortedHistory[0].price;

    for (int i = 0; i < sortedHistory.length; i++) {
      final item = sortedHistory[i];
      spots.add(FlSpot(i.toDouble(), item.price));
      if (item.price < minPrice) minPrice = item.price;
      if (item.price > maxPrice) maxPrice = item.price;
    }

    // Add padding to min/max prices for visual spacing
    final priceRange = maxPrice - minPrice;
    final yMin = (minPrice - (priceRange > 0 ? priceRange * 0.15 : 10.0)).clamp(0.0, double.infinity);
    final yMax = maxPrice + (priceRange > 0 ? priceRange * 0.15 : 10.0);

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 24, 24, 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: priceRange > 0 ? priceRange / 3 : 20,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: AppTheme.border,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < sortedHistory.length) {
                    final date = sortedHistory[idx].scrapedAt;
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      'R\$ ${value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (sortedHistory.length - 1).toDouble(),
          minY: yMin,
          maxY: yMax,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.statusScraped,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.statusScraped,
                  strokeWidth: 2,
                  strokeColor: AppTheme.darkCard,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.statusScraped.withOpacity(0.3),
                    AppTheme.statusScraped.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppTheme.border,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'R\$ ${spot.y.toStringAsFixed(2)}',
                    const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics_outlined, color: AppTheme.textSecondary, size: 48),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
