import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../constants/routes.dart';

import '../../models/topic.dart';

class TeacherHomeScreen extends StatefulWidget {
  @override
  _TeacherHomeScreenState createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase databaseInstance = FirebaseDatabase.instance;

  String professorName;

  List<Topic> _lastTopicCoveredList = [];

  var _isLoading = false;

  void getProfessorDetails() async {
    //changing state to loading
    setState(() {
      _isLoading = true;
    });

    //gettig logged in user
    FirebaseUser user = await firebaseAuth.currentUser();

    //getting user details from realtime database
    await databaseInstance
        .reference()
        .child("Teachers")
        .child(user.uid)
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> userData = snapshot.value;
      professorName = userData['Name'];
    });

    _lastTopicCoveredList = [];
    //getting last topic covered list
    await databaseInstance
        .reference()
        .child("Teachers")
        .child(user.uid)
        .child("Topic Covered")
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> lastTopicData = snapshot.value;
      lastTopicData.keys.forEach((dbYear) {
        String year = dbYear;
        Map<dynamic, dynamic> yearData = lastTopicData[year];
        yearData.keys.forEach((dbDivision) {
          String division = dbDivision;
          Map<dynamic, dynamic> divisionData = yearData[division];
          divisionData.keys.forEach((dbSubject) {
            String subject = dbSubject;
            String topic = divisionData[subject]['Topic'];
            _lastTopicCoveredList.insert(
              0,
              Topic(
                year: year,
                division: division,
                subject: subject,
                topic: topic,
              ),
            );
          });
        });
      });
    });

    //changing state to not loading
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getProfessorDetails();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    DateTime todaysDate = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Image.asset(
          'assets/icons/menu.png',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_downward),
            onPressed: getProfessorDetails,
          ),
        ],
        centerTitle: true,
        title: Text(
          'Attendance',
          style: textTheme.title,
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //date
                    _buildDateWidget(textTheme, todaysDate),
                    //professor detail
                    _buildProfessorDetailWidget(screenSize, textTheme),
                    //last topic covered
                    _buildLastTopicCoveredWidget(screenSize, textTheme),
                    //build actions widget
                    _buildActionsWidget(screenSize, textTheme),
                  ],
                ),
              ),
            ),
    );
  }

  _buildActionsWidget(Size screenSize, TextTheme textTheme) {
    return SizedBox(
      height: screenSize.height * 0.6,
      width: screenSize.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //heading
          Text(
            'Actions',
            style: textTheme.subhead,
          ),
          SizedBox(
            height: 12.0,
          ),
          //actions grid
          Expanded(
            child: GridView(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              children: <Widget>[
                //make announcement button
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.MAKE_ANNOUNCEMENT_SCREEN,
                      arguments: [professorName],
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 12.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/announcement.png',
                        height: screenSize.height * 0.1,
                        fit: BoxFit.fitHeight,
                      ),
                      Text(
                        'Make \n Announcement',
                        textAlign: TextAlign.center,
                        style: textTheme.button.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                //take attendance button
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.TAKE_ATTENDANCE_SCREEN,
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 12.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/attendance.png',
                        height: screenSize.height * 0.1,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        'Take \n Attendance',
                        textAlign: TextAlign.center,
                        style: textTheme.button.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                //lecture details button
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.LECTURE_DETAILS_SCREEN,
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 12.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/lectures.png',
                        height: screenSize.height * 0.1,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        'Lecture \n Details',
                        textAlign: TextAlign.center,
                        style: textTheme.button.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildLastTopicCoveredWidget(Size screenSize, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //heading
        Text(
          'Last Topic Covered',
          style: textTheme.subhead,
        ),
        SizedBox(
          height: 12.0,
        ),
        Container(
          height: screenSize.height * 0.15,
          width: screenSize.width,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: _lastTopicCoveredList.length,
            itemBuilder: (ctx, index) {
              return _buildLastTopicCard(_lastTopicCoveredList[index], screenSize, textTheme,);
            },
          ),
        ),
        SizedBox(
          height: 12.0,
        ),
      ],
    );
  }

  _buildLastTopicCard(
    Topic topic,
    Size screenSize,
    TextTheme textTheme,
  ) {
    return Container(
      width: screenSize.width * 0.5,
      margin: const EdgeInsets.symmetric(horizontal : 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Color(0xFF4D4D4D),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //title
          Text(
            '${topic.year} / ${topic.division} / ${topic.subject}',
            style: textTheme.subtitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Divider(
            color: Colors.white60,
          ),
          //spacing
          SizedBox(
            height: 8.0,
          ),
          //topic
          Text(
            '${topic.topic}',
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: textTheme.subtitle,
          ),
        ],
      ),
    );
  }

  _buildProfessorDetailWidget(Size screenSize, TextTheme textTheme) {
    return Container(
      width: screenSize.width,
      margin: const EdgeInsets.only(
        top: 36.0,
        bottom: 24.0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 18.0,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF4D4D4D),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10.0,
            offset: Offset(5, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            'Welcome !',
            style: textTheme.button,
          ),
          Text(
            'Prof. $professorName',
            style: textTheme.title,
          ),
        ],
      ),
    );
  }

  _buildDateWidget(TextTheme textTheme, DateTime todaysDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //week day
        Text(
          DateFormat.EEEE().format(todaysDate),
          style: textTheme.body1.copyWith(
            color: Colors.white,
          ),
        ),
        //date row
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //date
            Text(
              DateFormat.d().format(todaysDate),
              style: textTheme.headline.copyWith(
                fontSize: 56.0,
              ),
            ),
            //date suffix
            Text(
              getDayOfMonthSuffix(int.parse(DateFormat.d().format(todaysDate))),
              style: textTheme.headline,
            ),
            //spacing
            SizedBox(
              width: 8.0,
            ),
            //month
            Transform.translate(
              offset: Offset(0.0, 12),
              child: Text(
                DateFormat.MMMM().format(todaysDate) + ", ",
                style: textTheme.title,
              ),
            ),
            //year
            Transform.translate(
              offset: Offset(0.0, 12),
              child: Text(
                DateFormat.y().format(todaysDate),
                style: textTheme.title,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String getDayOfMonthSuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) {
      throw Exception('Invalid day of month');
    }

    if (dayNum >= 11 && dayNum <= 13) {
      return 'TH';
    }

    switch (dayNum % 10) {
      case 1:
        return 'ST';
      case 2:
        return 'ND';
      case 3:
        return 'RD';
      default:
        return 'TH';
    }
  }
}
