import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../widgets/date_widget.dart';

import '../../constants/routes.dart';

class AdminScreen extends StatelessWidget {
  int percentage = 70;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Image.asset(
          'assets/icons/menu.png',
        ),
        centerTitle: true,
        title: Text(
          'Admin Controls',
          style: textTheme.title,
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 22.0,
            right: 22.0,
            bottom: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //heading date
              DateWidget(),
              //miscellaneous information
              _buildMiscellaneousInformation(
                context,
                screenSize,
                textTheme,
              ),
              //average attendance information
              _buildAverageAttendanceInformation(
                context,
                screenSize,
                textTheme,
              ),
              //actions
              _buildActions(
                context,
                screenSize,
                textTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildActions(
    BuildContext context,
    Size screenSize,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Actions',
          textAlign: TextAlign.start,
          style: textTheme.title,
        ),
        //actions grid
        Container(
          height: screenSize.height * 0.4,
          width: screenSize.width,
          margin: const EdgeInsets.only(
            top: 12.0,
            bottom: 12.0,
          ),
          child: GridView(
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1 / 1,
              crossAxisSpacing: 22,
              mainAxisSpacing: 22,
            ),
            children: <Widget>[
              //get stats button
              RaisedButton(
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 12.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Image.asset(
                      'assets/icons/stats.png',
                      height: screenSize.height * 0.07,
                      fit: BoxFit.fitHeight,
                    ),
                    Text(
                      'Get \n Statistics',
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
                    Routes.CREATE_TEACHER_SCREEN,
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
                      'assets/icons/new_teacherpng.png',
                      height: screenSize.height * 0.1,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      'Create \n Teacher',
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
    );
  }

  List<PieChartSectionData> showingSections(TextTheme textTheme) {
    // String percentage = "70";
    double absentPercenage = 100 - percentage.toDouble();
    return [
      PieChartSectionData(
        color: Color(0xFF2ecc71),
        value: percentage.toDouble(),
        title: "$percentage %",
        radius: 44,
        titleStyle: textTheme.title,
      ),
      PieChartSectionData(
        color: Color(0xFFe74c3c),
        value: absentPercenage,
        title: "$absentPercenage %",
        radius: 40,
        titleStyle: textTheme.title,
      ),
    ];
  }

  _buildAverageAttendanceInformation(
    BuildContext context,
    Size screenSize,
    TextTheme textTheme,
  ) {
    return Container(
      width: screenSize.width,
      height: screenSize.height * 0.3,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Theme.of(context).backgroundColor,
      ),
      child: Stack(
        children: <Widget>[
          //pie chart
          Transform.translate(
            offset: Offset(-22.0, -12.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  startDegreeOffset: 180,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 5,
                  centerSpaceRadius: screenSize.height * 0.05,
                  sections: showingSections(textTheme),
                ),
              ),
            ),
          ),
          //information overview
          Positioned(
            right: 8,
            top: 18,
            child: Container(
              height: screenSize.height * 0.2,
              width: screenSize.width * 0.4,
              alignment: Alignment.center,
              child: Text(
                'On Average $percentage% Students Attend Their Lecture!',
                textAlign: TextAlign.center,
                style: textTheme.subtitle.copyWith(
                  fontSize: 22.0,
                ),
              ),
            ),
          ),
          //legend
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: <Widget>[
                // indicator
                Container(
                  height: 18.0,
                  width: 18.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color(0xFF2ecc71),
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                //indicator text
                Text('Present', style: textTheme.subhead),
                SizedBox(
                  width: 16.0,
                ),
                //indicator
                Container(
                  height: 18.0,
                  width: 18.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color(0xFFe74c3c),
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                //indicator text
                Text('Absent', style: textTheme.subhead),
                SizedBox(
                  width: 12.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildMiscellaneousInformation(
    BuildContext context,
    Size screenSize,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: <Widget>[
          //total students count
          Flexible(
            flex: 1,
            child: Container(
              height: screenSize.height * 0.15,
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 17.0,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Theme.of(context).backgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  //student image
                  Image.asset(
                    'assets/icons/student.png',
                    height: screenSize.height * 0.07,
                  ),
                  //student title
                  Text(
                    'Students',
                    style: textTheme.subtitle,
                  ),
                  //student count
                  Text(
                    '1200', //TODO, calculate this
                    style: textTheme.subtitle,
                  ),
                ],
              ),
            ),
          ),
          //total steacher count
          Flexible(
            flex: 1,
            child: Container(
              height: screenSize.height * 0.15,
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 17.0,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Theme.of(context).backgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  //teacher image
                  Image.asset(
                    'assets/icons/teacher.png',
                    height: screenSize.height * 0.07,
                  ),
                  //teacher title
                  Text(
                    'Teachers',
                    style: textTheme.subtitle,
                  ),
                  //teacher count
                  Text(
                    '36', //TODO, calculate this
                    style: textTheme.subtitle,
                  ),
                ],
              ),
            ),
          ),
          //lectures steacher count
          Flexible(
            flex: 1,
            child: Container(
              height: screenSize.height * 0.15,
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 17.0,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Theme.of(context).backgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  //lectures image
                  Image.asset(
                    'assets/icons/lectures.png',
                    height: screenSize.height * 0.07,
                  ),
                  //lectures title
                  Text(
                    'Lectures', //TODO, calculate this
                    style: textTheme.subtitle,
                  ),
                  //lectures count
                  Text(
                    '128',
                    style: textTheme.subtitle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
