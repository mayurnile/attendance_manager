import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../widgets/custom_text_field.dart';
import '../widgets/custom_drop_down_button.dart';

import '../constants/routes.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final Curve myCurve = Curves.easeInOut;
  final Duration myDuration = Duration(milliseconds: 1000);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _forgetPasswordFormKey = GlobalKey<FormState>();

  final databaseReference = Firestore.instance;
  final realtimeDatabaseReference = FirebaseDatabase.instance;

  TabController _tabController;

  bool _isExpanded = false;

  String email = "";
  String password = "";
  String fullName = "";
  String studentID = "";
  int rollNo = 0;
  String selectedYear = "FE";
  String selectedDivsion = "A";

  List<String> _yearsList = ['FE', 'SE', 'TE', 'BE'];
  List<String> _divisionList = ['A', 'B'];

  var screenSize;
  var textTheme;

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  void submitForm() async {
    //changing state to loading
    setState(() {
      _isLoading = true;
    });

    //getting form data
    final form = _formKey.currentState;

    //saving form
    form.save();

    //validating the form
    if (form.validate()) {
      //signing in the user
      AuthResult result =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseUser user = result.user;

      //send to admin panel if admin id is logging in
      if (user.email == "admin@gmail.com") {
        //clearing all the fields
        form.reset();

        //redirecting to admin panel
        Navigator.of(context).pushNamed(
          Routes.ADMIN_HOME_SCREEN,
        );
      } else {
        //else normal routing mechanism

        //checking login type
        bool isTeacher = false;

        //checking user type in database
        await realtimeDatabaseReference
            .reference()
            .child("users")
            .child(user.uid)
            .once()
            .then((snapshot) {
          if (snapshot.value['role'] == 'Teacher') {
            print(snapshot.value['role']);
            isTeacher = true;
            return;
          }
        });

        //clearing all the fields
        form.reset();

        //redirecting to respective form based on role
        if (isTeacher) {
          Navigator.of(context).pushReplacementNamed(
            Routes.TEACHER_HOME_SCREEN,
          );
        } else {
          Navigator.of(context).pushReplacementNamed(
            Routes.STUDENT_HOME_SCREEN,
          );
        }
      }
    }

    //changing state to not loading
    setState(() {
      _isLoading = false;
    });
  }

  void signup() async {
    //changing state to loading
    setState(() {
      _isLoading = true;
    });

    //getting form data
    final form = _formKey.currentState;

    //saving the form
    form.save();

    if (form.validate()) {
      //saving data to cloud firestore
      await databaseReference
          .collection("Years")
          .document(selectedYear)
          .collection(selectedDivsion)
          .add({
        'Student Id': studentID,
        'Email Id': email,
        'Full Name': fullName,
        'Roll No': rollNo,
      });

      //creating new user
      AuthResult result =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseUser user = result.user;

      //clearing all fields
      form.reset();

      //setting role in realtime database
      await realtimeDatabaseReference
          .reference()
          .child("users")
          .child(user.uid)
          .set({'role': 'student'});

      int endPoint = user.email.indexOf("@");
      String emid = user.email.substring(0, endPoint);

      await realtimeDatabaseReference
          .reference()
          .child("Students")
          .child(emid)
          .set({
        'Student Id': studentID,
        'Year': selectedYear,
        'Division': selectedDivsion,
        'Attendance': null,
      });
    }
    //changing state to not loading
    setState(() {
      _isLoading = false;
    });
  }

  void getData() {
    databaseReference
        .collection("Years")
        .document("SE")
        .collection("B")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach(
        (f) => print(
          '${f.data}',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            //top container
            _buildTopContainer(),
            //bottom cotainer
            _buildBottomContainer(),
          ],
        ),
      ),
    );
  }

  _buildTopContainer() {
    return AnimatedContainer(
      duration: myDuration,
      curve: myCurve,
      height: _isExpanded ? screenSize.height * 0.2 : screenSize.height * 0.9,
      width: screenSize.width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(52.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          AnimatedOpacity(
            duration: myDuration,
            curve: myCurve,
            opacity: _isExpanded ? 1.0 : 0.0,
            child: SizedBox(
              height: _isExpanded ? screenSize.height * 0.2 : 0.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: Text(
                    'Welcome To \n Attendance Portal',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: textTheme.headline.copyWith(letterSpacing: 1.2),
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: myDuration,
            curve: myCurve,
            opacity: _isExpanded ? 0.0 : 1.0,
            child: SizedBox(
              height: _isExpanded ? 0 : screenSize.height * 0.9,
              child: Column(
                children: <Widget>[
                  //spacing
                  SizedBox(
                    height: screenSize.height * 0.08,
                  ),
                  //top image
                  Image.asset(
                    'assets/images/on_boarding.png',
                    height: screenSize.height * 0.5,
                    width: screenSize.width,
                    fit: BoxFit.contain,
                  ),
                  //headline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'Let us care about your Overhead',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: textTheme.headline,
                    ),
                  ),
                  //spacing
                  SizedBox(
                    height: 8.0,
                  ),
                  //description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'We help you in easily conducting the attendance marking of the students and maintain a central management for better stats',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: textTheme.body1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildBottomContainer() {
    return Stack(
      children: [
        AnimatedContainer(
          duration: myDuration,
          curve: myCurve,
          height:
              _isExpanded ? screenSize.height * 0.8 : screenSize.height * 0.1,
          width: screenSize.width,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
        ),
        AnimatedContainer(
          duration: myDuration,
          curve: myCurve,
          height:
              _isExpanded ? screenSize.height * 0.8 : screenSize.height * 0.1,
          width: screenSize.width,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(56.0),
            ),
          ),
          child: _isExpanded
              ? Column(
                  children: <Widget>[
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    //heading
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorPadding: EdgeInsets.symmetric(
                          horizontal: (screenSize.width / 2) * 0.45),
                      indicatorWeight: 4,
                      labelStyle: textTheme.button.copyWith(
                        fontSize: 24.0,
                      ),
                      unselectedLabelStyle: textTheme.button.copyWith(
                        fontSize: 20.0,
                        color: Colors.grey,
                      ),
                      tabs: <Widget>[
                        Tab(
                          text: 'Login',
                        ),
                        Tab(
                          text: 'Signup',
                        ),
                      ],
                    ),
                    //form body
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TabBarView(
                          controller: _tabController,
                          children: <Widget>[
                            //login form
                            _buildLoginForm(),
                            //signup form
                            _buildSignupForm(),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : FlatButton(
                  onPressed: () {
                    _isExpanded = !_isExpanded;
                    setState(() {});
                  },
                  child: Text(
                    'Login To Your Account',
                    style: textTheme.button,
                  ),
                ),
        ),
      ],
    );
  }

  _buildLoginForm() {
    return Container(
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 500),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: <Widget>[
              SizedBox(
                height: screenSize.height * 0.03,
              ),
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
              //password input field
              MyTextField(
                icon: Icons.lock,
                label: 'Password',
                hint: 'What is you password ?',
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
                  if (value.length < 6) {
                    return 'Password Must Be Atleast 6 Characteres Long !';
                  }
                  return null;
                },
              ),
              //rest buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                  vertical: 36.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    //forget password button
                    FlatButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: _buildForgetPasswordForm,
                      child: Text(
                        '  Forget Password ?',
                        style: textTheme.button.copyWith(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    //Spacing
                    SizedBox(
                      width: 8.0,
                    ),
                    //login button
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: RaisedButton(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 24.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 10.0,
                        onPressed: submitForm,
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Login',
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildForgetPasswordForm() {
    String recoveryEmail = "";
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Form(
            key: _forgetPasswordFormKey,
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: <Widget>[
                    //Heading Text
                    Text(
                      'Forget Password',
                      style: textTheme.title,
                    ),
                    //spacing
                    SizedBox(
                      height: 16.0,
                    ),
                    //email id input field
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          labelText: 'Email Id',
                          labelStyle: Theme.of(context).textTheme.display1,
                          hintText: 'Enter Email Id Of Your Account !',
                          hintStyle: Theme.of(context).textTheme.display2,
                          errorStyle: Theme.of(context).textTheme.display3,
                          border: OutlineInputBorder(),
                        ),
                        style: Theme.of(context).textTheme.button,
                        obscureText: false,
                        onSaved: (value) {
                          recoveryEmail = value;
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
                    ),
                    //recover button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 12.0,
                          top: 12.0,
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
                          onPressed: () {
                            //getting form data
                            final form = _forgetPasswordFormKey.currentState;

                            //saving form
                            form.save();

                            //validatig form
                            if (form.validate()) {
                              //sending otp to emailid
                              FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                              firebaseAuth.sendPasswordResetEmail(
                                  email: recoveryEmail);

                              Navigator.of(context).pop();
                            }
                          },
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Recover',
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _buildSignupForm() {
    String confirmPassword;
    return Container(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: <Widget>[
                SizedBox(
                  height: screenSize.height * 0.03,
                ),
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
                //student id input field
                MyTextField(
                  icon: Icons.contacts,
                  label: 'Student Id',
                  hint: 'Enter the ID give on ICard',
                  hideText: false,
                  isSuffix: false,
                  inputType: TextInputType.text,
                  onSaved: (value) {
                    studentID = value;
                  },
                  validator: (String value) {
                    if (value.length == 0) {
                      return 'This Field Can\'t Be Empty !';
                    }
                    return null;
                  },
                ),
                //roll no input field
                MyTextField(
                  icon: Icons.person,
                  label: 'Roll Number',
                  hint: 'Enter your Roll Number',
                  hideText: false,
                  isSuffix: false,
                  inputType: TextInputType.number,
                  onSaved: (value) {
                    rollNo = int.parse(value);
                  },
                  validator: (String value) {
                    if (value.length == 0) {
                      return 'This Field Can\'t Be Empty !';
                    }
                    if (int.parse(value) > 80) {
                      return 'Enter A Valid Roll Number !';
                    }
                    return null;
                  },
                ),
                //year selection input
                Padding(
                  padding: const EdgeInsets.only(
                    left: 36.0,
                    right: 36.0,
                    top: 24.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      //year selection dropdown
                      MyDropDowmButton(
                        selectedValue: selectedYear,
                        icon: Icons.person_pin,
                        itemsList: _yearsList,
                        width: screenSize.width * 0.2,
                        onChanged: (value) {
                          selectedYear = value;
                          setState(() {});
                        },
                      ),
                      //division drop down button
                      MyDropDowmButton(
                        selectedValue: selectedDivsion,
                        icon: Icons.category,
                        itemsList: _divisionList,
                        width: screenSize.width * 0.2,
                        onChanged: (value) {
                          selectedDivsion = value;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 44.0,
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
                SizedBox(
                  height: 36.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
