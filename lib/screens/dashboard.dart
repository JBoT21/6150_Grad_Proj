import 'package:flutter/material.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Teacher Dashboard"),
    );
  }
}
