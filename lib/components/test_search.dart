import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomSearch2 extends StatefulWidget {
  late String fromTo;
  late List<QueryDocumentSnapshot> stations;
  String? selectedValue;
  CustomSearch2(
      {super.key,
      required this.stations,
      required this.fromTo,
      required this.selectedValue});

  @override
  State<CustomSearch2> createState() => _CustomSearch2State();
}

class _CustomSearch2State extends State<CustomSearch2> {
  List<String?> yarb = [''];
  String? aa;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: DropdownSearch<String>(
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: widget.fromTo,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.9),
          ),
        ),
        items: getStations(),
        popupProps: PopupProps.dialog(
          itemBuilder: (context, item, isSelected) {
            return Column(
              children: [
                Center(
                  child: ListTile(
                    title: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                    selected: isSelected,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 70),
                  ),
                ),
                Divider(
                  height: 0.5,
                  color: Colors.black.withOpacity(0.6),
                  indent: 15,
                  endIndent: 15,
                ), // Add a divider after each item
              ],
            );
          },
          dialogProps: const DialogProps(
            backgroundColor: Color.fromARGB(255, 49, 69, 103),
          ),
          showSearchBox: true,
          showSelectedItems: true,
          searchFieldProps: TextFieldProps(
            cursorColor: Color.fromARGB(255, 49, 69, 103),
            autocorrect: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.withOpacity(0.5),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
            ),
          ),
        ),
        onChanged: (value) {
          setState(() {
            widget.selectedValue = value;
            yarb.add(widget.selectedValue);
          });
        },
        selectedItem: widget.selectedValue,
      ),
    );
  }

  List<String> getStations() {
    List<String> station_name = [];
    String? x = yarb.last;
    for (int i = 0; i < widget.stations.length; i++) {
      if (widget.stations[i]['name'] == x) {
        continue;
      }
      station_name.add(widget.stations[i]['name']);
    }
    yarb.remove(x);
    //station_name.where((element) => element != widget.selectedValue).toList();
    //setState(() {});
    return station_name;
  }
}
