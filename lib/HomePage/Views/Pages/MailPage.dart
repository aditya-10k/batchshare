import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:textshare/Elements/MessageBubble.dart';
import 'package:textshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:textshare/HomePage/Bloc/HomePageEvent.dart';

class MailPage extends StatefulWidget {
  const MailPage({super.key});

  @override
  State<MailPage> createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  final mailIdTextEditingController = TextEditingController();
  final mailContentTextEditingController = TextEditingController();
  final textEditingController = TextEditingController();
  List<String> mailContents = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: size.height * 0.70,
          width: size.width * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.08),
            border: BoxBorder.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.white.withOpacity(0.02),
            //     blurRadius: 18,
            //     offset: const Offset(0, 10),
            //   ),
            // ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: mailContents.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      fileType: 'msg',
                      url: '',
                      text: mailContents[index],senderName: '', sentAtIso: ''
                    );
                  },
                ),
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: mailContentTextEditingController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter Text",
                          hintStyle: const TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        // TODO: open file picker
                      },
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.white70,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        setState(() {
                          mailContents.add(
                            mailContentTextEditingController.text,
                          );
                          mailContentTextEditingController.clear();
                        });
                      },
                      icon: const Icon(Icons.send, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        Container(
          height: 200,
          width: 300,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.08),
            border: BoxBorder.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.5),
            //     blurRadius: 18,
            //     offset: const Offset(0, 10),
            //   ),
            // ],
          ),
          child: Column(
            children: [
              Text(
                'Enter your mail-id',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: mailIdTextEditingController,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      context.read<HomePageBloc>().add(GoToHomePage());
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
                      child: Center(
                        child: Text(
                          "< Back",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      //context.read<HomePageBloc>().add(GoToMailPage());
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
            ],
          ),
        ),
      ],
    );
  }
}
