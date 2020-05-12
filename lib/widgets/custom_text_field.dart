import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final bool hideText;
  final bool isSuffix;
  final Function onSaved;
  final Function validator;
  final TextInputType inputType;

  MyTextField({
    @required this.icon,
    @required this.label,
    @required this.hint,
    @required this.hideText,
    @required this.isSuffix,
    @required this.onSaved,
    @required this.validator,
    @required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry myPadding = label == 'Title' || label == 'Topic Covered'
        ? EdgeInsets.only(top: 12.0)
        : EdgeInsets.only(
            left: 36.0,
            right: 36.0,
            top: 24.0,
          );

    return Padding(
      padding: myPadding,
      child: TextFormField(
        keyboardType: inputType,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white,
            size: 24.0,
          ),
          labelText: label,
          labelStyle: Theme.of(context).textTheme.display1,
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.display2,
          errorStyle: Theme.of(context).textTheme.display3,
          border: OutlineInputBorder(),
        ),
        style: Theme.of(context).textTheme.button,
        obscureText: hideText,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
