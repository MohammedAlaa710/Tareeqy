// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/components/searchbar.dart';
import 'package:tareeqy_metro/firebasemetro/Route.dart';
import 'package:tareeqy_metro/firebasemetro/tripdetailsScreen.dart';
//import 'package:tareeqy_metro/maps/getNearestStation.dart';
import 'package:tareeqy_metro/maps/track_location.dart';

class MetroScreen extends StatefulWidget {
  const MetroScreen({super.key});

  @override
  State<MetroScreen> createState() => _MetroScreenState();
}

class _MetroScreenState extends State<MetroScreen> {
  List<QueryDocumentSnapshot> stations = [];
  String selectedValue1 = '';
  String selectedValue2 = '';
  bool timePrice = false;
  final List<String> transitStation12 = const ['Sadat', 'Al-Shohada'];
  final String transitStation23 = 'Attaba';
  final String transitStation13 = 'Gamal Abd Al-Naser';

  GetStations() async {
    QuerySnapshot metroLine1 = await FirebaseFirestore.instance
        .collection('Metro_Line_1')
        .orderBy('number')
        .get();
    QuerySnapshot metroLine2 = await FirebaseFirestore.instance
        .collection('Metro_Line_2')
        .orderBy('number')
        .get();
    QuerySnapshot metroLine3 = await FirebaseFirestore.instance
        .collection('Metro_Line_3')
        .orderBy('number')
        .get();
    stations.addAll(metroLine1.docs);
    stations.addAll(metroLine2.docs);
    stations.addAll(metroLine3.docs);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    GetStations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.white,
        title: Text(
          'Metro',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      //0xff2A2D2E,, Color.fromARGB(150, 0, 63, 171),
      /* appBar: AppBar(
          title: Text(
            'Metro',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 14, 72, 171)), */
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Image(
              image: AssetImage("assets/images/metroIconn.jpg"),
              height: 220,
              width: 220,
            ),
            ////////////////////////////////////////////////////////////////////////////
            //const SizedBox(height: 0),
            ////////////////////////////////////////////////////////////////////////////
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: MyDropdownSearch(
                fromto: 'From',
                items: getStations()
                    .where((String x) => x != selectedValue2)
                    .toSet(),
                selectedValue: selectedValue1,
                onChanged: (value) {
                  setState(() {
                    selectedValue1 = value!;
                  });
                },
              ),
            ),
            ////////////////////////////////////////////////////////////////////////////
            const SizedBox(height: 10),
            ////////////////////////////////////////////////////////////////////////////
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: MyDropdownSearch(
                fromto: 'To',
                items: getStations()
                    .where((String x) => x != selectedValue1)
                    .toSet(),
                selectedValue: selectedValue2,
                onChanged: (value) {
                  setState(() {
                    selectedValue2 = value!;
                  });
                },
              ),
            ),
            ////////////////////////////////////////////////////////////////////////////
            const SizedBox(height: 10),
            ////////////////////////////////////////////////////////////////////////////
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 40, 53, 173),
                minimumSize: Size(150, 50),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  // This gives the button squared edges
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedValue1 = '';
                  selectedValue2 = '';
                });
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            ////////////////////////////////////////////////////////////////////////////
            const SizedBox(height: 10),
            ////////////////////////////////////////////////////////////////////////////
            if (selectedValue1 != '' && selectedValue2 != '')
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                height: 150,
                child: Row(
                  children: [
                    Spacer(
                      flex: 1,
                    ),
                    ///////////////////////////////////////////////////////////////////////
                    Container(
                      padding: EdgeInsets.only(left: 15, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.attach_money,
                            size: 70,
                          ),
                          const Text(
                            'Ticket Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                metroPrice(selectedValue1, selectedValue2),
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
                    ///////////////////////////////////////////////////////////////////////
                    Spacer(
                      flex: 1,
                    ),
                    ///////////////////////////////////////////////////////////////////////

                    VerticalDivider(
                      thickness: 1,
                      width: 20,
                      color: Colors.black,
                      endIndent: 10,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timelapse,
                            size: 70,
                          ),
                          const Text(
                            'Estimated Time',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                metroTime(selectedValue1, selectedValue2),
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
                    ///////////////////////////////////////////////////////////////////////
                    Spacer(
                      flex: 1,
                    ),
                    ///////////////////////////////////////////////////////////////////////
                  ],
                ),
              ),
            ////////////////////////////////////////////////////////////////////////////
            const SizedBox(height: 20),
            ////////////////////////////////////////////////////////////////////////////

            ////////////////////////////////////////////////////////////////////////////
            const SizedBox(height: 10),
            ////////////////////////////////////////////////////////////////////////////
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 30,
                          color: Color.fromARGB(255, 14, 72, 171),
                        ),
                      ),
                      //const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Color.fromARGB(255, 14, 72, 171),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Color.fromARGB(255, 40, 53, 173),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return TrackLocation();
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'Nearest Station?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),

                      //han7ot tripxxxx
                      if (selectedValue1 != '' && selectedValue2 != '')
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Color.fromARGB(255, 14, 72, 171),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 40, 53, 173),
                                minimumSize: Size(double.infinity,
                                    50), // Adjust width to fit the available space
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return TripDetails(
                                        route: GetRoute(
                                            selectedValue1, selectedValue2),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                'Trip Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ////////////////////////////////////////////////////////////////////////////
            //const SizedBox(height: 20),
            ////////////////////////////////////////////////////////////////////////////
          ],
        ),
      ),
    );
  }

  List<String> getStations() {
    List<String> stationName = [];
    for (int i = 0; i < stations.length; i++) {
      stationName.add(stations[i]['name']);
    }
    return stationName;
  }

