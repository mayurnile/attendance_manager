import 'package:intl/intl.dart';

class Subject {
  static const FE_EVEN_SUBJECTS = ["EM1","EP1","EC1","EM","BEE"];
  static const FE_ODD_SUBJECTS = ["EM2","EP2","EC2","PCE","CP","ED"];

  static const SE_EVEN_SUBJECTS = ["AM3","DLDA","DM","ECCF","DS"];
  static const SE_ODD_SUBJECTS = ["AM4","AA","COA","CG","OS"];

  static const TE_EVEN_SUBJECTS = ["MP","DBMS","CN","TCS","AOS","AAA","MS"];
  static const TE_ODD_SUBJECTS = ["SE","DWM","SPCC","CSS","ML","ACN","ERP","ADS"];

  static const BE_EVEN_SUBJECTS = ["DSIP","MCC","AI","ASS","BD","Robotics"];
  static const BE_ODD_SUBJECTS = ["HMI","DC","HPC","NLP","AWN"];
 
  List<String> getSubjects(String year) {
    DateTime currentDate = DateTime.now();
    int month = int.parse(DateFormat.M().format(currentDate));

    if (month >= 1 && month <= 5) {
      if (year == 'FE') {
        return FE_EVEN_SUBJECTS;
      } else if (year == 'SE') {
        return SE_EVEN_SUBJECTS;
      } else if (year == 'TE') {
        return TE_EVEN_SUBJECTS;
      } else if (year == 'BE') {
        return BE_EVEN_SUBJECTS;
      }
    } else {
      if (year == 'FE') {
        return FE_ODD_SUBJECTS;
      } else if (year == 'SE') {
        return SE_ODD_SUBJECTS;
      } else if (year == 'TE') {
        return TE_ODD_SUBJECTS;
      } else if (year == 'BE') {
        return BE_ODD_SUBJECTS;
      }
    }
    return FE_ODD_SUBJECTS;
  }
}
