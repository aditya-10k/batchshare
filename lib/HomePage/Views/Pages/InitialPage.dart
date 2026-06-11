import 'dart:ui';

import 'package:batchshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:batchshare/HomePage/Bloc/HomePageEvent.dart';
import 'package:batchshare/HomePage/Views/Pages/LandingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:batchshare/Elements/AppScaffold.dart';


class InitialPage extends StatefulWidget {
  final bool isRename;

  const InitialPage({super.key, required this.isRename});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final codeTextEditingController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String? existingName = pref.getString("Name");
    if (existingName != null && existingName.isNotEmpty) {
      setState(() {
        nameController.text = existingName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;
    return AppScaffold(
      showHeader: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: isDesktop ? 60 : 20),
            Center(
              child: Text(
                'Batch Share',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                ),
              ),
            ),
            SizedBox(height: isDesktop ? 40 : 20),
            Center(
              child: Container(
                width: size.width > 700 ? size.width * 0.4 : size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.isRename
                                ? 'Rename?'
                                : 'Just one Quick thing ...',
                            style: const TextStyle(
                              letterSpacing: 2,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                          const Spacer(),
                          widget.isRename
                              ? InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    context.read<HomePageBloc>().add(
                                      AppStartUp(),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      '<Back',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'This name will be visible to others in the room',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextField(
                        controller: nameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Barney Stinson',
                          hintStyle: const TextStyle(
                            color: Colors.white38,
                            letterSpacing: 1.2,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            final name = nameController.text.trim();

                            if (name.isEmpty) {
                              Get.snackbar(
                                'Oops',
                                'Please enter a valid name',
                                colorText: Colors.white,
                                backgroundColor: Colors.redAccent.withValues(
                                  alpha: 0.7,
                                ),
                                maxWidth: 300,
                              );
                            } else {
                              context.read<HomePageBloc>().add(SaveName(name));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

