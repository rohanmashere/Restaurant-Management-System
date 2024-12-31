import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delight_corner/screens/manager_login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final _firebase = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ManagerRegisterScreen extends ConsumerStatefulWidget {
  const ManagerRegisterScreen({super.key});

  @override
  ConsumerState<ManagerRegisterScreen> createState() {
    return ManagerRegisterScreenState();
  }
}

class ManagerRegisterScreenState extends ConsumerState<ManagerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _password;
  var _enteredName = '';
  var _enteredAddress = '';
  var _enteredNumber = '';
  var _enteredEmail = '';
  var _enteredPassword = '';

  Future<void> registerSubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    try {
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPassword,
      );

      await userCredentials.user!.sendEmailVerification();
      await _firestore.collection('users').doc(userCredentials.user!.uid).set({
        'Address': _enteredAddress,
        'Email': _enteredEmail,
        'Mobile No': _enteredNumber,
        'Restaurant Name': _enteredName,
        'uid': userCredentials.user!.uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration successful! A verification email has been sent to $_enteredEmail.',
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => ManagerLoginScreen(),
        ),
      );

      _formKey.currentState!.reset();
    } catch (error) {
      if (error is FirebaseAuthException) {
        if (error.code == 'email-already-in-use') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This email is already registered.'),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 1),
                        Text(
                          'Register',
                          style: GoogleFonts.lato(
                            fontSize: 40,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add your details to register',
                          style: GoogleFonts.poppins(
                            color: const Color.fromARGB(255, 73, 67, 67),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              color: Color.fromARGB(255, 90, 57, 44),
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  label: Text(
                                    'Restaurant Name',
                                    style: GoogleFonts.lato(
                                      color: Color.fromARGB(255, 140, 93, 74),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter the name.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredName = value!.trim();
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
                                    'Mobile Number',
                                    style: GoogleFonts.lato(
                                      color: Color.fromARGB(255, 140, 93, 74),
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null ||
                                      !RegExp(r'^[0-9]+$')
                                          .hasMatch(value.trim()) ||
                                      value.trim().length != 10) {
                                    return 'Please enter a valid number.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredNumber = value!.trim();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Color.fromARGB(255, 90, 57, 44),
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  label: Text(
                                    'Email Address',
                                    style: GoogleFonts.lato(
                                      color: Color.fromARGB(255, 140, 93, 74),
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredEmail = value!.trim();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.add_home_outlined,
                              color: Color.fromARGB(255, 90, 57, 44),
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  label: Text(
                                    'Address',
                                    style: GoogleFonts.lato(
                                      color: Color.fromARGB(255, 140, 93, 74),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a valid address.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredAddress = value!.trim();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.password_outlined,
                              color: Color.fromARGB(255, 90, 57, 44),
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  label: Text(
                                    'Password',
                                    style: GoogleFonts.lato(
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
                                  _password = value;
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.password_outlined,
                              color: Color.fromARGB(255, 90, 57, 44),
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  label: Text(
                                    'Confirm Password',
                                    style: GoogleFonts.lato(
                                      color: Color.fromARGB(255, 140, 93, 74),
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _confirmPasswordVisible =
                                            !_confirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: !_confirmPasswordVisible,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value != _password) {
                                    return "Password doesn't match.";
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
                        const SizedBox(height: 40),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: registerSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 249, 111, 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 110,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ManagerLoginScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an Account? ",
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 87, 83, 79),
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: 'Register',
                              style: GoogleFonts.poppins(
                                color: Color.fromARGB(255, 255, 123, 7),
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
