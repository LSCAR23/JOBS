import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jobs/global/global.dart';
import 'package:jobs/screens/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _fromKey = GlobalKey<FormState>();

  final emailTextEditingController = TextEditingController();

  void _submit() {
    firebaseAuth
        .sendPasswordResetEmail(email: emailTextEditingController.text.trim())
        .then((value) {
      Fluttertoast.showToast(
          msg:
              "we have sent you an email to recover your password, please check your inbox.");
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg: "Error Occurred:\n${error.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    //bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    bool darkTheme= true;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: darkTheme ? Colors.black : Colors.white,
          body: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Column(
                children: [
                  Image.asset('images/examp.jpg'),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Recover Password',
                    style: TextStyle(
                        color: darkTheme ? Colors.white : Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Form(
                                key: _fromKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          style: TextStyle(
                                              color: darkTheme
                                                  ? Colors.white
                                                  : Colors.black),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                100)
                                          ],
                                          decoration: InputDecoration(
                                              hintText: "Email",
                                              hintStyle: TextStyle(
                                                color: Colors.blue,
                                              ),
                                              filled: true,
                                              fillColor: darkTheme
                                                  ? Colors.black
                                                  : Colors.white,
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  borderSide: BorderSide(
                                                      width: 0,
                                                      style: BorderStyle.none)),
                                              prefixIcon: Icon(Icons.person,
                                                  color: Colors.blue)),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (text) {
                                            if (text == null || text.isEmpty) {
                                              return 'Email can not be empty';
                                            }
                                            if (EmailValidator.validate(text) ==
                                                true) {
                                              return null;
                                            }
                                            if (text.length < 2 ||
                                                text.length > 99) {
                                              return 'Please enter a valid email';
                                            }
                                          },
                                          onChanged: (text) => setState(() {
                                            emailTextEditingController.text =
                                                text;
                                          }),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: darkTheme
                                                ? Colors.black
                                                : Colors.white,
                                            onPrimary: Colors.blue,
                                            elevation:
                                                5.0, // Change this line for shadow depth
                                            shadowColor: Colors.grey,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32)),
                                            side:
                                                BorderSide(color: Colors.blue),
                                            minimumSize:
                                                Size(double.infinity, 50)),
                                        onPressed: () {
                                          _submit();
                                        },
                                        child: Text('Send email',
                                            style: TextStyle(
                                              fontSize: 20,
                                            ))),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: darkTheme
                                                ? Colors.black
                                                : Colors.white,
                                            onPrimary: darkTheme
                                                ? Colors.grey
                                                : Colors.black,
                                            elevation:
                                                5.0, // Change this line for shadow depth
                                            shadowColor: Colors.grey,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32)),
                                            side: BorderSide(
                                                color: darkTheme
                                                    ? Colors.grey
                                                    : Colors.black,
                                                width: 2.0),
                                            minimumSize:
                                                Size(double.infinity, 50)),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (c) =>
                                                      LoginScreen()));
                                        },
                                        child: Text('Sign In',
                                            style: TextStyle(
                                              fontSize: 20,
                                            ))),
                                  ],
                                )),
                          ]))
                ],
              )
            ],
          )),
    );
  }
}
