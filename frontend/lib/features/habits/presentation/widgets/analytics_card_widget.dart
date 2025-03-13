import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/habits/domain/entities/analytics_card_info.dart';

class AnalyticsCardWidget extends StatefulWidget {
  final AnalyticsCardInfo analyticsCardInfo;
  final String userLocale;
  final Color color;

  const AnalyticsCardWidget({
    super.key,
    required this.analyticsCardInfo,
    required this.userLocale,
    required this.color,
  });

  @override
  State<AnalyticsCardWidget> createState() => _AnalyticsCardWidgetState();
}

class _AnalyticsCardWidgetState extends State<AnalyticsCardWidget> {
  bool _detailsOpen = false;
  bool _isOverflowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  void toggleDetailVisibility() {
    setState(() {
      _detailsOpen = !_detailsOpen;
    });
  }

  void _checkTextOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.analyticsCardInfo.text,
        style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 350 - 32); // Adjust for padding (16 left + 16 right)

    final isOverflowing = textPainter.didExceedMaxLines;

    setState(() {
      _isOverflowing = isOverflowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: _detailsOpen ? null : 130,
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color.withAlpha(100),
            widget.color.withBlue(100).withAlpha(100)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.analyticsCardInfo.icon,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  widget.analyticsCardInfo.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(widget.analyticsCardInfo.text,
                overflow: _detailsOpen ? null : TextOverflow.ellipsis,
                maxLines: _detailsOpen ? null : 3,
                style: TextStyle(color: Colors.white)),
            if (_isOverflowing) ...[
              SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: toggleDetailVisibility,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.only(bottom: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _detailsOpen
                        ? AppLocalizations.of(context)!.tapToSeeLess
                        : AppLocalizations.of(context)!.tapForMoreDetails,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
