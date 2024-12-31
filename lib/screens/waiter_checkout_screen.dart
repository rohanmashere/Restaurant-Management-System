import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class WaiterCheckoutScreen extends StatefulWidget {
  final String username;
  final String table;

  const WaiterCheckoutScreen({
    super.key,
    required this.username,
    required this.table,
  });

  @override
  State<WaiterCheckoutScreen> createState() => WaiterCheckoutScreenState();
}

class WaiterCheckoutScreenState extends State<WaiterCheckoutScreen> {
  Future<String?> getUserIdByUsername(String username) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in querySnapshot.docs) {
        final userData = userDoc.data();
        final waiters = userData['waiters'] as List<dynamic>;

        for (var waiter in waiters) {
          if (waiter['username'] == username) {
            return userDoc.id;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> removeItem(String userId, String table, String itemName) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        final userData = userDocSnapshot.data() as Map<String, dynamic>;
        final addMenu = userData['add_menu'] ?? {};
        final orders = List<Map<String, dynamic>>.from(addMenu[table] ?? []);
        final totalBill = userData['total_bill'] ?? {};
        final itemIndex =
            orders.indexWhere((order) => order['name'] == itemName);

        if (itemIndex != -1) {
          final item = orders[itemIndex];
          final itemPrice = item['price'];
          final itemQuantity = item['quantity'];

          if (itemQuantity > 1) {
            orders[itemIndex]['quantity'] = itemQuantity - 1;
            totalBill[table] -= itemPrice;
          } else {
            orders.removeAt(itemIndex);
            totalBill[table] -= itemPrice;
          }

          await userDocRef.update({
            'add_menu.$table': orders,
            'total_bill.$table': totalBill[table],
          });

          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item removed.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item not found.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item $itemName.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.table} - Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 230, 106, 4),
      ),
      body: FutureBuilder<String?>(
        future: getUserIdByUsername(widget.username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User not found.'));
          }
          final userId = snapshot.data!;
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!orderSnapshot.hasData || !orderSnapshot.data!.exists) {
                return const Center(child: Text('No orders for this table.'));
              }
              final userData =
                  orderSnapshot.data!.data() as Map<String, dynamic>;
              final addMenu = userData['add_menu'] ?? {};
              final orders =
                  List<Map<String, dynamic>>.from(addMenu[widget.table] ?? []);
              final totalBill =
                  userData['total_bill'][widget.table]?.toDouble() ?? 0.0;
              Map<String, List<Map<String, dynamic>>> groupedOrders = {};

              for (var order in orders) {
                String category = order['category'] ?? 'Uncategorized';
                if (groupedOrders.containsKey(category)) {
                  groupedOrders[category]!.add(order);
                } else {
                  groupedOrders[category] = [order];
                }
              }

              return ListView(
                padding: EdgeInsets.all(10),
                children: [
                  Text(
                    'Order Summary',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(),
                  if (orders.isEmpty)
                    Center(
                      child: Text(
                        'No items Added',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ...groupedOrders.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...entry.value.map((order) {
                          return ListTile(
                            title: Text(
                              '${order['name']} x ${order['quantity']}',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Color.fromARGB(255, 90, 57, 44),
                              ),
                            ),
                            subtitle: Text(
                              'Rs ${order['price']}',
                              style: GoogleFonts.lato(
                                color: Color.fromARGB(255, 90, 57, 44),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Color.fromARGB(255, 90, 57, 44),
                              ),
                              onPressed: () {
                                removeItem(
                                  userId,
                                  widget.table,
                                  order['name'],
                                );
                              },
                            ),
                          );
                        }),
                        Divider(),
                      ],
                    );
                  }),
                  Text(
                    'Total Bill: Rs $totalBill',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
