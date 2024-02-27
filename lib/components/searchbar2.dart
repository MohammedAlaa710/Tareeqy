import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomSearch2 extends StatefulWidget {
  late List<QueryDocumentSnapshot> stations;
  CustomSearch2({
    super.key,
    required this.stations,
  });

  @override
  State<CustomSearch2> createState() => _CustomSearch2State();
}

class _CustomSearch2State extends State<CustomSearch2> {
  List<String?> yarb = [''];
  String? selectedValue1;
  String? selectedValue2;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: DropdownSearch<String>(
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'From',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.9),
              ),
            ),
            items: getStations()
                .where((element) => element != selectedValue2)
                .toList(),
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 70),
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
                selectedValue1 = value;
                yarb.add(selectedValue1);
              });
            },
            selectedItem: selectedValue1,
          ),
        ),
        ////////////////////////////////////////////////////////
        const SizedBox(height: 10),
        ///////////////////////////////////////////////////////
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: DropdownSearch<String>(
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'To',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.9),
              ),
            ),
            items: getStations()
                .where((element) => element != selectedValue1)
                .toList(),
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 70),
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
                selectedValue2 = value;
                yarb.add(selectedValue2);
              });
            },
            selectedItem: selectedValue2,
          ),
        ),
      ],
    );
  }

  List<String> getStations() {
    List<String> station_name = [];
    for (int i = 0; i < widget.stations.length; i++) {
      station_name.add(widget.stations[i]['name']);
    }
    return station_name;
  }
}
