import 'package:batchshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:batchshare/HomePage/Bloc/HomePageEvent.dart';
import 'package:batchshare/HomePage/Bloc/HomePageState.dart';
import 'package:batchshare/HomePage/Views/Pages/UrlShortenerDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final Widget? titleWidget;
  final Widget? leading;
  final Widget? trailing;
  final bool showHeader;
  final bool showBackButton;

  const AppScaffold({
    super.key,
    required this.child,
    this.titleWidget,
    this.leading,
    this.trailing,
    this.showHeader = true,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    Widget buildLeading(BuildContext context) {
      if (showBackButton) {
        return Padding(
          padding: EdgeInsets.only(left: isDesktop ? 50 : 20),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.black.withOpacity(0.3),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      }

      if (leading != null) {
        return leading!;
      }

      // Default Homepage Shorten Button
      return Padding(
        padding: EdgeInsets.only(left: isDesktop ? 50 : 20),
        child: InkWell(
          onTap: () {
            Get.dialog(const UrlShortenerDialog(), barrierDismissible: true);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : 12,
              vertical: isDesktop ? 10 : 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.3),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.link,
                  color: Colors.white,
                  size: isDesktop ? 18 : 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'SHORTEN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 16 : 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildTrailing(BuildContext context) {
      if (trailing != null) {
        return trailing!;
      }

      // Default Homepage Rename Button (fetches name from Bloc)
      return BlocBuilder<HomePageBloc, HomePageState>(
        builder: (context, state) {
          String name = '';
          if (state is HomePageInitial) name = state.name;
          if (state is ConnectionEstablished) name = state.name;
          if (state is MailChosen) name = state.name;

          if (name.isEmpty) return const SizedBox();

          return Padding(
            padding: EdgeInsets.only(right: isDesktop ? 50 : 20),
            child: InkWell(
              onTap: () {
                context.read<HomePageBloc>().add(Rename());
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20 : 12,
                  vertical: isDesktop ? 10 : 6,
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 16 : 12,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    Widget buildTitle() {
      if (titleWidget != null) {
        return titleWidget!;
      }

      return Text(
        'Batch Share',
        style: TextStyle(
          color: Colors.white,
          fontSize: isDesktop ? 28 : 22,
          fontWeight: FontWeight.bold,
          letterSpacing: isDesktop ? 10 : 6,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: Stack(
        children: [
          Image.asset(
            'assets/ffflux1.png',
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
          SafeArea(
            minimum: EdgeInsets.only(
              top: isDesktop ? 0 : 35.0,
              bottom: isDesktop ? 0 : 15.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showHeader) ...[
                  SizedBox(height: isDesktop ? 20 : 10),
                  SizedBox(
                    height: isDesktop ? 50 : 40,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: buildLeading(context),
                        ),
                        Align(alignment: Alignment.center, child: buildTitle()),
                        Align(
                          alignment: Alignment.centerRight,
                          child: buildTrailing(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 15 : 10),
                ],
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
