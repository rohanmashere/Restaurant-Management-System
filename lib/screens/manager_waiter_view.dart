import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delight_corner/models/waiter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagerWaiterView extends StatelessWidget {
  final Waiter waiter;
  final String userId;

  const ManagerWaiterView({
    super.key,
    required this.waiter,
    required this.userId,
  });

  Future<void> _removeWaiter(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'waiters': FieldValue.arrayRemove([waiter.toMap()])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Waiter removed successfully'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing waiter: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Waiter Details',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 230, 106, 4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Name:  ${waiter.name}',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 90, 57, 44),
                ),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Mobile No:  ${waiter.mobileNo}',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 90, 57, 44),
                ),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Username: ${waiter.username}',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 90, 57, 44),
                ),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Password: ${waiter.password}',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 90, 57, 44),
                ),
              ),
            ),
            Divider(),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _removeWaiter(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 249, 111, 5),
                ),
                child: Text(
                  'Remove Waiter',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
