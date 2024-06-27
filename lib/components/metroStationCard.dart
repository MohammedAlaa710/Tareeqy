import 'package:flutter/material.dart';
import 'package:tareeqy_metro/components/VerticalDividerLine.dart';

class StationCard extends StatelessWidget {
  final String stationName;
  final bool isTransit;
  final bool isFirst;
  final bool isLast;

  const StationCard({
    super.key,
    required this.stationName,
    required this.isTransit,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor = const Color(0xFF00796B);
    Color errorColor = const Color(0xFFB31312);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                if (!isFirst) const VerticalDividerLine(),
                if (isFirst) const SizedBox(height: 10),
                Icon(
                  isFirst
                      ? Icons.location_on
                      : isLast
                          ? Icons.flag
                          : isTransit
                              ? Icons.transfer_within_a_station
                              : Icons.circle,
                  color:
                      isFirst || isLast || isTransit ? errorColor : accentColor,
                  size: 24.0,
                ),
                if (!isLast) const VerticalDividerLine(),
                if (isLast) const SizedBox(height: 10),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stationName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isFirst || isLast || isTransit
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
