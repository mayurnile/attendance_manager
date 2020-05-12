import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../widgets/custom_drop_down_button.dart';
import '../../widgets/custom_text_field.dart';

class MakeAnnouncementScreen extends StatefulWidget {
  @override
  _MakeAnnouncementScreenState createState() => _MakeAnnouncementScreenState();
}

class _MakeAnnouncementScreenState extends State<MakeAnnouncementScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final databaseInstance = FirebaseDatabase.instance;

  String title = "";
  String description = "";
  String professorName = "";
  String selectedYear = "FE";
  String selectedDivsion = "A";

  List<String> _yearsList = ['FE', 'SE', 'TE', 'BE'];
  List<String> _divisionList = ['A', 'B'];

  var _isLoading = false;

  void makeAnnouncement(BuildContext context) async {
    //changing state to loading
    setState(() {
      _isLoading = true;
    });

    //getting form data
    final form = _formKey.currentState;

    //saving form
    form.save();

    //validating the form
    if (form.validate()) {
      //Getting today's date and time
      DateTime date = DateTime.now();
      DateFormat dateFormatter = DateFormat('dd-MM-yyyy hh:mm a');
      String uploadDate = dateFormatter.format(date);

      //pushing data to realtime database
      await databaseInstance
          .reference()
          .child("Announcements")
          .child(selectedYear)
          .child(selectedDivsion)
          .child(uploadDate)
          .set({
        'Title': title,
        'Description': description,
        'Sent By': professorName,
      });
    }

    //changing state to not loading
    setState(() {
      _isLoading = false;
    });

    //routing to previous page
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    List args = ModalRoute.of(context).settings.arguments;
    professorName = args[0];
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Make Announcement',
          style: textTheme.title,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                //year selection dropdown
                MyDropDowmButton(
                  selectedValue: selectedYear,
                  icon: Icons.person_pin,
                  itemsList: _yearsList,
                  width: screenSize.width * 0.7,
                  onChanged: (value) {
                    selectedYear = value;
                    setState(() {});
                  },
                ),
                //spacing
                SizedBox(
                  height: 12,
                ),
                //division drop down button
                MyDropDowmButton(
                  selectedValue: selectedDivsion,
                  icon: Icons.category,
                  itemsList: _divisionList,
                  width: screenSize.width * 0.7,
                  onChanged: (value) {
                    selectedDivsion = value;
                    setState(() {});
                  },
                ),
                //title input field
                MyTextField(
                  icon: Icons.title,
                  label: 'Title',
                  hint: 'Enter Title For Announcement',
                  hideText: false,
                  isSuffix: false,
                  inputType: TextInputType.multiline,
                  onSaved: (value) {
                    title = value;
                  },
                  validator: (String value) {
                    if (value.length == 0) {
                      return 'This Field Can\'t Be Empty !';
                    }
                    return null;
                  },
                ),
                //description input field
                Padding(
                  padding: const EdgeInsets.only(
                    top: 12.0,
                    bottom: 12.0,
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.textsms,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      labelText: 'Description',
                      labelStyle: Theme.of(context).textTheme.display1,
                      hintText: 'Enter Description Of Announcement',
                      hintStyle: Theme.of(context).textTheme.display2,
                      errorStyle: Theme.of(context).textTheme.display3,
                      border: OutlineInputBorder(),
                    ),
                    style: Theme.of(context).textTheme.button,
                    onSaved: (value) {
                      description = value;
                    },
                    validator: (String value) {
                      if (value.length == 0) {
                        return 'This Field Can\'t Be Empty !';
                      }
                      return null;
                    },
                  ),
                ),
                //spacing
                SizedBox(
                  height: 12.0,
                ),
                //announce button
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: RaisedButton(
                      onPressed: () {
                        makeAnnouncement(context);
                      },
                      elevation: 8.0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 18.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Announce',
                            style: textTheme.button,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.announcement,
                                  size: 24.0,
                                  color: Colors.white,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
