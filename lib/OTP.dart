import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  bool _isOtpValid = false;

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      FocusScope.of(context).nextFocus();
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }

    // Check if all OTP fields are filled
    _isOtpValid = _otpControllers.every((controller) => controller.text.length == 1);
    setState(() {});
  }

  void _verifyOtp() {
    String correctOtp = "1234";
    String enteredOtp = _otpControllers.map((controller) => controller.text).join();

    if (enteredOtp == correctOtp) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP Verified Successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incorrect OTP!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // OTP Verification title
            Text(
              'OTP Verification',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Enter the OTP sent to your email.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),

            // OTP Input Fields (4 Digits)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: 60,
                  height: 60,
                  child: TextField(
                    controller: _otpControllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    onChanged: (value) => _onOtpChanged(value, index),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 30),

            // Verify Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isOtpValid ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOtpValid ? Color(0xFF07574B) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Verify",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


