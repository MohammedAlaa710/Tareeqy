import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:tareeqy_metro/components/MyDropdownSearch.dart';
import 'package:tareeqy_metro/Metro/metroService.dart';

class MetroTicketGeneration extends StatefulWidget {
  const MetroTicketGeneration({super.key});

  @override
  State<MetroTicketGeneration> createState() => _MetroTicketGenerationState();
}

class _MetroTicketGenerationState extends State<MetroTicketGeneration> {
  int _selectedOption = 1;
  String dropdownValue = '6 egp';
  int number = 0;
  final QRservices _qrServices = QRservices();
  TextEditingController controller = TextEditingController();
  late final metroService _metroService;

  String selectedValue1 = '';
  String selectedValue2 = '';

  bool isDataLoaded = false;

  void incrementNumber() {
    setState(() {
      number++;
      controller.text = number.toString();
    });
  }

  void decrementNumber() {
    setState(() {
      if (number > 0) {
        number--;
        controller.text = number.toString();
      }
    });
  }

  Future<void> _loadStations() async {
    await _metroService.getStations();
    setState(() {
      isDataLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _metroService = metroService();
    _loadStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF073042),
        title: Text(
          "Get a Ticket",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "You can get your Metro ticket in three ways:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF073042),
              ),
            ),
            const SizedBox(height: 20),
            RadioListTile(
              title: const Text(
                'Enter the ticket Price',
                style: TextStyle(fontSize: 18),
              ),
              value: 1,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value as int;
                });
              },
              activeColor: const Color(0xFF073042),
            ),
            RadioListTile(
              title: const Text(
                'Enter the source and destination stations',
                style: TextStyle(fontSize: 18),
              ),
              value: 2,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value as int;
                });
              },
              activeColor: const Color(0xFF073042),
            ),
            RadioListTile(
              title: const Text(
                'Enter number of stations',
                style: TextStyle(fontSize: 18),
              ),
              value: 3,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value as int;
                });
              },
              activeColor: const Color(0xFF073042),
            ),
            const SizedBox(height: 20),
            _selectedOption == 1
                ? _buildPriceOption()
                : _selectedOption == 3
                    ? _buildStationsNumberOption()
                    : _selectedOption == 2
                        ? _buildSourceDestinationOption()
                        : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceOption() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF073042), width: 2),
          ),
          child: DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  dropdownValue = newValue;
                });
              }
            },
            items: <String>['6 egp', '8 egp', '12 egp', '15 egp']
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Color(0xFF073042)),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              backgroundColor: const Color(0xFF00796B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              int price = int.parse(dropdownValue.split(' ')[0]);
              String docId =
                  await _qrServices.addQRWithPrice(context, '$price egp');
              if (docId.isNotEmpty) {
                await _qrServices.addQRCodeToUser(context, docId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRcode(
                      qrData: docId,
                      ticketType: 'metro',
                      screen: "metro",
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Get The Ticket',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationsNumberOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Number of Stations',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF073042),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 350,
          child: TextFormField(
            cursorColor: const Color(0xFF073042),
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF073042), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF073042), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'Enter number of stations',
              labelStyle: const TextStyle(color: Color(0xFF073042)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: incrementNumber,
                    icon: const Icon(Icons.add, color: Color(0xFF073042)),
                  ),
                  IconButton(
                    onPressed: decrementNumber,
                    icon: const Icon(Icons.remove, color: Color(0xFF073042)),
                  ),
                ],
              ),
            ),
            onChanged: (value) {
              setState(() {
                number = int.tryParse(value) ?? 0;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              backgroundColor: const Color(0xFF00796B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: number > 0 && number <= 80
                ? () async {
                    String docId =
                        await _qrServices.addQRWithStationsNu(context, number);
                    if (docId.isNotEmpty) {
                      await _qrServices.addQRCodeToUser(context, docId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRcode(
                            qrData: docId,
                            ticketType: 'metro',
                            screen: "metro",
                          ),
                        ),
                      );
                    }
                  }
                : null,
            child: const Text(
              'Get The Ticket',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceDestinationOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Select Source and Destination Stations',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF073042),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (!isDataLoaded)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: MyDropdownSearch(
                  fromto: 'From',
                  items: _metroService
                      .getStationNames()
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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: MyDropdownSearch(
                  fromto: 'To',
                  items: _metroService
                      .getStationNames()
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: (selectedValue1.isNotEmpty &&
                          selectedValue2.isNotEmpty)
                      ? () async {
                          String docId = await _qrServices.addQRWithSrcandDst(
                              context, selectedValue1, selectedValue2);
                          if (docId.isNotEmpty) {
                            await _qrServices.addQRCodeToUser(context, docId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QRcode(
                                  qrData: docId,
                                  ticketType: 'metro',
                                  screen: "metro",
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  child: const Text(
                    'Get The Ticket',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
