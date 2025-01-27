import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_on_boarding/firebase_options.dart';
import 'package:flutter_on_boarding/iintroduction_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/model/add_date.dart';

bool show = true;

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(AdddataAdapter());
  await Hive.openBox<Add_data>('data');
  runApp(const BudgetWallet());
}
// }

class BudgetWallet extends StatelessWidget {
  const BudgetWallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroScreen(),
    );
  }
}
