import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delight_corner/screens/manager_home_screen.dart';
import 'package:delight_corner/screens/manager_register_screen.dart';
import 'package:delight_corner/screens/reset_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final _firebase = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ManagerLoginScreen extends ConsumerStatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  ConsumerState<ManagerLoginScreen> createState() {
    return ManagerLoginScreenState();
  }
}

class ManagerLoginScreenState extends ConsumerState<ManagerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  var _enteredEmail = '';
  var _enteredPassword = '';

  Future<void> loginSubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    try {
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('Email', isEqualTo: _enteredEmail)
          .get();

      if (userQuery.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found with that Email.')),
        );
        return;
      }

      UserCredential userCredential =
          await _firebase.signInWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPassword,
      );

      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await _firebase.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email is not verified. Please verify your email.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Successful.'),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => ManagerHomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

  void resetPassword() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ResetPasswordScreen(),
      ),
    );
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
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 80),
                        Text(
                          'Login',
                          style: GoogleFonts.lato(
                            fontSize: 40,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add your details to login',
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 73, 67, 67),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: Color.fromARGB(255, 90, 57, 44),
                              size: 30,
                            ),
                            SizedBox(width: 10),
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
                                    return 'Please enter valid email address';
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
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.password_outlined,
                              color: Color.fromARGB(255, 90, 57, 44),
                              size: 30,
                            ),
                            SizedBox(width: 10),
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
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Password must be at least 6 characters long.';
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
                        SizedBox(
                          height: 30,
                        ),
                        TextButton(
                          onPressed: resetPassword,
                          child: Text(
                            'Reset your Password?',
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 255, 123, 7),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        loginSubmit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 249, 111, 5),
                        padding: EdgeInsets.symmetric(
                          horizontal: 110,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ManagerRegisterScreen(),
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
