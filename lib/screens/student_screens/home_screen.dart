import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../widgets/date_widget.dart';
import '../../widgets/my_progress_indicator.dart';

import '../../constants/routes.dart';

class StudentHomeScreen extends StatefulWidget {
  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final databaseInstance = FirebaseDatabase.instance;

  String percentage = "0";
  String message = "Please Wait...";

  String year = "";
  String division = "";

  List<String> subjects = [];
  List<int> subAttendance = [];

  List<String> totalSubjects = [];
  List<int> totalLectureCount = [];

  List<int> subjectPercentages = [];

  int totalAttendance = 0;
  int studentLecture = 0;

  var _isLoading = false;

  ///[To get list of all subjects]
  void getSubjects() async {
    setState(() {
      _isLoading = true;
    });

    //getting curent logged in user
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser user = await firebaseAuth.currentUser();
    String studentEmailId = user.email;

    int endPoint = studentEmailId.indexOf("@");
    String emid = studentEmailId.substring(0, endPoint);

    //fetching list of subjects and attendance from database
    await databaseInstance
        .reference()
        .child("Students")
        .child(emid)
        .child("Attendance")
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> subjectData = snapshot.value;
      // print(subjectData.keys);
      subjects = [];
      subAttendance = [];
      if (subjectData != null) {
        subjectData.keys.forEach((sub) {
          subjects.add(sub);
          subAttendance.add(subjectData[sub]['total']);
        });
      }
    });

    //fetching year and division
    await databaseInstance
        .reference()
        .child("Students")
        .child(emid)
        .once()
        .then((snapshot) {
      year = snapshot.value['Year'];
      division = snapshot.value['Division'];
    });

    //fetching total lectures count
    await databaseInstance
        .reference()
        .child("Lectures")
        .child(year)
        .child(division)
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> totalSubData = snapshot.value;
      totalSubjects = [];
      totalLectureCount = [];
      if (totalSubData != null) {
        totalSubData.keys.forEach((sub) {
          totalSubjects.add(sub);
          totalLectureCount.add(totalSubData[sub]['total']);
        });
      }
    });

    //calculating attendance percentage
    totalAttendance = 0;
    totalLectureCount.forEach((lec) {
      totalAttendance += lec;
    });

    studentLecture = 0;
    subAttendance.forEach((lec) {
      studentLecture += lec;
    });

    double temp;
    temp = (studentLecture / totalAttendance) * 100;
    percentage = temp.toStringAsFixed(2);

    for (int i = 0; i < subAttendance.length; i++) {
      double subjectTemp;
      subjectTemp = (subAttendance[i] / totalLectureCount[i]) * 100;
      subjectPercentages.add(subjectTemp.ceil());
    }

    //defining message
    if (double.parse(percentage) > 90) {
      message = "You\'re Scoring !";
    } else if (double.parse(percentage) > 75) {
      message = "Nerd Seems To Skip Class Huh !";
    } else if (double.parse(percentage) > 50) {
      message = "Keep Up It\'s Not That Hard...";
    } else if (double.parse(percentage) > 40) {
      message = "Seems Like You Live on Mars...";
    } else {
      message = "Feels Like This Is Not Where Your Heart Lays...";
    }

    //changing state to not loading
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getSubjects();
  }

  List<PieChartSectionData> showingSections() {
    double absentPercentageTemp = 100 - double.parse(percentage);
    String absentPercentage = absentPercentageTemp.toStringAsFixed(2);
    return [
      PieChartSectionData(
        color: Color(0xFF2ecc71),
        value: double.parse(percentage),
        title: "$percentage %",
        radius: 44,
        titleStyle: Theme.of(context).textTheme.title,
      ),
      PieChartSectionData(
        color: Color(0xFFe74c3c),
        value: double.parse(absentPercentage),
        title: "$absentPercentage %",
        radius: 40,
        titleStyle: Theme.of(context).textTheme.title,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Image.asset(
          'assets/icons/menu.png',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).pushNamed(
                Routes.VIEW_ANNOUNCEMENT_SCREEN,
                arguments: [year, division],
              );
            },
          ),
        ],
        centerTitle: true,
        title: Text(
          'Attendance',
          style: textTheme.title,
        ),
      ),
      body: SizedBox(
        height: screenSize.height,
        width: screenSize.width,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
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
                  //heading date
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 22.0,
                      right: 22.0,
                      bottom: 22.0,
                    ),
                    child: DateWidget(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      "Overall Attendence",
                      style: textTheme.subhead,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 22.0,
                      right: 22.0,
                      top: 8.0,
                    ),
                    padding: const EdgeInsets.only(right: 32.0),
                    width: screenSize.width,
                    height: screenSize.height * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                      color: Color(0xFF4D4D4D),
                    ),
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            children: <Widget>[
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: PieChart(
                                    PieChartData(
                                      startDegreeOffset: 180,
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      sectionsSpace: 5,
                                      centerSpaceRadius:
                                          screenSize.height * 0.05,
                                      sections: showingSections(),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Color(0xFF2ecc71),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 12.0,
                                      ),
                                      Text(
                                        'Attended',
                                        style: textTheme.subtitle,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 18.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Color(0xFFe74c3c),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 12.0,
                                      ),
                                      Text(
                                        'Skipped',
                                        style: textTheme.subtitle,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                    ),
                    padding: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0),
                      ),
                      color: Color(0xFF4D4D4D),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        // vertical: 8.0,
                        horizontal: 38.0,
                      ),
                      child: Center(
                        child: Text(
                          '$message',
                          textAlign: TextAlign.center,
                          style: textTheme.subtitle,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 8.0,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    height: screenSize.height * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(
                        width: 4,
                        color: Color(0xFF4d4d4d),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "$totalAttendance",
                              style: textTheme.title,
                            ),
                            Text(
                              "Total",
                            ),
                          ],
                        ),
                        VerticalDivider(
                          thickness: 4,
                          color: Color(0xFF4d4d4d),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "$studentLecture",
                              style: textTheme.title,
                            ),
                            Text("Attended"),
                          ],
                        ),
                        VerticalDivider(
                          thickness: 4,
                          color: Color(0xFF4d4d4d),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "${totalAttendance - studentLecture}",
                              style: textTheme.title,
                            ),
                            Text("Skipped"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      "Subjects",
                      style: textTheme.subhead,
                    ),
                  ),
                  Container(
                    width: screenSize.width,
                    height: screenSize.height * 0.22,
                    padding: const EdgeInsets.only(
                      top: 4.0,
                      bottom: 12.0,
                    ),
                    child: subjects.length == 0
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(22.0),
                              child: Text(
                                'Oops! You Haven\'t Attended Any Lectures Yet...',
                                textAlign: TextAlign.center,
                                style: textTheme.subtitle,
                              ),
                            ),
                          )
                        : AnimationLimiter(
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: subjects.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (ctx, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: Duration(milliseconds: 600),
                                  child: SlideAnimation(
                                    horizontalOffset: 100.0,
                                    child: FadeInAnimation(
                                      child: Container(
                                        width: screenSize.width * 0.4,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                        ),
                                        padding: const EdgeInsets.all(
                                          12.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          color: Color(0xFF4D4D4D),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Text(
                                              subjects[index],
                                              style: textTheme.title,
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                "${subjectPercentages[index]} %",
                                                style: textTheme.subtitle,
                                              ),
                                            ),
                                            MyProgressIndicator(
                                              width: screenSize.width * 0.4,
                                              height: 12,
                                              value: subjectPercentages[index]
                                                  .toDouble(),
                                            ),
                                            Center(
                                              child: Text(
                                                "${subAttendance[index]} out of ${totalLectureCount[index]}",
                                                style: textTheme.body1,
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                "Attended",
                                                style: textTheme.body1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
