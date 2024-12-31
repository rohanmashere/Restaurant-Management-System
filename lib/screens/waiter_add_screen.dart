import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class WaiterAddScreen extends ConsumerStatefulWidget {
  const WaiterAddScreen({super.key, required this.onAdd});
  final VoidCallback onAdd;
  @override
  WaiterAddScreenState createState() => WaiterAddScreenState();
}

class WaiterAddScreenState extends ConsumerState<WaiterAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  var _enteredWName = '';
  var _enteredMobile = '';
  var _enteredUsername = '';
  var _enteredPassword = '';

  Future<void> addWaiterToFirestore() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      final allUsersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      bool usernameExists = false;

      for (var userDoc in allUsersSnapshot.docs) {
        final waiters = List.from(userDoc.data()['waiters'] ?? []);
        if (waiters
            .any((waiter) => waiter['username'] == _enteredUsername.trim())) {
          usernameExists = true;
          break;
        }
      }

      if (usernameExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username already exists, please choose another one'),
          ),
        );
        return;
      }

      final userData = await userDocRef.get();
      List<dynamic> waiters = List.from(userData.data()?['waiters'] ?? []);

      final newWaiter = {
        'name': _enteredWName.trim(),
        'mobile no': _enteredMobile.trim(),
        'username': _enteredUsername.trim(),
        'password': _enteredPassword.trim(),
      };

      waiters.add(newWaiter);

      await userDocRef.set({
        'waiters': waiters,
      }, SetOptions(merge: true));

      Navigator.of(context).pop();
      widget.onAdd();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiter added Successfully'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding waiter: ${error.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 249, 111, 5),
        title: Text(
          'Add Waiter',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle,
                        color: Color.fromARGB(255, 90, 57, 44),
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            label: Text(
                              'Waiter Name',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Color.fromARGB(255, 140, 93, 74),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid name';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredWName = value!.trim();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.mobile_friendly,
                        color: Color.fromARGB(255, 90, 57, 44),
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            label: Text(
                              'Mobile No.',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Color.fromARGB(255, 140, 93, 74),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                !RegExp(r'^[0-9]+$').hasMatch(value.trim()) ||
                                value.trim().length != 10) {
                              return 'Please enter a valid number.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredMobile = value!.trim();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 90, 57, 44),
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            label: Text(
                              'Username',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Color.fromARGB(255, 140, 93, 74),
                              ),
                            ),
                          ),
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid username';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredUsername = value!.trim();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.password,
                        color: Color.fromARGB(255, 90, 57, 44),
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            label: Text(
                              'Password',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Color.fromARGB(255, 140, 93, 74),
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_passwordVisible,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a password.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!.trim();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        addWaiterToFirestore();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 249, 111, 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 90,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'Add Waiter',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
