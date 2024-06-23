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
  final GlobalKey part1Key = GlobalKey();
  final GlobalKey descKey = GlobalKey();
  final GlobalKey appbarKey = GlobalKey();
  final GlobalKey dividerKey = GlobalKey();
  late double _widgetHeight;
  late double _deskHeight;
  //late double _dividerHeight;
  //late double _appbarHeight;
  late double _screenHeight; // Get the ratio to set as max size.
  late double requiredHeight = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _widgetHeight = getWidgetHeight(part1Key);
      _deskHeight = getWidgetHeight(descKey);
      //_dividerHeight = getWidgetHeight(dividerKey);
      //_appbarHeight = getWidgetHeight(appbarKey);
      _screenHeight = screenHeight(context);
      requiredHeight = 0.94 - (((_widgetHeight + _deskHeight) / _screenHeight));
      setState(() {}); // Update the UI with the new height
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        key: appbarKey,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(widget.route.routeStations.first,
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.05)),
              const Text('  To  ',
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold)),
              Text(widget.route.routeStations.last,
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.05)),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF073042),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              ///////////////////////////////////////////////////////////////////////////
              //Part1
              Padding(
                key: descKey,
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: TripDescription(
                      widget.route.line,
                      widget.route.direction,
                      widget.route.transit,
                      screenWidth),
                ),
              ),
              Padding(
                key: part1Key,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
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
                              spreadRadius: 5,
                              blurRadius: 7,
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
                              color: Color(0xFF00796B),
                            ),
                            Text(
                              'Stations',
                              style: TextStyle(
                                color: Color(0xFF00796B),
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
                      const SizedBox(
                        width: 10,
                      ),
                    if (widget.route.transit != '')
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
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
                              color: Color(0xFF00796B),
                              Icons.transit_enterexit_outlined,
                              size: screenWidth * 0.12,
                            ),
                            Text(
                              'Interchange Station',
                              style: TextStyle(
                                color: Color(0xFF00796B),
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
                  ],
                ),
              ),

              ///end of part1
              ////////////////////////////////////////////////////////////////////////
              const Divider(
                color: Colors.black,
                endIndent: 10,
                indent: 10,
              ),
            ],
          ),
          ///////////////////////////////////////////////////////////////////////////
          ///part2
          DraggableScrollableSheet(
            initialChildSize: requiredHeight.clamp(0.1, 1.0),
            //kol ma el rakb bykbr bntl3 l fo2
            minChildSize: requiredHeight.clamp(0.1, 1.0),
            //dh el hyt8yr w lazm yb2 a2l mn el tani
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(color: Color(0xFF073042)),
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: widget.route.routeStations.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          const SizedBox(
                            width: 50,
                            child: Divider(
                              thickness: 5,
                            ),
                          ),
                          const Text(
                            'Stations',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          Card(
                            child: Row(
                              children: [
                                const Icon(Icons.circle, color: Colors.red),
                                Text(
                                  widget.route.routeStations[0],
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Card(
                      child: Row(
                        children: [
                          if (widget.route.routeStations[index] ==
                                  widget.route.transit ||
                              index == 0 ||
                              index == (widget.route.routeStations.length - 1))
                            const Icon(Icons.circle, color: Colors.red),
                          if (widget.route.routeStations[index] ==
                                  widget.route.transit ||
                              index == 0 ||
                              index == (widget.route.routeStations.length - 1))
                            Text(
                              widget.route.routeStations[index],
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          if (widget.route.routeStations[index] !=
                                  widget.route.transit &&
                              index != 0 &&
                              index != (widget.route.routeStations.length - 1))
                            const Icon(Icons.circle_outlined,
                                color: Colors.red),
                          if (widget.route.routeStations[index] !=
                                  widget.route.transit &&
                              index != 0 &&
                              index != (widget.route.routeStations.length - 1))
                            Text(
                              widget.route.routeStations[index],
                              style: const TextStyle(fontSize: 20),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          /// end of part2
          ///////////////////////////////////////////////////////////////////////
        ],
      ),
    );
  }

  double Draggablenumber() {
    double extra = 0.03;
    if (widget.route.direction[0] == 'Shoubra El-Kheima Direction' ||
        widget.route.direction[1] == 'Shoubra El-Kheima Direction' ||
        widget.route.direction[1] == 'Rod El Farag Corridor Direction' ||
        widget.route.direction[0] == 'Rod El Farag Corridor Direction' ||
        widget.route.direction[1] == 'Adli Mansour Direction' ||
        widget.route.direction[0] == 'Adli Mansour Direction' ||
        widget.route.transit == 'Al-Shohada') {
      extra = 0.00;
    }
    if (widget.route.transit == '') {
      return 0.67 - extra;
    } else {
      return 0.6 - extra;
    }
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
                spreadRadius: 5,
                blurRadius: 7,
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
                    color: Color(0xFF00796B),
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

  double getWidgetHeight(GlobalKey k) {
    final RenderBox renderBox =
        k.currentContext?.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
