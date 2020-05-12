import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../models/attendance.dart';
import '../../models/subject.dart';

import '../../widgets/custom_drop_down_button.dart';

class AttendedStudentsList extends StatefulWidget {
  @override
  _AttendedStudentsListState createState() => _AttendedStudentsListState();
}

class _AttendedStudentsListState extends State<AttendedStudentsList> {
  Size screenSize;
  TextTheme textTheme;

  final firestoreInstance = Firestore.instance;
  final databaseInstance = FirebaseDatabase.instance;

  String selectedYear = "FE";
  String selectedDivsion = "A";
  String selectedSubject = "";
  String selectedDate = "";

  List<String> _yearsList = ['FE', 'SE', 'TE', 'BE'];
  List<String> _divisionList = ['A', 'B'];
  List<String> _subjectList = [];

  List<StudentAttendance> newww = [];

  bool isLoading = false;

  @override
  void initState() {
    Subject sub = Subject();
    _subjectList = sub.getSubjects(selectedYear);
    selectedSubject = _subjectList[0];
    super.initState();
  }

  void getDataByDate(String date) async {
    selectedDate = date;

    setState(() {
      isLoading = true;
    });

    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser user = await firebaseAuth.currentUser();
    String teacherId = user.uid;

    List<Map<String, bool>> studentDataFromDB = [];
    List<StudentAttendance> studentDataFromFirestore = [];

    await databaseInstance
        .reference()
        .child("Teachers")
        .child(teacherId)
        .child(selectedYear)
        .child(selectedDivsion)
        .child(selectedSubject)
        .child(date.toString())
        .child("Attendance")
        .once()
        .then((DataSnapshot snap) {
      var data = snap.value.toList();

      for (int i = 0; i < data.length; i++) {
        Map data2 = json.decode(data[i]);

        String key = data2.keys.toString();

        var present = data2.values.toList();

        studentDataFromDB.add(
          {
            key: present[0],
          },
        );
      }
    });

    await firestoreInstance
        .collection("Years")
        .document(selectedYear)
        .collection(selectedDivsion)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach(
        (studentData) {
          StudentAttendance student = StudentAttendance(
            id: studentData['Student Id'],
            rollNo: studentData['Roll No'],
            name: studentData['Full Name'],
          );

          studentDataFromFirestore.add(student);
        },
      );
    });

    newww = [];

    for (var i = 0; i < studentDataFromFirestore.length; i++) {
      bool v = studentDataFromDB[i].values.toList()[0];
      StudentAttendance student = StudentAttendance(
        id: studentDataFromFirestore[i].id,
        name: studentDataFromFirestore[i].name,
        rollNo: studentDataFromFirestore[i].rollNo,
        present: v,
      );
      newww.insert(i, student);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Lecture Details',
          style: Theme.of(context).textTheme.title,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //year selection dropdown
              MyDropDowmButton(
                selectedValue: selectedYear,
                icon: Icons.person_pin,
                itemsList: _yearsList,
                width: screenSize.width * 0.7,
                onChanged: (value) {
                  selectedYear = value;
                  Subject sub = Subject();
                  _subjectList = sub.getSubjects(selectedYear);
                  selectedSubject = _subjectList[0];
                  setState(() {});
                },
              ),
              //spacing
              SizedBox(
                height: 12,
              ),
              //division drop down button
              MyDropDowmButton(
                selectedValue: selectedDivsion,
                icon: Icons.category,
                itemsList: _divisionList,
                width: screenSize.width * 0.7,
                onChanged: (value) {
                  selectedDivsion = value;
                  setState(() {});
                },
              ),
              //spacing
              SizedBox(
                height: 12,
              ),
              //subject selection dropdown
              MyDropDowmButton(
                selectedValue: selectedSubject,
                icon: Icons.subject,
                itemsList: _subjectList,
                width: screenSize.width * 0.7,
                onChanged: (value) {
                  selectedSubject = value;
                  setState(() {});
                },
              ),
              //spacing
              SizedBox(
                height: 12,
              ),
              //get list button
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 22.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 10.0,
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.date_range,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      Text(
                        'Select Date',
                        style: textTheme.button,
                      ),
                    ],
                  ),
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2001),
                      lastDate: DateTime(2022),
                    ).then(
                      (date) {
                        String d = DateFormat('dd-MM-yyyy').format(date);
                        getDataByDate(d);
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Column(
                          children: <Widget>[
                            //heading title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Attendance',
                                  style: textTheme.subtitle,
                                  // textAlign: TextAlign.left,
                                ),
                                Text(
                                  selectedDate,
                                  style: textTheme.subtitle,
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(
                                color: Colors.white54,
                              ),
                            ),
                            //table headings
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'Name',
                                    style: textTheme.display4,
                                  ),
                                  Spacer(),
                                  Text(
                                    'Roll No.',
                                    style: textTheme.display4,
                                  ),
                                  SizedBox(
                                    width: 24.0,
                                  ),
                                  Text(
                                    'Present',
                                    style: textTheme.display4,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(
                                color: Colors.white54,
                              ),
                            ),
                            //students list
                            Expanded(
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: newww.length,
                                itemBuilder: (ctx, index) {
                                  String value =
                                      newww[index].present ? 'Yes' : 'No';
                                  Color valueColor = newww[index].present
                                      ? Color(0xFF2ECC71)
                                      : Color(0xFFE74C3C);

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    width: screenSize.width,
                                    height: screenSize.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Color(0xFF414141),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            newww[index].name,
                                            style: textTheme.display1,
                                          ),
                                          Spacer(),
                                          Container(
                                            width: screenSize.width * 0.1,
                                            alignment: Alignment.center,
                                            child: Text(
                                              newww[index].rollNo.toString(),
                                              style: textTheme.display1,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 42.0,
                                          ),
                                          Container(
                                            width: screenSize.width * 0.1,
                                            alignment: Alignment.center,
                                            child: Text(
                                              value,
                                              style:
                                                  textTheme.display1.copyWith(
                                                color: valueColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 12.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // isLoading
                            //     ? Text('wait kro')
                            //     : Text('Data here...')
                            // : DataTable(
                            //     columns: <DataColumn>[
                            //       DataColumn(
                            //           label: Text(
                            //             "Name",
                            //             style: TextStyle(
                            //                 color: Colors.grey,
                            //                 fontSize: 12,
                            //                 fontWeight: FontWeight.w700),
                            //           ),
                            //           numeric: false),
                            //       DataColumn(
                            //           label: Text(
                            //             "Roll No",
                            //             style: TextStyle(
                            //                 color: Colors.grey,
                            //                 fontSize: 12,
                            //                 fontWeight: FontWeight.w700),
                            //           ),
                            //           numeric: true),
                            //       DataColumn(
                            //           label: Text(
                            //             "Present",
                            //             style: TextStyle(
                            //                 color: Colors.grey,
                            //                 fontSize: 12,
                            //                 fontWeight: FontWeight.w700),
                            //           ),
                            //           numeric: false),
                            //     ],
                            //     rows: newww.map((n) {
                            //       DataRow(cells: [
                            //         DataCell(
                            //           isLoading
                            //               ? Text("")
                            //               : Text(
                            //                   n.name,
                            //                   style: TextStyle(
                            //                       color:
                            //                           Color(0xff414141)),
                            //                 ),
                            //         ),
                            //         DataCell(isLoading
                            //             ? Text("")
                            //             : Text(n.id.toString(),
                            //                 style: TextStyle(
                            //                     color:
                            //                         Color(0xff414141)))),
                            //         DataCell(isLoading
                            //             ? Text("")
                            //             : Text(n.present ? "Yes" : "No",
                            //                 style: TextStyle(
                            //                     color: n.present
                            //                         ? Color(0xff2ecc71)
                            //                         : Color(
                            //                             0xffe74c3c)))),
                            //       ]);
                            //     }).toList(),
                            //   ),
                          ],
                        ),
                ),
              )
            ],
          )),
    );
  }
}
