import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:textshare/Config/ResponsiveWidget.dart';
import 'package:textshare/Elements/Loading.dart';
import 'package:textshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:textshare/HomePage/Bloc/HomePageEvent.dart';
import 'package:textshare/HomePage/Bloc/HomePageState.dart';
import 'package:textshare/HomePage/Views/Pages/ChatPage.dart';
import 'package:textshare/HomePage/Views/Pages/InitialPage.dart';
import 'package:textshare/HomePage/Views/Pages/LandingPage.dart';
import 'package:textshare/HomePage/Views/Pages/MailPage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? name;
  @override
  void initState() {
    super.initState();
    context.read<HomePageBloc>().add(AppStartUp());
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      portraitView: Container(color: Colors.red),
      landscapeView: Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: Stack(
          children: [
            Image.asset(
              'assets/ffflux1.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            BlocBuilder<HomePageBloc, HomePageState>(
              builder: (context, state) {
                if (state is RenameRequired) {
                  return InitialPage(isRename: true);
                }
                if (state is NameRequired) {
                  return InitialPage(isRename: false);
                }
                if (state is HomePageInitial ||
                    state is ConnectionEstablished ||
                    state is MailChosen) {
                  String name = '';
                  if (state is HomePageInitial) name = state.name;
                  if (state is ConnectionEstablished) name = state.name;
                  if (state is MailChosen) name = state.name;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 60),
                      SizedBox(
                        height: 80,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            // Center title (horizontal only)
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Text Share',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 10,
                                ),
                              ),
                            ),

                            // Right-side button
                            if (name.isNotEmpty)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 50),
                                  child: InkWell(
                                    onTap: () {
                                      context.read<HomePageBloc>().add(
                                            Rename(),
                                          );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.black.withOpacity(0.3),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 60),
                      Center(
                        child: BlocBuilder<HomePageBloc, HomePageState>(
                          builder: (context, state) {
                            if (state is HomePageInitial) {
                              return LandingPage();
                            }
                            if (state is ConnectionEstablished) {
                              return ChatPage(state: state);
                            }
                            if (state is MailChosen) {
                              return MailPage();
                            } else {
                              return Loading();
                            }
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Loading();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
