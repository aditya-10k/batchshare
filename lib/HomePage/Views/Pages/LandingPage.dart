import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:textshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:textshare/HomePage/Bloc/HomePageEvent.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  final codeTextEditingController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 500,
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 230,
                padding: EdgeInsets.fromLTRB(25, 25, 25, 25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: BoxBorder.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Join a room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Pinput(
                      length: 6,
                      controller: codeTextEditingController,
                      defaultPinTheme: PinTheme(
                        height: 40,
                        width: 35,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withOpacity(0.3),
                          border: BoxBorder.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        height: 40,
                        width: 35,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontSize: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.indigo, width: 2),
                          color: Colors.white,
                        ),
                      ),
                      errorPinTheme: PinTheme(
                        height: 40,
                        width: 35,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.redAccent, width: 2),
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        context.read<HomePageBloc>().add(
                          JoinRoom(codeTextEditingController.text),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black.withOpacity(0.6),
                          border: BoxBorder.all(color: Colors.black, width: 2),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Enter Code',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 50),
              VerticalDivider(
                color: Colors.white,
                thickness: 1.5,
                width: 50,
                indent: 100,
                endIndent: 100,
                radius: BorderRadius.circular(20),
              ),
              SizedBox(width: 50),
              Container(
                height: 230,
                width: 290,
                padding: EdgeInsets.fromLTRB(25, 25, 25, 25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  border: BoxBorder.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        print('tapped');
                        context.read<HomePageBloc>().add(CreateRoom());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black.withOpacity(0.6),
                          border: BoxBorder.all(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          'Get a room :)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        context.read<HomePageBloc>().add(GoToMailPage());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black.withOpacity(0.6),
                          border: BoxBorder.all(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          'Mail it !',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
