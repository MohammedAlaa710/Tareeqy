// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/components/searchbar.dart';
import 'package:tareeqy_metro/firebasemetro/Route.dart';
import 'package:tareeqy_metro/firebasemetro/tripdetailsScreen.dart';

class MetroScreenbeforEdit extends StatefulWidget {
  const MetroScreenbeforEdit({super.key});

  @override
  State<MetroScreenbeforEdit> createState() => _MetroScreenbeforEditState();
}

class _MetroScreenbeforEditState extends State<MetroScreenbeforEdit> {
  List<QueryDocumentSnapshot> stations = [];
  String selectedValue1 = '';
  String selectedValue2 = '';
  bool timePrice = false;
  final List<String> transitStation12 = const ['Sadat', 'Al-Shohada'];
  final String transitStation23 = 'Attaba';
  final String transitStation13 = 'Gamal Abd Al-Naser';

  GetStations() async {
    QuerySnapshot metro_line_1 = await FirebaseFirestore.instance
        .collection('Metro_Line_1')
        .orderBy('number')
        .get();
    QuerySnapshot metro_line_2 = await FirebaseFirestore.instance
        .collection('Metro_Line_2')
        .orderBy('number')
        .get();
    QuerySnapshot metro_line_3 = await FirebaseFirestore.instance
        .collection('Metro_Line_3')
        .orderBy('number')
        .get();
    stations.addAll(metro_line_1.docs);
    stations.addAll(metro_line_2.docs);
    stations.addAll(metro_line_3.docs);
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
      backgroundColor: const Color(0xff2A2D2E),
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 14, 72, 171)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ////////////////////////////////////////////////////////////////////////////
              const SizedBox(height: 10),
              ////////////////////////////////////////////////////////////////////////////
              MyDropdownSearch(
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
              ////////////////////////////////////////////////////////////////////////////
              const SizedBox(height: 10),
              ////////////////////////////////////////////////////////////////////////////
              MyDropdownSearch(
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
              ////////////////////////////////////////////////////////////////////////////
              const SizedBox(height: 10),
              ////////////////////////////////////////////////////////////////////////////
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 14, 72, 171),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedValue1 = '';
                    selectedValue2 = '';
                    print(stations[47]['name'] + " ");
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
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ///////////////////////////////////////////////////////////////////////
                            Spacer(
                              flex: 1,
                            ),
                            ///////////////////////////////////////////////////////////////////////
                            Container(
                              width: 60,
                              padding: EdgeInsets.only(left: 15, top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.money,
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
                                    width: 70,
                                    height: 30,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text(
                                        metroPrice(
                                            selectedValue1, selectedValue2),
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
                              width: 60,
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
                                    width: 70,
                                    height: 30,
                                    color: Colors.grey[300],
                                    child: Center(
                                      // ignore: prefer_const_constructors
                                      child: Text(
                                        '15 mins',
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
                    ],
                  ),
                ),
              ////////////////////////////////////////////////////////////////////////////
              const SizedBox(height: 10),
              ////////////////////////////////////////////////////////////////////////////
              if (selectedValue1 != '' && selectedValue2 != '')
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(255, 14, 72, 171),
                    ),
                  ),
                  onPressed: () {
                    GetRoute(selectedValue1, selectedValue2);
/*                     Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return TripDetails(
                            stations: getStations(),
                          );
                        },
                      ),
                    ); */
                  },
                  child: const Text(
                    'Trip Details',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> getStations() {
    List<String> station_name = [];
    for (int i = 0; i < stations.length; i++) {
      station_name.add(stations[i]['name']);
    }
    return station_name;
  }

  String metroPrice(String from, String to) {
    if (GetRoute(from, to).routeStations.length - 1 < 10) {
      return '6 egp';
    } else if (GetRoute(from, to).routeStations.length - 1 < 17) {
      return '8 egp';
    } else {
      return '12 egp';
    }
  }

  String metroTime() {
    return ' ';
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

  MetroRoute GetRoute(String from, String to) {
    MetroRoute route = MetroRoute();
    int fromCollection = getCollection(getStationsIndx(from));
    int toCollection = getCollection(getStationsIndx(to));
    int fromIndx = getStationsIndx(from);
    int toIndx = getStationsIndx(to);
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
      fromCollection = TeansitIndx(from, to)[0];
      toCollection = TeansitIndx(from, to)[0];
      fromIndx = TeansitIndx(from, to)[1];
      toIndx = TeansitIndx(from, to)[2];
    }

    if (fromCollection == toCollection) {
      for (int i = fromIndx;
          fromIndx < toIndx ? i < toIndx + 1 : i > toIndx - 1;
          fromIndx < toIndx ? i++ : i--) {
        route.routeStations.add(stations[i]['name']);
        if (fromIndx > toIndx) {
          switch (toCollection) {
            case 1:
              print('etgah helwan');
              break;
            case 2:
              print('etgah El monib');
              break;
            case 3:
              print('etgah adly mansour');
              break;
            default:
              print('Unknown destination line');
          }
          i--;
        }
        if (fromIndx < toIndx) {
          switch (toCollection) {
            case 1:
              print('etgah el Marg');
              break;
            case 2:
              print('etgah shubra el kheima');
              break;
            case 3:
              print('etgah kitkat');
              break;
            default:
              print('Unknown destination line');
          }
          i++;
        }
      }
    } else {
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
                : (stations[i]['name'] != transitStation13 && i > naser[0]);) {
          route.routeStations.add(stations[i]['name']);
          if (fromIndx > naser[0]) {
            switch (getCollection(naser[0])) {
              case 1:
                print('etgah helwan');
                break;
              case 3:
                print('etgah adly mansour');
                break;
              default:
                print('Unknown destination line');
            }
            i--;
          }
          if (fromIndx < naser[0]) {
            switch (getCollection(naser[0])) {
              case 1:
                print('etgah el Marg');
                break;
              case 3:
                print('etgah kitkat');
                break;
              default:
                print('Unknown destination line');
            }
            i++;
          }
        }
        route.routeStations.add(stations[naser[0]]['name']);
        print(stations[naser[0]]['name']);
        int inc = naser[1] < toIndx ? 1 : -1;

        for (int i = naser[1] + inc;
            naser[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
            naser[1] < toIndx ? i++ : i--) {
          print('inside the second loop');
          route.routeStations.add(stations[i]['name']);
          if (naser[1] > toIndx) {
            switch (getCollection(toIndx)) {
              case 1:
                print('etgah helwan');
                break;
              case 3:
                print('etgah adly mansour');
                break;
              default:
                print('Unknown destination line');
            }
          }
          if (naser[1] < toIndx) {
            switch (getCollection(toIndx)) {
              case 1:
                print('etgah el Marg');
                break;
              case 3:
                print('etgah kitkat');
                break;
              default:
                print('Unknown destination line');
            }
          }
        }
        print(stations[toIndx]['name']);
        print('==========================');
      }
      ////////////////////////////////////////////////////////////////////////////////////////////////
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
        print('Line:' + getCollection(fromIndx).toString());
        print('Line:' + getCollection(toIndx).toString());
        for (int i = fromIndx;
            fromIndx < ataba[0]
                ? (stations[i]['name'] != transitStation13 && i < ataba[0])
                : (stations[i]['name'] != transitStation13 && i > ataba[0]);) {
          route.routeStations.add(stations[i]['name']);
          if (fromIndx > ataba[0]) {
            switch (getCollection(ataba[0])) {
              case 2:
                print('etgah el monib');
                break;
              case 3:
                print('etgah adly mansour');
                break;
              default:
                print('Unknown destination line');
            }
            i--;
          }
          if (fromIndx < ataba[0]) {
            switch (getCollection(ataba[0])) {
              case 2:
                print('etgah shoubra el kheima');
                break;
              case 3:
                print('etgah kitkat');
                break;
              default:
                print('Unknown destination line');
            }
            i++;
          }
        }
        route.routeStations.add(stations[ataba[0]]['name']);
        print(stations[ataba[0]]['name']);
        int inc = ataba[1] < toIndx ? 1 : -1;

        for (int i = ataba[1] + inc;
            ataba[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
            ataba[1] < toIndx ? i++ : i--) {
          print('inside the second loop');
          route.routeStations.add(stations[i]['name']);
          if (ataba[1] > toIndx) {
            switch (getCollection(toIndx)) {
              case 2:
                print('etgah el monib');
                break;
              case 3:
                print('etgah adly mansour');
                break;
              default:
                print('Unknown destination line');
            }
          }
          if (ataba[1] < toIndx) {
            switch (getCollection(toIndx)) {
              case 2:
                print('etgah shoubra el kheima');
                break;
              case 3:
                print('etgah kitkat');
                break;
              default:
                print('Unknown destination line');
            }
          }
        }
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
        if (sadat.isNotEmpty) {
          for (int i = fromIndx;
              fromIndx < sadat[0]
                  ? (stations[i]['name'] != transitStation13 && i < sadat[0])
                  : (stations[i]['name'] != transitStation13 &&
                      i > sadat[0]);) {
            route.routeStations.add(stations[i]['name']);
            if (fromIndx > sadat[0]) {
              switch (getCollection(sadat[0])) {
                case 1:
                  print('etgah helwan');
                  break;
                case 2:
                  print('etgah el monib');
                  break;
                default:
                  print('Unknown destination line');
              }
              i--;
            }
            if (fromIndx < sadat[0]) {
              switch (getCollection(sadat[0])) {
                case 1:
                  print('etgah el Marg');
                  break;
                case 2:
                  print('etgah shubra el kheima');
                  break;
                default:
                  print('Unknown destination line');
              }
              i++;
            }
          }
          route.routeStations.add(stations[sadat[0]]['name']);
          print(stations[sadat[0]]['name']);
          int inc = sadat[1] < toIndx ? 1 : -1;
          for (int i = sadat[1] + inc;
              sadat[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
              sadat[1] < toIndx ? i++ : i--) {
            print('inside the second loop');
            route.routeStations.add(stations[i]['name']);
            if (sadat[1] > toIndx) {
              switch (getCollection(toIndx)) {
                case 1:
                  print('etgah helwan');
                  break;
                case 2:
                  print('etgah el monib');
                  break;
                default:
                  print('Unknown destination line');
              }
            }
            if (sadat[1] < toIndx) {
              switch (getCollection(toIndx)) {
                case 1:
                  print('etgah el Marg');
                  break;
                case 2:
                  print('etgah shubra el kheima');
                  break;
                default:
                  print('Unknown destination line');
              }
            }
          }
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////
        else if (shohada.isNotEmpty) {
          for (int i = fromIndx;
              fromIndx < shohada[0]
                  ? (stations[i]['name'] != transitStation13 && i < shohada[0])
                  : (stations[i]['name'] != transitStation13 &&
                      i > shohada[0]);) {
            route.routeStations.add(stations[i]['name']);
            if (fromIndx > shohada[0]) {
              switch (getCollection(shohada[0])) {
                case 1:
                  print('etgah helwan');
                  break;
                case 2:
                  print('etgah el monib');
                  break;
                default:
                  print('Unknown destination line');
              }
              i--;
            }
            if (fromIndx < shohada[0]) {
              switch (getCollection(shohada[0])) {
                case 1:
                  print('etgah el Marg');
                  break;
                case 2:
                  print('etgah shubra el kheima');
                  break;
                default:
                  print('Unknown destination line');
              }
              i++;
            }
          }
          route.routeStations.add(stations[shohada[0]]['name']);
          print(stations[shohada[0]]['name']);
          int inc1 = shohada[1] < toIndx ? 1 : -1;
          for (int i = shohada[1] + inc1;
              shohada[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
              shohada[1] < toIndx ? i++ : i--) {
            print('inside the second loop');
            route.routeStations.add(stations[i]['name']);
            if (shohada[1] > toIndx) {
              switch (getCollection(toIndx)) {
                case 1:
                  print('etgah helwan');
                  break;
                case 2:
                  print('etgah el monib');
                  break;
                default:
                  print('Unknown destination line');
              }
            }
            if (shohada[1] < toIndx) {
              switch (getCollection(toIndx)) {
                case 1:
                  print('etgah el Marg');
                  break;
                case 2:
                  print('etgah shubra el kheima');
                  break;
                default:
                  print('Unknown destination line');
              }
            }
          }
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
                    : (stations[i]['name'] != transitStation12[0] && i > 18);) {
              route.routeStations.add(stations[i]['name']);
              if (fromIndx > 18) {
                switch (getCollection(18)) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i--;
              }
              if (fromIndx < 18) {
                switch (getCollection(18)) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i++;
              }
            }
            route.routeStations.add(stations[18]['name']);
            print(stations[18]['name']);
            int inc = 44 < toIndx ? 1 : -1;
            for (int i = 44 + inc;
                44 < toIndx ? (i <= toIndx) : (i >= toIndx);
                44 < toIndx ? i++ : i--) {
              print('inside the second loop');
              route.routeStations.add(stations[i]['name']);
              if (44 > toIndx) {
                switch (toCollection) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
              if (44 < toIndx) {
                switch (toCollection) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
            }
          } else if ((from == 'Gamal Abd Al-Naser' || from == 'Orabi') &&
              (to == 'Attaba' || toIndx > 47)) {
            for (int i = fromIndx;
                fromIndx < 21
                    ? (stations[i]['name'] != transitStation12[1] && i < 21)
                    : (stations[i]['name'] != transitStation12[1] && i > 21);) {
              route.routeStations.add(stations[i]['name']);
              if (fromIndx > 21) {
                switch (getCollection(21)) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i--;
              }
              if (fromIndx < 21) {
                switch (getCollection(21)) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i++;
              }
            }
            route.routeStations.add(stations[21]['name']);
            print(stations[21]['name']);
            int inc1 = 47 < toIndx ? 1 : -1;
            for (int i = 47 + inc1;
                47 < toIndx ? (i <= toIndx) : (i >= toIndx);
                47 < toIndx ? i++ : i--) {
              print('inside the second loop');
              route.routeStations.add(stations[i]['name']);
              if (47 > toIndx) {
                switch (getCollection(toIndx)) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
              if (47 < toIndx) {
                switch (getCollection(toIndx)) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
            }
          }
          ////////////////////////////////////////////////////////////////////
          ///ma7tat el khat el tani naguib, awl if sadat w tani if shohada
          else if ((from == 'Mohamed Naguib') &&
              (to == 'Gamal Abd Al-Naser' || toIndx < 18)) {
            for (int i = fromIndx;
                fromIndx < 44
                    ? (stations[i]['name'] != transitStation12[0] && i < 44)
                    : (stations[i]['name'] != transitStation12[0] && i > 44);) {
              route.routeStations.add(stations[i]['name']);
              if (fromIndx > 44) {
                switch (getCollection(44)) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i--;
              }
              if (fromIndx < 44) {
                switch (getCollection(44)) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i++;
              }
            }
            route.routeStations.add(stations[44]['name']);
            print(stations[44]['name']);
            int inc = 18 < toIndx ? 1 : -1;
            for (int i = 18 + inc;
                18 < toIndx ? (i <= toIndx) : (i >= toIndx);
                18 < toIndx ? i++ : i--) {
              print('inside the second loop');
              route.routeStations.add(stations[i]['name']);
              if (18 > toIndx) {
                switch (toCollection) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
              if (18 < toIndx) {
                switch (toCollection) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
            }
          } else if ((from == 'Mohamed Naguib') &&
              (to == 'Orabi' || toIndx > 21)) {
            for (int i = fromIndx;
                fromIndx < 47
                    ? (stations[i]['name'] != transitStation12[1] && i < 47)
                    : (stations[i]['name'] != transitStation12[1] && i > 47);) {
              route.routeStations.add(stations[i]['name']);
              if (fromIndx > 47) {
                switch (getCollection(47)) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i--;
              }
              if (fromIndx < 47) {
                switch (getCollection(47)) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i++;
              }
            }
            route.routeStations.add(stations[47]['name']);
            print(stations[47]['name']);
            int inc1 = 21 < toIndx ? 1 : -1;
            for (int i = 21 + inc1;
                21 < toIndx ? (i <= toIndx) : (i >= toIndx);
                21 < toIndx ? i++ : i--) {
              print('inside the second loop');
              route.routeStations.add(stations[i]['name']);
              if (21 > toIndx) {
                switch (getCollection(toIndx)) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
              if (21 < toIndx) {
                switch (getCollection(toIndx)) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
            }
          }
          ////////////////////////////////////////////////////////////////////
          ///ma7tat el khat el tani naguib, awl if sadat w tani if shohada
          else if ((from == 'Attaba') && (toIndx < 18)) {
            for (int i = fromIndx;
                fromIndx < 44
                    ? (stations[i]['name'] != transitStation12[0] && i < 44)
                    : (stations[i]['name'] != transitStation12[0] && i > 44);) {
              route.routeStations.add(stations[i]['name']);
              if (fromIndx > 44) {
                switch (getCollection(44)) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i--;
              }
              if (fromIndx < 44) {
                switch (getCollection(44)) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i++;
              }
            }
            route.routeStations.add(stations[44]['name']);
            print(stations[44]['name']);
            int inc = 18 < toIndx ? 1 : -1;
            for (int i = 18 + inc;
                18 < toIndx ? (i <= toIndx) : (i >= toIndx);
                18 < toIndx ? i++ : i--) {
              print('inside the second loop');
              route.routeStations.add(stations[i]['name']);
              if (18 > toIndx) {
                switch (toCollection) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
              if (18 < toIndx) {
                switch (toCollection) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
            }
          } else if ((from == 'Attaba') &&
              (to == 'Gamal Abd Al-Naser' || to == 'Orabi' || toIndx > 21)) {
            for (int i = fromIndx;
                fromIndx < 47
                    ? (stations[i]['name'] != transitStation12[1] && i < 47)
                    : (stations[i]['name'] != transitStation12[1] && i > 47);) {
              route.routeStations.add(stations[i]['name']);
              if (fromIndx > 47) {
                switch (getCollection(47)) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i--;
              }
              if (fromIndx < 47) {
                switch (getCollection(47)) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
                i++;
              }
            }
            route.routeStations.add(stations[47]['name']);
            print(stations[47]['name']);
            int inc1 = 21 < toIndx ? 1 : -1;
            for (int i = 21 + inc1;
                21 < toIndx ? (i <= toIndx) : (i >= toIndx);
                21 < toIndx ? i++ : i--) {
              print('inside the second loop');
              route.routeStations.add(stations[i]['name']);
              if (21 > toIndx) {
                switch (getCollection(toIndx)) {
                  case 1:
                    print('etgah helwan');
                    break;
                  case 2:
                    print('etgah el monib');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
              if (21 < toIndx) {
                switch (getCollection(toIndx)) {
                  case 1:
                    print('etgah el Marg');
                    break;
                  case 2:
                    print('etgah shubra el kheima');
                    break;
                  default:
                    print('Unknown destination line');
                }
              }
            }
          }
        }
      }
    }
    print('==================================================');
    halop(route.routeStations);

    return route;
  }

  void halop(List<String> route) {
    for (int i = 0; i < route.length; i++) {
      print(route[i]);
    }
  }

  void halop2() {
    for (int i = 0; i < stations.length; i++) {
      print(i.toString() + ": " + stations[i]['name']);
    }
  }

  List<int> TeansitIndx(String from, String to) {
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
}
// line 1 => 0/34 
// line 2 => 35/54
// line 3 => 55/77

