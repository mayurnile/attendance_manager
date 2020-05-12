import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../models/announcement.dart';

class ViewAnnouncementScreen extends StatefulWidget {
  @override
  _ViewAnnouncementScreenState createState() => _ViewAnnouncementScreenState();
}

class _ViewAnnouncementScreenState extends State<ViewAnnouncementScreen> {
  final databaseInstance = FirebaseDatabase.instance;

  String year = "";
  String division = "";

  List<Announcement> _announcements = [];

  Size screenSize;
  TextTheme textTheme;

  Future<void> getAnnouncements() async {
    _announcements = [];

    await databaseInstance
        .reference()
        .child("Announcements")
        .child(year)
        .child(division)
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> announcementData = snapshot.value;

      announcementData.keys.forEach((announcement) {
        String id = announcement;
        List<String> splittedString = id.split(' ');
        String date = splittedString[0];
        String time = splittedString[1] + " " + splittedString[2];
        String title = announcementData[announcement]['Title'];
        String description = announcementData[announcement]['Description'];
        String sentBy = announcementData[announcement]['Sent By'];

        _announcements.insert(
          0,
          Announcement(
            id: id,
            date: date,
            time: time,
            title: title,
            description: description,
            sentBy: sentBy,
          ),
        );
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    List args = ModalRoute.of(context).settings.arguments;
    year = args[0];
    division = args[1];
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
          'Announcements',
          style: textTheme.title,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: FutureBuilder(
          future: getAnnouncements(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              );
            }
            return AnimationLimiter(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _announcements.length,
                itemBuilder: (ctx, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 100.0,
                      child: FadeInAnimation(
                        child: _buildAnnouncementCard(_announcements[index]),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  _buildAnnouncementCard(Announcement announcement) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 12.0,
      ),
      height: screenSize.height * 0.3,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Color(0xFF4D4D4D),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                announcement.title,
                style: textTheme.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                announcement.date,
                style: textTheme.subtitle,
              ),
            ],
          ),
          Divider(
            color: Colors.grey,
          ),
          Expanded(
            child: Container(
              width: screenSize.width,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Color(0xFF414141),
              ),
              child: Text(
                announcement.description,
                textAlign: TextAlign.justify,
                style: textTheme.subtitle.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'By ' + announcement.sentBy,
                style: textTheme.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                announcement.time,
                style: textTheme.display2.copyWith(
                  fontSize: 16.0,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
