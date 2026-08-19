import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/monthly_report_model.dart';

class EffortRatioChart extends StatefulWidget {
  final MonthlyReportModel report;

  const EffortRatioChart({super.key, required this.report});

  @override
  State<EffortRatioChart> createState() => _EffortRatioChartState();
}

class _EffortRatioChartState extends State<EffortRatioChart> {
  int _touchedIndex = -1;

  final List<Color> _partnerColors = [
    AppColors.partner1,
    AppColors.partner2,
    AppColors.partner3,
    Colors.teal,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final summaries = widget.report.partnerSummaries.values.toList();
    if (summaries.isEmpty || widget.report.totalPartnersPoints <= 0) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text(
          'لا توجد نقاط مسجلة لهذا الشهر حتى الآن لحساب نسبة المجهود.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    final sections = summaries.asMap().entries.map((entry) {
      final idx = entry.key;
      final partner = entry.value;
      final isTouched = idx == _touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final color = _partnerColors[idx % _partnerColors.length];

      return PieChartSectionData(
        color: color,
        value: partner.effortPercentage > 0 ? partner.effortPercentage : 0.1,
        title: '${partner.effortPercentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Legend row
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: summaries.asMap().entries.map((entry) {
            final idx = entry.key;
            final partner = entry.value;
            final color = _partnerColors[idx % _partnerColors.length];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${partner.userName}: ${partner.effortPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
