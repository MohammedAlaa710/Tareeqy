import 'package:flutter/material.dart';
import 'package:tareeqy_metro/firebasemetro/Route.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TripDetails extends StatefulWidget {
  MetroRoute route = MetroRoute();
  TripDetails({super.key, required this.route});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  // backgroundColor: Color.fromARGB(255, 164, 53, 53)
  // Color cardColor = Color.fromARGB(255, 188, 143, 143);
  Color cardColor = Colors.white;
  Color textColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(widget.route.routeStations.first,
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
                const Text('  To  ',
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold)),
                Text(widget.route.routeStations.last,
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF073042)),
      body: Stack(
        //physics: BouncingScrollPhysics(),
        //fit: StackFit.expand,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: TripDescription(widget.route.line,
                      widget.route.direction, widget.route.transit),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              //offset: Offset(0, 5),
                            )
                          ],
                          color: cardColor,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.subway,
                              size: 50,
                              color: Color(0xFF00796B),
                            ),
                            const Text(
                              'Stations',
                              style: TextStyle(
                                color: Color(0xFF00796B),
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              height: 30,
                              child: Center(
                                child: Text(
                                  widget.route.routeStations.length.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    /////////////////////////////////////////////////////////////////////
                    if (widget.route.transit != '')
                      const SizedBox(
                        width: 10,
                      ),
                    ///////////////////////////////////////////////////
                    if (widget.route.transit != '')
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              //offset: Offset(0, 0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: cardColor,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              color: Color(0xFF00796B),
                              Icons.transit_enterexit_outlined,
                              size: 50,
                            ),
                            const Text(
                              'Interchange Station',
                              style: TextStyle(
                                color: Color(0xFF00796B),
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Container(
                              //color: Colors.grey[300],
                              child: Center(
                                child: Text(
                                  widget.route.transit,
                                  style: TextStyle(
                                    fontSize: 20,
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
              const Divider(
                color: Colors.black,
                endIndent: 10,
                indent: 10,
              ),
            ],
          ),
/*           Padding(
            padding: const EdgeInsets.all(8.0),
            child: 
            ListView.separated(
              separatorBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 23.0, right: 50.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    width: double.infinity,
                    height: 1.0,
                  ),
                );
              },
              //physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.route.routeStations.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    if (widget.route.routeStations[index] ==
                            widget.route.transit ||
                        index == 0 ||
                        index == (widget.route.routeStations.length - 1))
                      Icon(Icons.circle, color: Colors.red),
                    //SizedBox(height: 40),
                    if (widget.route.routeStations[index] ==
                            widget.route.transit ||
                        index == 0 ||
                        index == (widget.route.routeStations.length - 1))
                      Text(
                        widget.route.routeStations[index],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    if (widget.route.routeStations[index] !=
                            widget.route.transit &&
                        index != 0 &&
                        index != (widget.route.routeStations.length - 1))
                      Icon(Icons.circle_outlined, color: Colors.red),
                    //SizedBox(height: 40),
                    if (widget.route.routeStations[index] !=
                            widget.route.transit &&
                        index != 0 &&
                        index != (widget.route.routeStations.length - 1))
                      Text(
                        widget.route.routeStations[index],
                        style: TextStyle(fontSize: 20),
                      ),
                  ],
                );
              },
            ),
          ),
 */

          DraggableScrollableSheet(
            initialChildSize: Draggablenumber(),
            minChildSize: Draggablenumber(),
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
                          )),
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
                          //SizedBox(height: 40),
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
                          //SizedBox(height: 40),
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
        ],
      ),
    );
  }

  double Draggablenumber() {
    double extra = 0;
    if (widget.route.direction[0] == 'Shoubra El-Kheima Direction' ||
        widget.route.direction[1] == 'Shoubra El-Kheima Direction' ||
        widget.route.direction[1] == 'Rod El Farag Corridor Direction' ||
        widget.route.direction[0] == 'Rod El Farag Corridor Direction' ||
        widget.route.direction[1] == 'Adli Mansour Direction' ||
        widget.route.direction[0] == 'Adli Mansour Direction' ||
        widget.route.transit == 'Al-Shohada') {
      extra = 0.04;
    }
    if (widget.route.transit == '') {
      return 0.67 - extra;
    } else {
      return 0.6 - extra;
    }
  }

  Widget TripDescription(
      List<int> line, List<String> dircetion, String transit) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 7,
                //offset: Offset(0, 5),
              )
            ],
            borderRadius: BorderRadius.circular(8),
            color: cardColor,
          ),
          width: 370,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trip Desription:',
                style: TextStyle(
                    color: Color(0xFF00796B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              if (transit != '')
                // ignore: prefer_interpolation_to_compose_strings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AutoSizeText(
                    // ignore: prefer_interpolation_to_compose_strings
                    'You will take Line ' +
                        line[0].toString() +
                        ' in ' +
                        dircetion[0] +
                        ' till you reach ' +
                        transit +
                        ' station then you will change to line ' +
                        line[1].toString() +
                        " in " +
                        dircetion[1],
                    style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              if (transit == '')
                // ignore: prefer_interpolation_to_compose_strings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: AutoSizeText(
                    // ignore: prefer_interpolation_to_compose_strings
                    'you will take Line ' +
                        line[0].toString() +
                        " in " +
                        dircetion[0],
                    style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}
