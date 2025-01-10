import 'package:flutter/material.dart';
import 'package:flutter_on_boarding/data/model/add_date.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Add_Screen extends StatefulWidget {
  const Add_Screen({Key? key});

  @override
  State<Add_Screen> createState() => _Add_ScreenState();
}

class _Add_ScreenState extends State<Add_Screen> {
  final box = Hive.box<Add_data>('data');
  DateTime date = DateTime.now();
  String? selectedCategory;
  String? selectedType;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final List<String> categories = [
    "Food",
    "Transport",
    "Utility",
    "Groceries",
    "Merchantise"
  ];
  final List<String> entryTypes = ['Online', "Cash"];

  // Speech-to-Text variables
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            backgroundContainer(context),
            Positioned(
              top: 120,
              child: mainContainer(),
            ),
          ],
        ),
      ),
    );
  }

  Container mainContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 550,
      width: 340,
      child: Column(
        children: [
          SizedBox(height: 50),
          categoryDropdown(),
          SizedBox(height: 30),
          descriptionField(),
          SizedBox(height: 30),
          amountField(),
          SizedBox(height: 30),
          typeDropdown(),
          SizedBox(height: 30),
          dateField(),
          Spacer(),
          actionButtons(),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Cash In Button
        ElevatedButton(
          onPressed: () {
            if (selectedCategory != null) {
              var newEntry = Add_data(
                'Income',
                amountController.text,
                date,
                descriptionController.text,
                selectedCategory!,
              );
              box.add(newEntry);
              Navigator.of(context).pop();
            } else {
              showMessage("Please select a category.");
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Cash In',
            style: TextStyle(color: Colors.white),
          ),
        ),
        // Cash Out Button
        ElevatedButton(
          onPressed: () {
            if (selectedCategory != null) {
              var newEntry = Add_data(
                'Expense',
                amountController.text,
                date,
                descriptionController.text,
                selectedCategory!,
              );
              box.add(newEntry);
              Navigator.of(context).pop();
            } else {
              showMessage("Please select a category.");
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Cash Out',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Speech-to-Text listening function
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _voiceInput = val.recognizedWords;
            descriptionController.text =
                _voiceInput; // Set voice input as the description
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Function to show a SnackBar message
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget dateField() {
    return Container(
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5))),
      width: 300,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100));
          if (newDate == null) return;
          setState(() {
            date = newDate;
          });
        },
        child: Text(
          'Date : ${date.year} / ${date.day} / ${date.month}',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Padding typeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: DropdownButton<String>(
          value: selectedType,
          onChanged: (value) {
            setState(() {
              selectedType = value!;
            });
          },
          items: entryTypes
              .map((e) => DropdownMenuItem(
            child: Row(
              children: [Text(e, style: TextStyle(fontSize: 18))],
            ),
            value: e,
          ))
              .toList(),
          hint: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Payment Method',
              style: TextStyle(color: Colors.black),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Padding amountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            controller: amountController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              labelText: 'Amount',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5)),
              ),
            ),
          ),
          // Voice Input Button
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () async {
                if (!_isListening) {
                  bool available = await _speech.initialize(
                    onStatus: (val) {
                      print('onStatus: $val');
                      if (val == 'notListening') {
                        setState(() => _isListening = false);
                      }
                    },
                    onError: (val) => print('onError: $val'),
                  );
                  if (available) {
                    setState(() => _isListening = true);
                    _speech.listen(
                      onResult: (val) => setState(() {
                        _voiceInput = val.recognizedWords;
                        amountController.text = _voiceInput; // Set voice input as the amount
                      }),
                    );
                  }
                } else {
                  setState(() => _isListening = false);
                  _speech.stop();
                }
              },
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ?Color(0xff368983): Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Padding descriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              labelText: 'Description',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5)),
              ),
            ),
          ),
          // Voice Input Button
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: _listen,
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Color(0xff368983): Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5)),
        ),
        child: DropdownButton<String>(
          value: selectedCategory,
          onChanged: (value) {
            setState(() {
              selectedCategory = value!;
            });
          },
          items: categories
              .map((e) => DropdownMenuItem(
            child: Row(
              children: [Text(e, style: TextStyle(fontSize: 18))],
            ),
            value: e,
          ))
              .toList(),
          hint: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Category',
              style: TextStyle(color: Colors.black),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Column backgroundContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: Color(0xff368983),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'New Entry',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(width: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}