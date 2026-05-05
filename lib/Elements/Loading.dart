import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: 
      Container(
        padding: EdgeInsets.all(10),
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          border: BoxBorder.all(color: Colors.white , width: 2),
          borderRadius: BorderRadius.circular(20)
        ),
        child: CircularProgressIndicator(color: Colors.blueAccent,),
      ),
    );
  }
}