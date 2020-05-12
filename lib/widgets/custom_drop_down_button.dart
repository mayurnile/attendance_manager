import 'package:flutter/material.dart';

class MyDropDowmButton extends StatelessWidget {
  final String selectedValue;
  final IconData icon;
  final List<String> itemsList;
  final double width;
  final Function onChanged; 
  
  MyDropDowmButton({
    @required this.selectedValue,
    @required this.icon,
    @required this.itemsList,
    @required this.width,
    @required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: Color(0xFF2C2C2C),
          width: 1.6,
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 12.0,
          ),
          Icon(
            icon,
            color: Colors.white,
          ),
          DropdownButton<String>(
            underline: SizedBox.shrink(),
            icon: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Transform.rotate(
                angle: -1.6,
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 18.0,
                ),
              ),
            ),
            value: selectedValue,
            items: itemsList.map((String year) {
              return DropdownMenuItem(
                value: year,
                child: SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.only(left : 12.0),
                    child: Text(
                      year,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.display1,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
