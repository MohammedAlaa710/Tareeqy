import 'package:flutter/material.dart';
import 'package:tareeqy_metro/firebasemetro/Route.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TripDetails extends StatefulWidget {
  final MetroRoute route;

  TripDetails({Key? key, required this.route}) : super(key: key);

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  Color cardColor = Colors.white;
  Color textColor = Colors.black;
  Color appBarColor = Color(0xFF073042);
  Color accentColor = Color(0xFF00796B);
  Color errorColor = Color(0xFFB31312);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(widget.route.routeStations.first,
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.05)),
              const Text('  To  ',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Text(widget.route.routeStations.last,
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.05)),
            ],
          ),
        ),
        backgroundColor: appBarColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TripDescription(
                widget.route.line,
                widget.route.direction,
                widget.route.transit,
                screenWidth,
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: screenWidth * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 0.5,
                            blurRadius: 4,
                          )
                        ],
                        color: cardColor,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.subway,
                            size: screenWidth * 0.12,
                            color: accentColor,
                          ),
                          Text(
                            'Stations',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.08,
                            child: Center(
                              child: Text(
                                widget.route.routeStations.length.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.05,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.route.transit != '')
                    SizedBox(width: 10),
                  if (widget.route.transit != '')
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 0.5,
                              blurRadius: 4,
                            )
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: cardColor,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.transit_enterexit_outlined,
                              size: screenWidth * 0.12,
                              color: accentColor,
                            ),
                            Text(
                              'Interchange Station',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            Container(
                              child: Center(
                                child: Text(
                                  widget.route.transit,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(
                color: Colors.black26,
                endIndent: 10,
                indent: 10,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.route.routeStations.length,
                itemBuilder: (context, index) {
                  bool isTransit = widget.route.routeStations[index] ==
                      widget.route.transit;
                  bool isFirst = index == 0;
                  bool isLast = index == widget.route.routeStations.length - 1;
                  bool afterTransit = widget.route.transit != '' &&
                      index > widget.route.routeStations.indexOf(widget.route.transit);

                  return Padding(
                    padding: EdgeInsets.only(
                      left: isTransit || afterTransit ? 60.0 : 0.0,
                      bottom: 10.0,
                    ),
                    child: StationCard(
                      stationName: widget.route.routeStations[index],
                      isTransit: isTransit,
                      isFirst: isFirst,
                      isLast: isLast,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget TripDescription(List<int> line, List<String> direction, String transit,
      double screenWidth) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius:0.5,
                blurRadius: 5,
              )
            ],
            borderRadius: BorderRadius.circular(8),
            color: cardColor,
          ),
          width: screenWidth * 0.95,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Description:',
                style: TextStyle(
                    color: accentColor,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold),
              ),
              if (transit != '')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AutoSizeText(
                    'You will take Line ${line[0]} in ${direction[0]} till you reach $transit station then you will change to line ${line[1]} in ${direction[1]}',
                    style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: textColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              if (transit == '')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AutoSizeText(
                    'You will take Line ${line[0]} in ${direction[0]}',
                    style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: textColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class StationCard extends StatelessWidget {
  final String stationName;
  final bool isTransit;
  final bool isFirst;
  final bool isLast;

  const StationCard({
    Key? key,
    required this.stationName,
    required this.isTransit,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color accentColor = Color(0xFF00796B);
    Color errorColor = Color(0xFFB31312);

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                if (!isFirst) VerticalDividerLine(),
                if (isFirst) const SizedBox(height: 10),
                Icon(
                  isFirst
                      ? Icons.location_on
                      : isLast
                          ? Icons.flag
                          : isTransit
                              ? Icons.transfer_within_a_station
                              : Icons.circle,
                  color: isFirst || isLast || isTransit ? errorColor : accentColor,
                  size: 24.0,
                ),
                if (!isLast) VerticalDividerLine(),
                if (isLast) const SizedBox(height: 10),
              ],
            ),
            SizedBox(width: 20),
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

class VerticalDividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
