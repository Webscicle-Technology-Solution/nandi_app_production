import 'package:flutter/material.dart';

class NotificationSecondPage extends StatefulWidget {
  const NotificationSecondPage({super.key});

  @override
  State<NotificationSecondPage> createState() => _NotificationSecondPageState();
}

class _NotificationSecondPageState extends State<NotificationSecondPage> {
  String message="";
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final arguments=ModalRoute.of(context)!.settings.arguments;
    if(arguments!=null){
      Map? pushArguments=arguments as Map;
      setState(() {
        message=pushArguments["message"];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        body: Center(child: Container(child: Text("Push message:$message"),),),
      ),
    );
  }
}