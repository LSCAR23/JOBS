import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
                  children: [Form(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                          inputFormatters: [LengthLimitingTextInputFormatter(50)],
                          decoration: InputDecoration(
                            hintText: "Name",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme? Colors.black45:Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none
                              )
                            ),
                          prefixIcon: Icon(Icons.person,color:darkTheme?Colors.amber.shade400:Colors.grey)  
                          ),
                          autovalidateMode:AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text==null || text.isEmpty){
                              return 'Name can not be empty';
                            }
                            if(text.length<2 || text.length>49){
                              return 'Please enter a valid name';
                            }
                          },
                          onChanged: (text)=>setState(() {
                            nameTextEditingController.text=text;
                          }),
                          ), 
                          SizedBox(height: 10,),

                          TextFormField(
                          inputFormatters: [LengthLimitingTextInputFormatter(100)],
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme? Colors.black45:Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none
                              )
                            ),
                          prefixIcon: Icon(Icons.person,color:darkTheme?Colors.amber.shade400:Colors.grey)  
                          ),
                          autovalidateMode:AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text==null || text.isEmpty){
                              return 'Email can not be empty';
                            }
                            if(EmailValidator.validate(text)==true){
                              return null;
                            }
                            if(text.length<2 || text.length>99){
                              return 'Please enter a valid email';
                            }
                          },
                          onChanged: (text)=>setState(() {
                            emailTextEditingController.text=text;
                          }),
                          ), 
                          SizedBox(height: 10,),
                          
                          IntlPhoneField(
                            showCountryFlag: false,
                            dropdownIcon: Icon(
                              Icons.arrow_drop_down,
                              color:darkTheme? Colors.amber.shade400:Colors.grey
                            ),
                            decoration: InputDecoration(
                            hintText: "Phone",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme? Colors.black45:Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none
                              )
                            ),
                          ),
                          initialCountryCode: 'CR',
                          onChanged: (text)=>setState(() {
                            phoneTextEditingController.text=text.completeNumber;
                          }),
                          ),
                          
                          TextFormField(
                          inputFormatters: [LengthLimitingTextInputFormatter(100)],
                          decoration: InputDecoration(
                            hintText: "Address",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme? Colors.black45:Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none
                              )
                            ),
                          prefixIcon: Icon(Icons.person,color:darkTheme?Colors.amber.shade400:Colors.grey)  
                          ),
                          autovalidateMode:AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text==null || text.isEmpty){
                              return 'Address can not be empty';
                            }
                            if(text.length<2 || text.length>99){
                              return 'Address enter a valid name';
                            }
                          },
                          onChanged: (text)=>setState(() {
                            addressTextEditingController.text=text;
                          }),
                          ),
                          SizedBox(height: 20,),

                          TextFormField(
                          obscureText: !_passwordVisible,
                          inputFormatters: [LengthLimitingTextInputFormatter(50)],
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme? Colors.black45:Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius:BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none
                              )
                            ),
                          prefixIcon: Icon(Icons.person,color:darkTheme?Colors.amber.shade400:Colors.grey),  
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisible?Icons.visibility:Icons.visibility_off,
                            color: darkTheme?Colors.amber.shade400:Colors.grey,
                            ),
                            onPressed:(){
                              setState(() {
                                _passwordVisible=!_passwordVisible;
                              });
                            } ,
                            )
                          ),
                          autovalidateMode:AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text==null || text.isEmpty){
                              return 'Password can not be empty';
                            }
                            if(text.length<6 || text.length>49){
                              return 'Password enter a valid name';
                            }
                            return null;
                          },
                          onChanged: (text)=>setState(() {
                            passwordTextEditingController.text=text;
                          }),
                          ),
                        ],
                      )
                    ),]
                    )
              )
            ],
          )
        ],
      )),
    );
  }
}
