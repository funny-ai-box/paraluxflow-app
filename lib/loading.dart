import 'package:flutter/material.dart';
import 'dart:async';

class LoadingPage extends StatefulWidget {
  @override
  _loadingState createState() => new _loadingState();
}

class _loadingState extends State<LoadingPage> {
  
  @override
  void initState(){
    super.initState();
    new Future.delayed(const Duration(seconds: 2), (){
      print('启动');
      // Navigator.of(context).pushReplacement('app')
    });
  }
  
  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.all(10),
      child: Image.asset(
        'assets/images/welcome.jpg',
        width: double.infinity,
        height: null,
      )
    );
  }
}