import 'package:flutter/foundation.dart';

class Student {
  final String id;
  final int rollNo;
  final String fullName;
  final String emailId;
  final String year;
  final String division;
  bool isAttended;
  // final String currentYear;
  // final String currentDivision;

  Student({
    @required this.id,
    @required this.rollNo,
    @required this.fullName,
    @required this.emailId,
    @required this.year,
    @required this.division,
    @required this.isAttended,
    // @required this.currentYear,
    // @required this.currentDivision,
  });
}
