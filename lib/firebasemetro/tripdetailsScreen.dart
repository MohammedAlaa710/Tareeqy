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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Row(
            children: [
              Text(widget.route.routeStations.first,
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Text('  To  ',
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold)),
              Text(widget.route.routeStations.last,
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 14, 72, 171)),
      body: Stack(
        //physics: BouncingScrollPhysics(),
        //fit: StackFit.expand,

        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xff0048AB),
                        width: 5,
                      )),
                  child: TripDescription(widget.route.line,
                      widget.route.direction, widget.route.transit),
                ),
              ),
              Row(
                children: [
                  /////////////////////////////////////////////////////////////////////////
                  Spacer(
                    flex: 1,
                  ),
                  ///////////////////////////////////////////////////////////////////////

                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xff0048AB),
                          width: 5,
                        )),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.subway_outlined,
                          size: 50,
                        ),
                        const Text(
                          'Stations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 30,
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(
                              widget.route.routeStations.length.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  /////////////////////////////////////////////////////////////////////////
                  const Spacer(
                    flex: 1,
                  ),
                  ///////////////////////////////////////////////////////////////////////
                  const VerticalDivider(
                    thickness: 1,
                    width: 20,
                    color: Colors.black,
                    endIndent: 10,
                    indent: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xff0048AB),
                          width: 5,
                        )),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.transit_enterexit_outlined,
                          size: 50,
                        ),
                        const Text(
                          'Interchange Station',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(
                              widget.route.transit,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  /////////////////////////////////////////////////////////////////////////
                  const Spacer(
                    flex: 1,
                  ),
                  ///////////////////////////////////////////////////////////////////////
                ],
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
            initialChildSize: 0.54,
            minChildSize: 0.54,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(color: Colors.grey),
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: widget.route.routeStations.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Divider(
                              thickness: 5,
                            ),
                          ),
                          Text(
                            'Stations',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          Card(
                              child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.red),
                              Text(
                                widget.route.routeStations[0],
                                style: TextStyle(fontSize: 20),
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

  Widget TripDescription(
      List<int> line, List<String> dircetion, String transit) {
    return Column(
      children: [
        Container(
          width: 370,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trip Desription:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18),
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
                    style: TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}