//0 1 2 3 4
//1 2 3 4
  String metroPrice(String from, String to) {
    if (GetRoute(from, to).routeStations.length - 1 < 10) {
      return '6 egp';
    } else if (GetRoute(from, to).routeStations.length - 1 < 17) {
      return '8 egp';
    } else if (GetRoute(from, to).routeStations.length - 1 < 24) {
      return '12 egp';
    } else {
      return '15 egp';
    }
  }

  String metroTime(String from, String to) {
    return ("${(GetRoute(from, to).routeStations.length - 1) * 2.5} min");
  }

  int getStationsIndx(String stationName) {
    for (int i = 0; i < stations.length; i++) {
      if (stations[i]['name'] == stationName) {
        return i;
      }
    }

    return 0;
  }

  int getCollection(int indx) {
    if (indx < 35) {
      return 1;
    } else if (indx < 55) {
      return 2;
    } else {
      return 3;
    }
  }

//t3alaa
  MetroRoute GetRoute(String from, String to) {
    MetroRoute route = MetroRoute();
    int fromIndx = getStationsIndx(from);
    int toIndx = getStationsIndx(to);
    int fromCollection = getCollection(fromIndx);
    int toCollection = getCollection(toIndx);
    if ((from == transitStation12[0] ||
            from == transitStation12[1] ||
            from == transitStation13 ||
            from == transitStation23 ||
            from == 'Mohamed Naguib') &&
        (to == transitStation12[0] ||
            to == transitStation12[1] ||
            to == transitStation13 ||
            to == transitStation23 ||
            to == 'Mohamed Naguib')) {
      fromCollection = TransitIndx(from, to)[0];
      toCollection = TransitIndx(from, to)[0];
      fromIndx = TransitIndx(from, to)[1];
      toIndx = TransitIndx(from, to)[2];
    }
    //done 1
    if (fromCollection == toCollection) {
      for (int i = fromIndx;
          fromIndx < toIndx ? i < toIndx + 1 : i > toIndx - 1;
          fromIndx < toIndx ? i++ : i--) {
        route.routeStations.add(stations[i]['name']);
        route.direction.add(getDirection(fromIndx, toIndx, toCollection));
        route.line.add(toCollection);
      }
    } else {
      //done 2
      if ((fromCollection == 1 && toCollection == 3) ||
          (fromCollection == 3 && toCollection == 1)) {
        List<int> naser = [];
        if (fromCollection == 1) {
          naser.add(19);
          naser.add(74);
        } else {
          naser.add(74);
          naser.add(19);
        }
        for (int i = fromIndx;
            fromIndx < naser[0]
                ? (stations[i]['name'] != transitStation13 && i < naser[0])
                : (stations[i]['name'] != transitStation13 && i > naser[0]);
            fromIndx < naser[0] ? i++ : i--) {
          route.routeStations.add(stations[i]['name']);
        }
        route.direction
            .add(getDirection(fromIndx, naser[0], getCollection(naser[0])));
        route.line.add(getCollection(naser[0]));
        route.routeStations.add(stations[naser[0]]['name']);
        route.transit = stations[naser[0]]['name'];
        int inc = naser[1] < toIndx ? 1 : -1;

        for (int i = naser[1] + inc;
            naser[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
            naser[1] < toIndx ? i++ : i--) {
          route.routeStations.add(stations[i]['name']);
        }
        route.direction
            .add(getDirection(naser[1], toIndx, getCollection(toIndx)));
        route.line.add(getCollection(toIndx));
      }
      ////////////////////////////////////////////////////////////////////////////////////////////////
      //done 3
      else if ((fromCollection == 2 && toCollection == 3) ||
          (fromCollection == 3 && toCollection == 2)) {
        List<int> ataba = [];
        if (fromCollection == 2) {
          ataba.add(46);
          ataba.add(73);
        } else {
          ataba.add(73);
          ataba.add(46);
        }
        for (int i = fromIndx;
            fromIndx < ataba[0]
                ? (stations[i]['name'] != transitStation13 && i < ataba[0])
                : (stations[i]['name'] != transitStation13 && i > ataba[0]);
            fromIndx < ataba[0] ? i++ : i--) {
          route.routeStations.add(stations[i]['name']);
        }
        route.direction
            .add(getDirection(fromIndx, ataba[0], getCollection(ataba[0])));
        route.line.add(getCollection(ataba[0]));
        route.routeStations.add(stations[ataba[0]]['name']);
        route.transit = stations[ataba[0]]['name'];
        int inc = ataba[1] < toIndx ? 1 : -1;

        for (int i = ataba[1] + inc;
            ataba[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
            ataba[1] < toIndx ? i++ : i--) {
          route.routeStations.add(stations[i]['name']);
        }
        route.direction
            .add(getDirection(ataba[1], toIndx, getCollection(toIndx)));
        route.line.add(getCollection(toIndx));
      }
      /////////////////////////////////////////////////////////////////////////////////////////////////
      else if ((fromCollection == 1 && toCollection == 2) ||
          (fromCollection == 2 && toCollection == 1)) {
        List<int> sadat = [];
        List<int> shohada = [];
        if (fromCollection == 2 && fromIndx < 44) {
          //el from fe line 2 abl el sadat
          sadat.add(44);
          sadat.add(18);
        } else if (fromCollection == 1 && fromIndx < 18) {
          // el from fe line 1 abl el sadat
          sadat.add(18);
          sadat.add(44);
        }
        if (fromCollection == 2 && fromIndx > 47) {
          // el from fe line 2 b3d el shohada
          shohada.add(47);
          shohada.add(21);
        } else if (fromCollection == 1 && fromIndx > 21) {
          // el from fe line 1 b3d el shohada
          shohada.add(21);
          shohada.add(47);
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////
        ///done 4.1
        if (sadat.isNotEmpty) {
          for (int i = fromIndx;
              fromIndx < sadat[0]
                  ? (stations[i]['name'] != transitStation13 && i < sadat[0])
                  : (stations[i]['name'] != transitStation13 && i > sadat[0]);
              fromIndx < sadat[0] ? i++ : i--) {
            route.routeStations.add(stations[i]['name']);
          }
          route.direction
              .add(getDirection(fromIndx, sadat[0], getCollection(sadat[0])));
          route.line.add(getCollection(sadat[0]));
          route.routeStations.add(stations[sadat[0]]['name']);
          route.transit = stations[sadat[0]]['name'];
          int inc = sadat[1] < toIndx ? 1 : -1;
          for (int i = sadat[1] + inc;
              sadat[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
              sadat[1] < toIndx ? i++ : i--) {
            route.routeStations.add(stations[i]['name']);
          }
          route.direction
              .add(getDirection(sadat[1], toIndx, getCollection(toIndx)));
          route.line.add(getCollection(toIndx));
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////
        ///done 4.2
        else if (shohada.isNotEmpty) {
          for (int i = fromIndx;
              fromIndx < shohada[0]
                  ? (stations[i]['name'] != transitStation13 && i < shohada[0])
                  : (stations[i]['name'] != transitStation13 && i > shohada[0]);
              fromIndx < shohada[0] ? i++ : i--) {
            route.routeStations.add(stations[i]['name']);
          }
          route.direction.add(
              getDirection(fromIndx, shohada[0], getCollection(shohada[0])));
          route.line.add(getCollection(shohada[0]));
          route.routeStations.add(stations[shohada[0]]['name']);
          route.transit = stations[shohada[0]]['name'];
          int inc1 = shohada[1] < toIndx ? 1 : -1;
          for (int i = shohada[1] + inc1;
              shohada[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
              shohada[1] < toIndx ? i++ : i--) {
            route.routeStations.add(stations[i]['name']);
          }
          route.direction
              .add(getDirection(shohada[1], toIndx, getCollection(toIndx)));
          route.line.add(getCollection(toIndx));
        }
        ///////////////////////////////////////////////////////////////////////////////////////////
        ///el gy hwa el statinos el fl nos
        else {
          ////////////////////////////////////////////////////////////////////
          ///ma7tat el khat el awl => naser, orabi
          if ((from == 'Gamal Abd Al-Naser' || from == 'Orabi') &&
              (to == 'Mohamed Naguib' || toIndx < 44)) {
            for (int i = fromIndx;
                fromIndx < 18
                    ? (stations[i]['name'] != transitStation12[0] && i < 18)
                    : (stations[i]['name'] != transitStation12[0] && i > 18);
                fromIndx < 18 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 18, getCollection(18)));
            route.line.add(getCollection(18));
            route.routeStations.add(stations[18]['name']);
            route.transit = stations[18]['name'];
            int inc = 44 < toIndx ? 1 : -1;
            for (int i = 44 + inc;
                44 < toIndx ? (i <= toIndx) : (i >= toIndx);
                44 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(44, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          } else if ((from == 'Gamal Abd Al-Naser' || from == 'Orabi') &&
              (to == 'Attaba' || toIndx > 47)) {
            ///iiiii
            for (int i = fromIndx;
                fromIndx < 21
                    ? (stations[i]['name'] != transitStation12[1] && i < 21)
                    : (stations[i]['name'] != transitStation12[1] && i > 21);
                fromIndx < 21 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 21, getCollection(21)));
            route.line.add(getCollection(21));
            route.routeStations.add(stations[21]['name']);
            route.transit = stations[21]['name'];
            int inc1 = 47 < toIndx ? 1 : -1;
            for (int i = 47 + inc1;
                47 < toIndx ? (i <= toIndx) : (i >= toIndx);
                47 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(47, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          }
          ////////////////////////////////////////////////////////////////////
          ///ma7tat el khat el tani naguib, awl if sadat w tani if shohada
          else if ((from == 'Mohamed Naguib') &&
              (to == 'Gamal Abd Al-Naser' || toIndx < 18)) {
            for (int i = fromIndx;
                fromIndx < 44
                    ? (stations[i]['name'] != transitStation12[0] && i < 44)
                    : (stations[i]['name'] != transitStation12[0] && i > 44);
                fromIndx < 44 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 44, getCollection(44)));
            route.line.add(getCollection(44));
            route.routeStations.add(stations[44]['name']);
            route.transit = stations[44]['name'];
            int inc = 18 < toIndx ? 1 : -1;
            for (int i = 18 + inc;
                18 < toIndx ? (i <= toIndx) : (i >= toIndx);
                18 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(18, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          } else if ((from == 'Mohamed Naguib') &&
              (to == 'Orabi' || toIndx > 21)) {
            for (int i = fromIndx;
                fromIndx < 47
                    ? (stations[i]['name'] != transitStation12[1] && i < 47)
                    : (stations[i]['name'] != transitStation12[1] && i > 47);
                fromIndx < 47 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 47, getCollection(47)));
            route.line.add(getCollection(47));
            route.routeStations.add(stations[47]['name']);
            route.transit = stations[47]['name'];
            int inc1 = 21 < toIndx ? 1 : -1;
            for (int i = 21 + inc1;
                21 < toIndx ? (i <= toIndx) : (i >= toIndx);
                21 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(21, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          }
          ////////////////////////////////////////////////////////////////////
          ///ma7tat el khat el tani naguib, awl if sadat w tani if shohada
          else if ((from == 'Attaba') && (toIndx < 18)) {
            for (int i = fromIndx;
                fromIndx < 44
                    ? (stations[i]['name'] != transitStation12[0] && i < 44)
                    : (stations[i]['name'] != transitStation12[0] && i > 44);
                fromIndx < 44 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 44, getCollection(44)));
            route.line.add(getCollection(44));
            route.routeStations.add(stations[44]['name']);
            route.transit = stations[44]['name'];
            int inc = 18 < toIndx ? 1 : -1;
            for (int i = 18 + inc;
                18 < toIndx ? (i <= toIndx) : (i >= toIndx);
                18 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(18, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(18));
          } else if ((from == 'Attaba') &&
              (to == 'Gamal Abd Al-Naser' || to == 'Orabi' || toIndx > 21)) {
            for (int i = fromIndx;
                fromIndx < 47
                    ? (stations[i]['name'] != transitStation12[1] && i < 47)
                    : (stations[i]['name'] != transitStation12[1] && i > 47);
                fromIndx < 47 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 47, getCollection(47)));
            route.line.add(getCollection(47));
            route.routeStations.add(stations[47]['name']);
            route.transit = stations[47]['name'];
            int inc1 = 21 < toIndx ? 1 : -1;
            for (int i = 21 + inc1;
                21 < toIndx ? (i <= toIndx) : (i >= toIndx);
                21 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(21, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          }
        }
      }
    }

    return route;
  }

/*   void halop(List<String> route) {
    for (int i = 0; i < route.length; i++) {
      print(route[i]);
    }
  }

  void halop2() {
    for (int i = 0; i < stations.length; i++) {
      print(i.toString() + ": " + stations[i]['name']);
    }
  } */

  List<int> TransitIndx(String from, String to) {
    if ((from == transitStation23 || from == transitStation13) &&
        (to == transitStation23 || to == transitStation13)) {
      if (from == transitStation23) {
        return [3, 73, 74];
      } else {
        return [3, 74, 73];
      }
    } else if ((from == transitStation23 || from == transitStation12[0]) &&
        (to == transitStation23 || to == transitStation12[0])) {
      if (from == transitStation23) {
        return [2, 46, 44];
      } else {
        return [2, 44, 46];
      }
    } else if ((from == transitStation23 || from == transitStation12[1]) &&
        (to == transitStation23 || to == transitStation12[1])) {
      if (from == transitStation23) {
        return [2, 46, 47];
      } else {
        return [2, 47, 46];
      }
    } else if ((from == 'Mohamed Naguib' || from == transitStation12[0]) &&
        (to == 'Mohamed Naguib' || to == transitStation12[0])) {
      if (from == 'Mohamed Naguib') {
        return [2, 45, 44];
      } else {
        return [2, 44, 45];
      }
    } else if ((from == 'Mohamed Naguib' || from == transitStation12[1]) &&
        (to == 'Mohamed Naguib' || to == transitStation12[1])) {
      if (from == 'Mohamed Naguib') {
        return [2, 45, 47];
      } else {
        return [2, 47, 45];
      }
    }
    return [
      getCollection(getStationsIndx(from)),
      getStationsIndx(from),
      getStationsIndx(to)
    ];
  }

  String getDirection(int fromIndx, int toIndx, int toCollection) {
    if (fromIndx > toIndx) {
      switch (toCollection) {
        case 1:
          return 'Helwan Direction';

        case 2:
          return 'El-Monib Direction';
        case 3:
          return 'Adli Mansour Direction';
        default:
          return 'Unknown destination line';
      }
    } else {
      switch (toCollection) {
        case 1:
          return 'El-Marg Direction';

        case 2:
          return 'Shoubra El-Kheima Direction';

        case 3:
          return 'Rod El Farag Corridor Direction';

        default:
          return 'Unknown destination line';
      }
    }
  }
}
// line 1 => 0/34
// line 2 => 35/54
// line 3 => 55/77
