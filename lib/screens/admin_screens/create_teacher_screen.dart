import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../widgets/custom_text_field.dart';

class CreateTeacherScreen extends StatefulWidget {
  @override
  _CreateTeacherScreenState createState() => _CreateTeacherScreenState();
}

class _CreateTeacherScreenState extends State<CreateTeacherScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final databaseInstance = FirebaseDatabase.instance;

  String email = "";
  String password = "";
  String fullName = "";
  String teacherId = "";

  var _isLoading = false;

  void signup() async {
    //changing state to loading
    setState(() {
      _isLoading = true;
    });

    //getting form data
    final form = _formKey.currentState;

    //saving the form
    form.save();

    //validating
    if (form.validate()) {
      //creating teacher user
      AuthResult result =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //storing user
      FirebaseUser user = result.user;

      //setting role in realtime database
      await databaseInstance
          .reference()
          .child("users")
          .child(user.uid)
          .set({'role': 'Teacher'});

      //loading teacher data to realtime database
      await databaseInstance
          .reference()
          .child("Teachers")
          .child(user.uid)
          .set({'Name': fullName, 'Teacher Id': teacherId});

      //clearing the form
      form.reset();

      //routing to previous screen
      Navigator.of(context).pop();
    }

    //changing state to loading
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Create Teacher',
          style: textTheme.title,
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              //signup form
              _buildCreateTeacherForm(context, screenSize, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  _buildCreateTeacherForm(
    BuildContext context,
    Size screenSize,
    TextTheme textTheme,
  ) {
    String confirmPassword;
    return Column(
      children: <Widget>[
        //email input field
        MyTextField(
          icon: Icons.email,
          label: 'Email Id',
          hint: 'What is you email id ?',
          hideText: false,
          isSuffix: false,
          inputType: TextInputType.emailAddress,
          onSaved: (value) {
            email = value;
          },
          validator: (String value) {
            if (value.length == 0) {
              return 'This Field Can\'t Be Empty !';
            }
            if (!(value.contains("@gmail.com") ||
                value.contains("@yahoo.com") ||
                value.contains("@rediff.com") ||
                value.contains("@hotmail.com"))) {
              return 'Enter A Valid Email !';
            }
            return null;
          },
        ),
        //name input fields
        MyTextField(
          icon: Icons.person_outline,
          label: 'Full Name',
          hint: 'Enter name as per IDCard',
          hideText: false,
          isSuffix: false,
          inputType: TextInputType.text,
          onSaved: (value) {
            fullName = value;
          },
          validator: (String value) {
            if (value.length == 0) {
              return 'This Field Can\'t Be Empty !';
            }
            return null;
          },
        ),
        //teacher id input field
        MyTextField(
          icon: Icons.contacts,
          label: 'Teacher Id',
          hint: 'Enter the ID give on ICard',
          hideText: false,
          isSuffix: false,
          inputType: TextInputType.text,
          onSaved: (value) {
            teacherId = value;
          },
          validator: (String value) {
            if (value.length == 0) {
              return 'This Field Can\'t Be Empty !';
            }
            return null;
          },
        ),
        //password input field
        MyTextField(
          icon: Icons.lock,
          label: 'Password',
          hint: 'What is you password ?',
          hideText: true,
          isSuffix: true,
          inputType: TextInputType.visiblePassword,
          onSaved: (value) {
            confirmPassword = value.toString();
            password = value;
          },
          validator: (String value) {
            if (value.length == 0) {
              return 'This Field Can\'t Be Empty !';
            }
            if (value.length < 6) {
              return 'Password Must Be Atleast 6 Characteres Long !';
            }
            return null;
          },
        ),
        //confirm password input field
        MyTextField(
          icon: Icons.lock_open,
          label: 'Confirm Password',
          hint: 'Enter Same Password Again !',
          hideText: true,
          isSuffix: true,
          inputType: TextInputType.visiblePassword,
          onSaved: (value) {
            password = value;
          },
          validator: (String value) {
            if (value.length == 0) {
              return 'This Field Can\'t Be Empty !';
            }
            if (!(value == confirmPassword)) {
              return 'Password & Confirm Password Didn\'t Match !';
            }
            return null;
          },
        ),
        //signup button
        Padding(
          padding: const EdgeInsets.only(
            right: 12.0,
            bottom: 24.0,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 36.0,
                top: 36.0,
              ),
              child: RaisedButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 24.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 10.0,
                onPressed: signup,
                color: Theme.of(context).primaryColor,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Signup',
                      style: textTheme.button,
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    _isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
