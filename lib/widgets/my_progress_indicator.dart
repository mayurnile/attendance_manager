import 'package:flutter/material.dart';

class MyProgressIndicator extends StatelessWidget {
  final double width;
  final double height;
  final double value;

  MyProgressIndicator({
    @required this.width,
    @required this.height,
    @required this.value,
  });

  @override
  Widget build(BuildContext context) {

    Color color;
    if(value > 90){
      color = Color(0xFF27ae60); //deep green
    } else if(value > 75){
      color = Color(0xFF2ecc71); //light green
    } else if(value > 50){
      color = Color(0xFFf39c12); //light yellow
    } else if(value > 40){
      color = Color(0xFFd35400); //deep orange
    } else {
      color = Color(0xFFc0392b); //deep red
    }
 
    return Stack(
      children: <Widget>[
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Theme.of(context).canvasColor,
          ), 
        ),
        Container(
            height: height,
            width: width * (value/100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: color,
            ),
          ),
      ],
    );
  }
}
