import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusSeats extends StatelessWidget {
  final String busId;

  const BusSeats(this.busId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available seats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Drivers')
            .where("busId", isEqualTo: busId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isNotEmpty) {
            DocumentSnapshot document = snapshot.data!.docs.first;
            int facesNumber = document['facesnumber'] as int;
            return Center(
              child: Text('Faces Number: $facesNumber'),
            );
          } else {
            return Center(
              child: Text('No document found with busId: $busId'),
            );
          }
        },
      ),
    );
  }
}