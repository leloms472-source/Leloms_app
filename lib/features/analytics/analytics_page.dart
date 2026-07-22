import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/study_provider.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>();
    final study = context.watch<StudyProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Progreso'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(user, study),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Tiempo de Estudio'),
            const SizedBox(height: 12),
            _buildStudyTimeChart(),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Nivel y Experiencia'),
            const SizedBox(height: 12),
            _buildXpChart(),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Resumen General'),
            const SizedBox(height: 12),
            _buildSummaryGrid(user, study),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(ProfileProvider user, StudyProvider study) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatCard(label: 'Nivel', value: '${user.level}', icon: Icons.auto_graph_rounded, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(label: 'XP Total', value: '${user.currentXp}', icon: Icons.stars_rounded, color: AppColors.gold)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatCard(label: 'Sesiones', value: '${study.allTimeSessions}', icon: Icons.repeat_rounded, color: AppColors.info)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(label: 'Minutos', value: '${study.allTimeMinutes}', icon: Icons.access_time_rounded, color: AppColors.success)),
          ],
        ),
      ],
    );
  }

  Widget _buildStudyTimeChart() {
    final studyMinutes = [30, 45, 20, 60, 40, 35, 50];
    final days = List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      return (day, studyMinutes[i]);
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 150,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= days.length) return const SizedBox();
                    final dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                    final weekDay = days[idx].$1.weekday - 1;
                    return Text(dayNames[weekDay], style: const TextStyle(color: AppColors.secondaryText, fontSize: 11));
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 50,
              getDrawingHorizontalLine: (value) => FlLine(color: AppColors.border.withValues(alpha: 0.3), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: days.asMap().entries.map((entry) {
              return BarChartGroupData(x: entry.key, barRods: [
                BarChartRodData(
                  toY: entry.value.$2.toDouble(),
                  color: AppColors.primary,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildXpChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) => FlLine(color: AppColors.border.withValues(alpha: 0.3), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(7, (i) => FlSpot(i.toDouble(), [10, 25, 15, 40, 30, 50, 35][i].toDouble())),
                isCurved: true,
                color: AppColors.gold,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.gold,
                    strokeWidth: 2,
                    strokeColor: AppColors.dark,
                  ),
                ),
                belowBarData: BarAreaData(show: true, color: AppColors.gold.withValues(alpha: 0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(ProfileProvider user, StudyProvider study) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSummaryRow('Nivel Actual', '${user.level}', '${user.currentXp}/${user.nextLevelXp} XP'),
          const Divider(color: AppColors.border, height: 24),
          _buildSummaryRow('Sesiones Totales', '${study.allTimeSessions}', '${study.allTimeMinutes} min'),
          const Divider(color: AppColors.border, height: 24),
          _buildSummaryRow('Hoy', '${study.sessionsToday} sesiones', '${study.totalMinutesToday} min'),
          const Divider(color: AppColors.border, height: 24),
          _buildSummaryRow('Racha Actual', '${study.currentStreakDays} días', '${user.streak} en racha'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
