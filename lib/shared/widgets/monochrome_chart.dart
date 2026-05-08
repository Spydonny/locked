import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../shared/models/app_models.dart';
import '../../theme/app_colors.dart';
import 'glass_card.dart';

class MonochromeChart extends StatelessWidget {
  const MonochromeChart({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
  });

  final String title;
  final String subtitle;
  final List<ChartDatum> points;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: const CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
                majorTickLines: MajorTickLines(size: 0),
                labelStyle: TextStyle(color: AppColors.textTertiary),
              ),
              primaryYAxis: const NumericAxis(
                isVisible: false,
                majorGridLines: MajorGridLines(
                  width: 0.8,
                  dashArray: [4, 5],
                  color: AppColors.stroke,
                ),
              ),
              series: <CartesianSeries<ChartDatum, String>>[
                SplineAreaSeries<ChartDatum, String>(
                  dataSource: points,
                  xValueMapper: (datum, _) => datum.label,
                  yValueMapper: (datum, _) => datum.value,
                  borderColor: AppColors.white,
                  borderWidth: 2.4,
                  color: const Color(0x26FFFFFF),
                  splineType: SplineType.natural,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
