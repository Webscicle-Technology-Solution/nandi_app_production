import 'package:flutter/material.dart';

class NotificationFirstPage extends StatefulWidget {
  const NotificationFirstPage({super.key});

  @override
  State<NotificationFirstPage> createState() => _NotificationFirstPageState();
}

class _NotificationFirstPageState extends State<NotificationFirstPage> {
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(body: Center(child: Container(child: Text("Push Notification"),),),),
    );
  }
}