import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jobs/firebase_services.dart';
import 'package:jobs/global/global.dart';
import 'package:jobs/screens/main_page.dart';

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

  void _submit() async {
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

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: ListView(
        padding: EdgeInsets.all(0),
        children: [
          Column(
            children: [
              Image.asset(
                  darkTheme ? 'images/darkCity.jpg' : 'images/lightCity.jpg'),
              SizedBox(
                height: 20,
              ),
              Text(
                'Register',
                style: TextStyle(
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
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
                                TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Name",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none)),
                                      prefixIcon: Icon(Icons.person,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey)),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Name can not be empty';
                                    }
                                    if (text.length < 2 || text.length > 49) {
                                      return 'Please enter a valid name';
                                    }
                                  },
                                  onChanged: (text) => setState(() {
                                    nameTextEditingController.text = text;
                                  }),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(100)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Email",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none)),
                                      prefixIcon: Icon(Icons.person,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey)),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Email can not be empty';
                                    }
                                    if (EmailValidator.validate(text) == true) {
                                      return null;
                                    }
                                    if (text.length < 2 || text.length > 99) {
                                      return 'Please enter a valid email';
                                    }
                                  },
                                  onChanged: (text) => setState(() {
                                    emailTextEditingController.text = text;
                                  }),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                IntlPhoneField(
                                  showCountryFlag: false,
                                  dropdownIcon: Icon(Icons.arrow_drop_down,
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey),
                                  decoration: InputDecoration(
                                    hintText: "Phone",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: darkTheme
                                        ? Colors.black45
                                        : Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            width: 0, style: BorderStyle.none)),
                                  ),
                                  initialCountryCode: 'CR',
                                  onChanged: (text) => setState(() {
                                    phoneTextEditingController.text =
                                        text.completeNumber;
                                  }),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(100)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Address",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none)),
                                      prefixIcon: Icon(Icons.person,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey)),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Address can not be empty';
                                    }
                                    if (text.length < 2 || text.length > 99) {
                                      return 'Please enter a valid address';
                                    }
                                  },
                                  onChanged: (text) => setState(() {
                                    addressTextEditingController.text = text;
                                  }),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  obscureText: !_passwordVisible,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Password",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none)),
                                      prefixIcon: Icon(Icons.person,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        },
                                      )),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Password can not be empty';
                                    }
                                    if (text.length < 6 || text.length > 49) {
                                      return 'Please enter a valid password';
                                    }
                                    return null;
                                  },
                                  onChanged: (text) => setState(() {
                                    passwordTextEditingController.text = text;
                                  }),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  obscureText: !_passwordVisible,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Confirm Password",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none)),
                                      prefixIcon: Icon(Icons.person,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        },
                                      )),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Confirm Password can not be empty';
                                    }
                                    if (text !=
                                        passwordTextEditingController.text) {
                                      return 'Password does not match';
                                    }
                                    if (text.length < 6 || text.length > 49) {
                                      return 'Please enter a valid Password';
                                    }
                                    return null;
                                  },
                                  onChanged: (text) => setState(() {
                                    confirmTextEditingController.text = text;
                                  }),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue,
                                        onPrimary: darkTheme
                                            ? Colors.black
                                            : Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(32)),
                                        minimumSize: Size(double.infinity, 50)),
                                    onPressed: () {
                                      _submit();
                                    },
                                    child: Text('Register',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ))),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                GestureDetector(
                                  onTap: () {},
                                  child: Text('Sign In',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue,
                                      )),
                                )
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
