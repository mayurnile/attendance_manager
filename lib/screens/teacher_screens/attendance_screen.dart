import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/student.dart';
import '../../models/subject.dart';

import '../../widgets/custom_drop_down_button.dart';
import '../../widgets/custom_text_field.dart';

class TakeAttendanceScreen extends StatefulWidget {
  @override
  _TakeAttendanceScreenState createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  final firestoreInstance = Firestore.instance;
  final databaseInstance = FirebaseDatabase.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Student> _studentsList = [];
  // List<bool> _attendanceStatus = [];
  // List<Map<String, dynamic>> _attendanceData = [];

  String selectedYear = "FE";
  String selectedDivsion = "A";
  String selectedSubject = "";
  String topicCovered = "";

  List<String> _yearsList = ['FE', 'SE', 'TE', 'BE'];
  List<String> _divisionList = ['A', 'B'];
  List<String> _subjectsList = [];

  Size screenSize;
  TextTheme textTheme;

  bool _isLoading = false;
  bool _isDataChanged = false;

  ///[Fetching students list]
  Future<void> getStudentsList() async {
    //changing state to loading
    setState(() {
      _isLoading = true;
    });

    //clearing previous data in list
    _studentsList = [];

    //getting students list
    await firestoreInstance
        .collection("Years")
        .document(selectedYear)
        .collection(selectedDivsion)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach(
        (studentData) {
          Student student = Student(
            id: studentData['Student Id'],
            rollNo: studentData['Roll No'],
            fullName: studentData['Full Name'],
            emailId: studentData['Email Id'],
            year: selectedYear,
            division: selectedDivsion,
            isAttended: true,
          );

          _studentsList.add(student);
          // _attendanceStatus.add(true);
        },
      );
    });

    //changing state to not loading
    setState(() {
      _isDataChanged = true;
      _isLoading = false;
    });
  }

  ///[Send attendance  data to databse]
  void markAttendance(StateSetter modalSetState) async {
    //changing state to loading
    modalSetState(() {
      _isLoading = true;
    });

    //getting form data
    final form = _formKey.currentState;

    //saving form
    form.save();

    //validating form
    if (form.validate()) {
      //saving to students account
      for (int i = 0; i < _studentsList.length; i++) {
        final std = _studentsList[i];
        int count = 0;
        int endPoint = std.emailId.indexOf('@');
        String emid = std.emailId.substring(0, endPoint);
        //getting previous count
        await databaseInstance
            .reference()
            .child("Students")
            .child(emid)
            .child("Attendance")
            .child(selectedSubject)
            .once()
            .then((snapshot) {
          count = snapshot.value == null ? 0 : snapshot.value['total'];
        });

        //increment if present
        if (std.isAttended) {
          if (count == null) {
            count = 0;
          }
          count++;
        }

        //push to database
        await databaseInstance
            .reference()
            .child("Students")
            .child(emid)
            .child("Attendance")
            .child(selectedSubject)
            .set({
          'total': count,
        });
      }

      //saving to teachers account

      //getting logged in user id
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseUser user = await firebaseAuth.currentUser();
      String teacherId = user.uid;

      DateTime date = DateTime.now();
      DateFormat formatter = DateFormat('dd-MM-yyyy');
      String currentDate = formatter.format(date);

      print('Selected Subject : $selectedSubject');

      //setting topic covered into database
      await databaseInstance
          .reference()
          .child("Teachers")
          .child(teacherId)
          .child("Topic Covered")
          .child(selectedYear)
          .child(selectedDivsion)
          .child(selectedSubject)
          .set({
        'Topic': topicCovered,
      });

      //setting values
      await databaseInstance
          .reference()
          .child("Teachers")
          .child(teacherId)
          .child(selectedYear)
          .child(selectedDivsion)
          .child(selectedSubject)
          .child(currentDate)
          .set({
        'Attendance': _studentsList.map((student) {
          return json.encode({
            student.id: student.isAttended,
          });
        }).toList(),
      });

      //saving to total lectures count
      //getting lectures count
      int lectureCount = 0;
      await databaseInstance
          .reference()
          .child("Lectures")
          .child(selectedYear)
          .child(selectedDivsion)
          .child(selectedSubject)
          .once()
          .then((snapshot) {
        lectureCount = snapshot.value == null ? 0 : snapshot.value['total'];
      });

      //increment the counter
      lectureCount++;

      //pushing to database
      await databaseInstance
          .reference()
          .child("Lectures")
          .child(selectedYear)
          .child(selectedDivsion)
          .child(selectedSubject)
          .set({
        'total': lectureCount,
      });

      Navigator.of(context).pop();
    }

    //changing state to not loading
    modalSetState(() {
      _isLoading = false;
    });
  }

  void showSubjectSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        Subject sub = Subject();
        if (_subjectsList.length == 0) {
          _subjectsList = sub.getSubjects(selectedYear);
          selectedSubject = _subjectsList[0];
        }
        return StatefulBuilder(
          builder: (ctx2, setModalSheet) => Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(22.0),
            width: screenSize.width,
            // height: screenSize.height * 0.3,
            decoration: BoxDecoration(
              color: Theme.of(ctx2).canvasColor,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12.0,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //heading
                  Text(
                    'Select Subject',
                    style: textTheme.title,
                  ),
                  //spacing
                  SizedBox(
                    height: 16.0,
                  ),
                  //subject selection drop down
                  MyDropDowmButton(
                    selectedValue: selectedSubject,
                    icon: Icons.subject,
                    itemsList: _subjectsList,
                    width: screenSize.width * 0.7,
                    onChanged: (value) {
                      setModalSheet(() {
                        selectedSubject = value;
                      });
                    },
                  ),
                  //spacing
                  SizedBox(
                    height: 16.0,
                  ),
                  //topic covered input field
                  MyTextField(
                    icon: Icons.info,
                    label: 'Topic Covered',
                    hint: 'Enter What Topic Taught Today...',
                    hideText: false,
                    isSuffix: false,
                    inputType: TextInputType.text,
                    onSaved: (value) {
                      topicCovered = value;
                    },
                    validator: (String value) {
                      if (value.length == 0) {
                        return 'This Field Can\'t Be Empty !';
                      }
                      return null;
                    },
                  ),
                  //spacing
                  SizedBox(
                    height: 18.0,
                  ),
                  //mark attendance button
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: RaisedButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 18.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: Theme.of(ctx).primaryColor,
                        elevation: 12.0,
                        onPressed: () {
                          markAttendance(setModalSheet);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Done',
                              style: textTheme.button,
                            ),
                            SizedBox(
                              width: 12.0,
                            ),
                            _isLoading
                                ? SizedBox(
                                    height: 24.0,
                                    width: 24.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: 24,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Mark Attendance',
          style: textTheme.title,
        ),
      ),
      //mark attendance button
      floatingActionButton: _isDataChanged
          ? FloatingActionButton(
              onPressed: () {
                showSubjectSelectionSheet(context);
              },
              child: Icon(Icons.done),
            )
          : SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _studentsList.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Select Class & Division And Press the Button To Get List !',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _studentsList.length,
              itemBuilder: (ctx, index) {
                bool isPresent = _studentsList[index].isAttended;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 22.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF5D5D5D),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _studentsList[index].fullName,
                            maxLines: 1,
                            style: textTheme.subtitle,
                          ),
                          Text(
                            _studentsList[index].rollNo.toString(),
                            style: textTheme.title,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Divider(
                        color: Colors.white,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Spacer(),
                          //present button
                          InkWell(
                            onTap: () {
                              _studentsList[index].isAttended = true;
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4.0),
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: isPresent
                                    ? Colors.green
                                    : Colors.transparent,
                              ),
                              child: Text(
                                'Present',
                                style: textTheme.button,
                              ),
                            ),
                          ),
                          //absent button
                          InkWell(
                            onTap: () {
                              _studentsList[index].isAttended = false;
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4.0),
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color:
                                    isPresent ? Colors.transparent : Colors.red,
                              ),
                              child: Text(
                                'Absent',
                                style: textTheme.button,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //year selection dropdown
            MyDropDowmButton(
              selectedValue: selectedYear,
              icon: Icons.person_pin,
              itemsList: _yearsList,
              width: screenSize.width * 0.13,
              onChanged: (value) {
                selectedYear = value;
                _isDataChanged = false;
                setState(() {});
              },
            ),
            //division drop down button
            MyDropDowmButton(
              selectedValue: selectedDivsion,
              icon: Icons.category,
              itemsList: _divisionList,
              width: screenSize.width * 0.13,
              onChanged: (value) {
                selectedDivsion = value;
                _isDataChanged = false;
                setState(() {});
              },
            ),
            //get list button
            RaisedButton(
              padding: const EdgeInsets.symmetric(vertical: 13.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 10.0,
              color: Theme.of(context).primaryColor,
              onPressed: getStudentsList,
              child: _isLoading
                  ? SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.file_download,
                      color: Colors.white,
                      size: 24.0,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
