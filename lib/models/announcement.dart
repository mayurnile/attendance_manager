import 'package:flutter/cupertino.dart';

class Announcement {
  final String id;
  final String date;
  final String time;
  final String title;
  final String description;
  final String sentBy;

  Announcement({
    @required this.id,
    @required this.date,
    @required this.time,
    @required this.title,
    @required this.description,
    @required this.sentBy,
  });
}
