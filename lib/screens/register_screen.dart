import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jobs/firebase_services.dart';
import 'package:jobs/global/global.dart';
import 'package:jobs/screens/forgot_password_screen.dart';
import 'package:jobs/screens/login_screen.dart';
import 'package:jobs/screens/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  final _fromKey = GlobalKey<FormState>();

  void _submit2() async {
    if (_fromKey.currentState!.validate()) {
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim())
          .then((auth) async {
        currentUser = auth.user;

        if (currentUser != null) {
          Map userMap2 = {
            "id": currentUser!.uid,
            "name": nameTextEditingController.text.trim(),
            "email": emailTextEditingController.text.trim(),
            "address": addressTextEditingController.text.trim(),
            "phone": phoneTextEditingController.text.trim()
          };
          DatabaseReference userRef =
              FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap2);
        }
        await Fluttertoast.showToast(msg: "Succesfully Registered");
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all field are valid");
    }
  }

  /* void _submit() async {
    if (_fromKey.currentState!.validate()) {
      var userMap = {
        'name': nameTextEditingController.text.trim(),
        'email': emailTextEditingController.text.trim(),
        'address': addressTextEditingController.text.trim(),
        'phone': phoneTextEditingController.text.trim(),
        'password': passwordTextEditingController.text.trim()
      };
      save_user(userMap);
      //DatabaseReference userRef= FirebaseDatabase.instance.ref().child('users');
      //userRef.child(currentUser!.uid).set(userMap);
      await Fluttertoast.showToast(msg: 'Succcesfully Registered!');
      Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid.");
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    //bool darkTheme= false;
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
                    'Register',
                    style: TextStyle(
                        color: darkTheme ? Colors.white : Colors.black,
                        fontSize: 35,
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
                                            LengthLimitingTextInputFormatter(50)
                                          ],
                                          decoration: InputDecoration(
                                              hintText: "Name",
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
                                              return 'Name can not be empty';
                                            }
                                            if (text.length < 2 ||
                                                text.length > 49) {
                                              return 'Please enter a valid name';
                                            }
                                          },
                                          onChanged: (text) => setState(() {
                                            nameTextEditingController.text =
                                                text;
                                          }),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
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
                                        child: IntlPhoneField(
                                          style: TextStyle(
                                              color: darkTheme
                                                  ? Colors.white
                                                  : Colors.black),
                                          showCountryFlag: false,
                                          dropdownIcon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.blue),
                                          decoration: InputDecoration(
                                    
                                            hintText: "Phone",
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
                                            counterText: "",
                                            
                                          ),
                                          
                                          initialCountryCode: 'CR',
                                          
                                          onChanged: (text) => setState(() {
                                            phoneTextEditingController.text =
                                                text.completeNumber;
                                          }),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
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
                                              hintText: "Address",
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
                                              return 'Address can not be empty';
                                            }
                                            if (text.length < 2 ||
                                                text.length > 99) {
                                              return 'Please enter a valid address';
                                            }
                                          },
                                          onChanged: (text) => setState(() {
                                            addressTextEditingController.text =
                                                text;
                                          }),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
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
                                          obscureText: !_passwordVisible,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(50)
                                          ],
                                          decoration: InputDecoration(
                                              hintText: "Password",
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
                                                  color: Colors.blue),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _passwordVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _passwordVisible =
                                                        !_passwordVisible;
                                                  });
                                                },
                                              )),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (text) {
                                            if (text == null || text.isEmpty) {
                                              return 'Password can not be empty';
                                            }
                                            if (text.length < 6 ||
                                                text.length > 49) {
                                              return 'Please enter a valid password';
                                            }
                                            return null;
                                          },
                                          onChanged: (text) => setState(() {
                                            passwordTextEditingController.text =
                                                text;
                                          }),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
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
                                          obscureText: !_passwordVisible,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(50)
                                          ],
                                          decoration: InputDecoration(
                                              hintText: "Confirm Password",
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
                                                  color: Colors.blue),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _passwordVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _passwordVisible =
                                                        !_passwordVisible;
                                                  });
                                                },
                                              )),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (text) {
                                            if (text == null || text.isEmpty) {
                                              return 'Confirm Password can not be empty';
                                            }
                                            if (text !=
                                                passwordTextEditingController
                                                    .text) {
                                              return 'Password does not match';
                                            }
                                            if (text.length < 6 ||
                                                text.length > 49) {
                                              return 'Please enter a valid Password';
                                            }
                                            return null;
                                          },
                                          onChanged: (text) => setState(() {
                                            confirmTextEditingController.text =
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
                                            side: BorderSide(color: Colors.blue),
                                            minimumSize:
                                                Size(double.infinity, 50)),
                                        onPressed: () {
                                          _submit2();
                                        },
                                        child: Text('Register',
                                            style: TextStyle(
                                              fontSize: 20,
                                            ))),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) =>
                                                  ForgotPasswordScreen()));
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Have an account?',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        )
                                      ],
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
                                            color: darkTheme? Colors.grey: Colors.black, width: 2.0),
                                        minimumSize: Size(double.infinity, 50)),
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
                                    /*GestureDetector(
                                      onTap: () {},
                                      child: Text('Sign In',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: darkTheme
                                                ? Colors.amber.shade400
                                                : Colors.blue,
                                          )),
                                    )*/
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
