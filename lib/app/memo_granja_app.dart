import 'package:flutter/material.dart';
import 'package:memo_granja/app/app_theme.dart';
import 'package:memo_granja/screens/home_screen.dart';

class MemoGranjaApp extends StatelessWidget {
  const MemoGranjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memo Granja',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
