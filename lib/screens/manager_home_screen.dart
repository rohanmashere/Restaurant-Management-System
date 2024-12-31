import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delight_corner/screens/manager_checkout_screen.dart';
import 'package:delight_corner/widgets/main_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagerHomeScreen extends ConsumerStatefulWidget {
  const ManagerHomeScreen({
    super.key,
  });

  @override
  ConsumerState<ManagerHomeScreen> createState() => ManagerHomeScreenState();
}

class ManagerHomeScreenState extends ConsumerState<ManagerHomeScreen> {
  Stream<List<dynamic>> getUserTablesStream() {
    final user = FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((docSnapshot) {
      final tables = List.from(docSnapshot.data()?['tables'] ?? []);
      return tables;
    });
  }

  Stream<String> getRestaurantNameStream() {
    final user = FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((docSnapshot) {
      final restaurantName =
          docSnapshot.data()?['Restaurant Name'] ?? 'No Restaurant';
      return restaurantName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 230, 106, 4),
        title: StreamBuilder<String>(
          stream: getRestaurantNameStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                backgroundColor: Colors.white,
              );
            }
            if (snapshot.hasError) {
              return const Text('Error loading restaurant');
            }
            return Text(
              snapshot.data!.toUpperCase(),
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            );
          },
        ),
      ),
      drawer: MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<List<dynamic>>(
          stream: getUserTablesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tables found.'));
            }
            final tables = snapshot.data!;
            return ListView.builder(
              itemCount: tables.length,
              itemBuilder: (context, index) {
                return TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ManagerCheckoutScreen(
                          table: tables[index],
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.table_chart,
                        color: const Color.fromARGB(255, 90, 57, 44),
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tables[index],
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 90, 57, 44),
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
