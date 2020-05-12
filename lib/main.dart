import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './screens/login_screen.dart';

import './screens/student_screens/home_screen.dart';
import './screens/student_screens/view_announcement_screen.dart';

import './screens/teacher_screens/home_screen.dart';
import './screens/teacher_screens/attendance_screen.dart';
import './screens/teacher_screens/attended_students_list.dart';
import './screens/teacher_screens/make_announcement.dart';

import './screens/admin_screens/admin_screen.dart';
import './screens/admin_screens/create_teacher_screen.dart';

import './constants/routes.dart';

void main() => runApp(AttendanceApp());

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Manager',
      theme: ThemeData(
        primaryColor: Color(0xFF1E4ABB),
        canvasColor: Color(0xFF3A3D3A),
        backgroundColor: Color(0xFF4D4D4D),
        buttonColor: Color(0xFF1E4ABB),
        accentColor: Color(0xFF1E4ABB),
        dialogBackgroundColor: Color(0xFF4D4D4D),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        textTheme: TextTheme(
          title: GoogleFonts.raleway(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
          subtitle: GoogleFonts.raleway(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          button: GoogleFonts.raleway(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          display1: GoogleFonts.raleway(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
          display2: GoogleFonts.raleway(
            fontSize: 14.0,
            color: Colors.white60,
            fontWeight: FontWeight.w300,
          ),
          display3: GoogleFonts.raleway(
            fontSize: 14.0,
            color: Colors.red,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
          ),
          display4: GoogleFonts.raleway(
            fontSize: 18.0,
            color: Colors.white60,
            fontWeight: FontWeight.w400,
          ),
          headline: GoogleFonts.raleway(
            fontSize: 26.0,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          body1: GoogleFonts.raleway(
            fontSize: 18.0,
            color: Colors.white60,
            fontWeight: FontWeight.w300,
          ),
          //for date picker
          caption: GoogleFonts.raleway(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          subhead: GoogleFonts.raleway(
            fontSize: 22.0,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      routes: {
        Routes.TEACHER_HOME_SCREEN: (ctx) => TeacherHomeScreen(),
        Routes.TAKE_ATTENDANCE_SCREEN: (ctx) => TakeAttendanceScreen(),
        Routes.LECTURE_DETAILS_SCREEN: (ctx) => AttendedStudentsList(),
        Routes.MAKE_ANNOUNCEMENT_SCREEN: (ctx) => MakeAnnouncementScreen(),
        Routes.STUDENT_HOME_SCREEN: (ctx) => StudentHomeScreen(),
        Routes.VIEW_ANNOUNCEMENT_SCREEN: (ctx) => ViewAnnouncementScreen(),
        Routes.ADMIN_HOME_SCREEN: (ctx) => AdminScreen(),
        Routes.CREATE_TEACHER_SCREEN: (ctx) => CreateTeacherScreen(),
      },
      home: LoginScreen(),
    );
  }
}
