import 'package:batchshare/Elements/Loading.dart';
import 'package:batchshare/Elements/AppScaffold.dart';
import 'package:batchshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:batchshare/HomePage/Bloc/HomePageEvent.dart';
import 'package:batchshare/HomePage/Bloc/HomePageState.dart';
import 'package:batchshare/HomePage/Views/Pages/ChatPage.dart';
import 'package:batchshare/HomePage/Views/Pages/InitialPage.dart';
import 'package:batchshare/HomePage/Views/Pages/LandingPage.dart';
import 'package:batchshare/HomePage/Views/Pages/MailPage.dart';
import 'package:batchshare/HomePage/Views/Pages/UrlShortenerDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

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
    return BlocListener<HomePageBloc, HomePageState>(
      listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        if (state is NameRequired) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PopScope(
                canPop: false,
                child: InitialPage(isRename: false),
              ),
            ),
          );
        } else if (state is RenameRequired) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InitialPage(isRename: true)),
          ).then((_) {
            context.read<HomePageBloc>().add(AppStartUp());
          });
        } else if (state is ConnectionEstablished) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage(state: state)),
          ).then((_) {
            context.read<HomePageBloc>().add(GoToHomePage());
          });
        } else if (state is MailChosen) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MailPage()),
          ).then((_) {
            context.read<HomePageBloc>().add(GoToHomePage());
          });
        } else if (state is HomePageInitial) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: BlocBuilder<HomePageBloc, HomePageState>(
        buildWhen: (previous, current) => current is HomePageInitial,
        builder: (context, state) {
          if (state is HomePageInitial) {
            return const AppScaffold(
              child: LandingPage(),
            );
          }
          return const Scaffold(
            backgroundColor: Color(0xFF101010),
            body: Center(child: Loading()),
          );
        },
      ),
    );
  }
}

