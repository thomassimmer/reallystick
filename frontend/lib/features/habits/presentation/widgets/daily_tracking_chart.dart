import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/presentation/screens/list_daily_trackings_modal.dart';

class DailyTrackingChart extends StatefulWidget {
  final Map<DateTime, double> aggregatedQuantities;
  final DateTime startDate;
  final int actualNumberOfBoxesToDisplay;
  final Color habitColor;
  final String userLocale;
  final Habit habit;

  const DailyTrackingChart({
    super.key,
    required this.aggregatedQuantities,
    required this.startDate,
    required this.actualNumberOfBoxesToDisplay,
    required this.habitColor,
    required this.userLocale,
    required this.habit,
  });

  @override
  State<DailyTrackingChart> createState() => _DailyTrackingChartState();
}

class _DailyTrackingChartState extends State<DailyTrackingChart> {
  List<Color> get gradientColors => [
        widget.habitColor,
        context.colors.background,
      ];

  final _chartKey = GlobalKey();
  late TransformationController _transformationController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _transformationController = TransformationController();

    // Scale to fit 14 days within the visible area
    final initialScale = widget.actualNumberOfBoxesToDisplay / 14.0;

    _transformationController.value =
        Matrix4.diagonal3Values(initialScale, 1, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 50), () {
        final childRenderBox =
            _chartKey.currentContext!.findRenderObject()! as RenderBox;
        final chartBoundaryRect = Offset.zero & childRenderBox.size;

        _transformationController.value *= Matrix4.translationValues(
          -chartBoundaryRect.width *
              (widget.actualNumberOfBoxesToDisplay - 14) /
              widget.actualNumberOfBoxesToDisplay,
          0,
          0,
        );
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value % 1 != 0) {
      return SizedBox.shrink();
    }

    final int dayOffset = value.toInt();
    final DateTime date = widget.startDate.add(Duration(days: dayOffset));

    double visibleDays = (meta.max - meta.min) /
        _transformationController.value.getMaxScaleOnAxis();

    DateFormat format;
    if (visibleDays <= 365) {
      format = DateFormat.Md(widget.userLocale);
    } else {
      format = DateFormat.yMMMd(widget.userLocale);
    }

    final String dayLabel = format.format(date);

    return SideTitleWidget(
      meta: meta,
      child: Transform.rotate(
        angle: -45 * 3.14 / 180,
        child: Text(
          dayLabel,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  void _showBottomModalSheet(int spotIndex) {
    final datetime = widget.startDate.add(Duration(days: spotIndex));
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
        maxWidth: 700,
      ),
      backgroundColor: context.colors.background,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: max(16.0, MediaQuery.of(context).viewInsets.bottom),
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListDailyTrackingsModal(
                  datetime: datetime,
                  habitId: widget.habit.id,
                  habitColor: widget.habitColor,
                  previewMode: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  LineChartData mainData() {
    final List<FlSpot> spots = [];

    for (int i = 0; i < widget.actualNumberOfBoxesToDisplay; i++) {
      DateTime date = widget.startDate.add(Duration(days: i));
      double quantity = widget.aggregatedQuantities[date] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), quantity));
    }

    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((e) => null).toList(),
          getTooltipColor: (_) => Colors.transparent,
        ),
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(color: Colors.transparent),
              FlDotData(show: false),
            );
          }).toList();
        },
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          if (touchResponse == null || touchResponse.lineBarSpots == null) {
            return;
          }

          if (event is FlTapUpEvent) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 200), () {
              final spot = touchResponse.lineBarSpots!.first;
              _showBottomModalSheet(spot.spotIndex);
            });
          } else if (event is FlPanStartEvent || event is FlLongPressStart) {
            _debounce?.cancel();
          }
        },
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: gradientColors[0].withValues(alpha: 0.7),
          barWidth: 4,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: 170,
        child: LineChart(
          chartRendererKey: _chartKey,
          transformationConfig: FlTransformationConfig(
            scaleAxis: FlScaleAxis.horizontal,
            maxScale: 30,
            panEnabled: true,
            scaleEnabled: true,
            transformationController: _transformationController,
          ),
          mainData(),
        ),
      ),
    );
  }
}
