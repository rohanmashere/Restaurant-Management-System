import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({super.key});
  @override
  BillHistoryScreenState createState() => BillHistoryScreenState();
}

class BillHistoryScreenState extends State<BillHistoryScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    setState(() {
      isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final database = FirebaseDatabase.instance.ref();
      final usersRef = database.child('users/${user.uid}/bills');
      usersRef.onValue.listen((event) {
        if (event.snapshot.exists) {
          final Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> formattedHistory = [];

          data.forEach((date, bills) {
            final List<dynamic> billsList = List.from(bills as List<dynamic>);
            double totalAmount = 0;

            billsList.forEach((bill) {
              totalAmount += (bill['total_bill'] is int
                  ? (bill['total_bill'] as int).toDouble()
                  : bill['total_bill'] as double);
            });

            formattedHistory.add({
              'date': date,
              'totalAmount': totalAmount,
              'bills': billsList,
            });
          });

          formattedHistory.sort((a, b) {
            final billsA = a['bills'] as List;
            final billsB = b['bills'] as List;
            final latestBillA = billsA.isNotEmpty
                ? DateTime.fromMillisecondsSinceEpoch(billsA.last['timestamp'])
                : DateTime(1970);
            final latestBillB = billsB.isNotEmpty
                ? DateTime.fromMillisecondsSinceEpoch(billsB.last['timestamp'])
                : DateTime(1970);

            return latestBillB.compareTo(latestBillA);
          });

          for (var item in formattedHistory) {
            item['bills'].sort((a, b) {
              final timestampA = a['timestamp'] as int;
              final timestampB = b['timestamp'] as int;
              return DateTime.fromMillisecondsSinceEpoch(timestampB)
                  .compareTo(DateTime.fromMillisecondsSinceEpoch(timestampA));
            });
          }

          setState(() {
            history = formattedHistory;
            isLoading = false;
          });
        } else {
          setState(() {
            history = [];
            isLoading = false;
          });
        }
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      String day = parsedDate.day.toString().padLeft(2, '0');
      String month = parsedDate.month.toString().padLeft(2, '0');
      String year = parsedDate.year.toString();

      return '$day-$month-$year';
    } catch (e) {
      return date;
    }
  }

  String formatTimestamp(int timestamp) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    int hour = date.hour;
    int minute = date.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    String minuteString = minute < 10 ? '0$minute' : '$minute';
    return '$hour:$minuteString $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 230, 106, 4),
        title: Text(
          'History',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ))
          : history.isEmpty
              ? const Center(child: Text('No history available'))
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final historyItem = history[index];
                    final totalAmount = historyItem['totalAmount'];
                    final bills = historyItem['bills'];

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          color: Colors.grey[200],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDate(historyItem['date']),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total: Rs ${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Column(
                          children: bills.map<Widget>((bill) {
                            return ListTile(
                              title: Text(
                                'Amount: Rs ${bill['total_bill'].toStringAsFixed(2)}',
                                style: GoogleFonts.lato(
                                    fontSize: 18,
                                    color:
                                        const Color.fromARGB(255, 90, 57, 44),
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Invoice No: ${bill['invoice_no']}',
                                style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              trailing: Text(
                                // ignore: unnecessary_string_interpolations
                                '${formatTimestamp(bill['timestamp'])}',
                                style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 90, 57, 44),
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
