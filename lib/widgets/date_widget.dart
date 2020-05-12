import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime todaysDate = DateTime.now();
    TextTheme textTheme = Theme.of(context).textTheme;
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
