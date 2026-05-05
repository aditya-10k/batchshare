import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:textshare/Elements/Loading.dart';
import 'package:textshare/HomePage/Bloc/HomePageEvent.dart';
import 'package:textshare/HomePage/Bloc/HomePageState.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  StompClient? service;
  StreamSubscription? socketsub;
  final List<Map<String, dynamic>> messages = [];

  final dummyMessages = [
    // {
    //   "sentBy": "YOU",
    //   "type": "TEXT",
    //   "message": "Hey, sending files now!",
    //   "url": ""
    // },
    // {
    //   "sentBy": "YOU",
    //   "type": "FILE",
    //   "message": "",
    //   "url": "https://res.cloudinary.com/demo/image/upload/sample.jpg"
    // },
    // {
    //   "sentBy": "FRIEND",
    //   "type": "FILE",
    //   "message": "",
    //   "url": "https://res.cloudinary.com/demo/raw/upload/sample.pdf"
    // },
    // {
    //   "sentBy": "FRIEND",
    //   "type": "FILE",
    //   "message": "",
    //   "url": "https://res.cloudinary.com/demo/video/upload/dog.mp4"
    // },
    // {
    //   "sentBy": "YOU",
    //   "type": "TEXT",
    //   "message": "Here's a PNG too",
    //   "url": ""
    // },
    // {
    //   "sentBy": "YOU",
    //   "type": "FILE",
    //   "message": "",
    //   "url": "https://res.cloudinary.com/demo/image/upload/cat.png"
    // }
  ];

  HomePageBloc() : super(HomePageInitial('')) {
    on<AppStartUp>((event, emit) async {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      String? name = pref.getString("Name");
      print("The name is $name" );

      if (name == null) {
        emit(NameRequired());
      } else {
        emit(HomePageInitial(name));
      }
    });

    on<SaveName>((event, emit) async {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("Name", event.name);
      emit(HomePageInitial(event.name));
      Get.dialog(Loading());
      Get.back();
    });

    on<Rename>((event, emit) async {
      emit(RenameRequired());
    });

    on<ConnectChatStream>((event, emit) async {
      try {
        service = StompClient(
          config: StompConfig.sockJS(
            url: 'http://localhost:8080/ws',
            onConnect: (StompFrame frame) {
              service?.subscribe(
                destination: '/chats/newChats/${event.code}',
                callback: (frame) {
                  if (frame.body != null) {
                    final decodedtxt = jsonDecode(frame.body ?? '');
                    print(decodedtxt);
                    add(MessageReceived(decodedtxt, event.code));
                  }
                },
              );
            },
          ),
        );
        service!.activate();
      } catch (e) {
        print(e);
        Get.snackbar('Error', 'Some error occured , please try again : ${e}');
      }
    });

    on<MessageReceived>((event, emit) {
      if (state is! ConnectionEstablished) return;

      final current = state as ConnectionEstablished;

      final updatedMessages = List<Map<String, dynamic>>.from(current.message)
        ..add(event.message);

      emit(ConnectionEstablished(updatedMessages, current.code, current.name));
    });

    on<SendChatMessage>((event, emit) async {
      try {
        final json = {
          "sentBy": event.sentBy,
          //"type":event.messageType,
          // "urls": '',
          "message": event.message,
          "chatCode": event.chatCode,
        };

        final jsonEnc = jsonEncode(json);

        service?.send(
          destination: '/app/sendMessage/${event.chatCode}',
          body: jsonEnc,
        );
        print('mss');
      } catch (e) {
        Get.snackbar(
          "Error",
          "Some error has occured \n ${e}",
          backgroundColor: Colors.red,
        );
      }
    });

    on<JoinRoom>((event, emit) async {
      final pref = await SharedPreferences.getInstance();
      final name = pref.getString("Name") ?? '';
      add(ConnectChatStream(event.code));
      //add(LoadEarlierMessages(event.code));
      emit(ConnectionEstablished(messages, event.code, name));
    });

    // on<LoadEarlierMessages>((event, emit) async{
    //   Get.dialog(Loading());
    //   emit(ConnectionEstablished(messages,event.code));
    //   Get.back();
    // },);

    on<GoToMailPage>((event, emit) async {
      Get.dialog(Loading());
      final pref = await SharedPreferences.getInstance();
      final name = pref.getString("Name") ?? '';
      emit(MailChosen(name));
      Get.back();
    });

    on<GoToHomePage>((event, emit) async {
      final pref = await SharedPreferences.getInstance();
      final name = pref.getString("Name");
      emit(HomePageInitial(name ?? ''));
    });

    on<CreateRoom>((event, emit) async {
      final response = await Dio().get('http://localhost:8080/createRoom');
      final pref = await SharedPreferences.getInstance();
      final name = pref.getString("Name") ?? '';
      print(response);
      Get.snackbar(
        'Success',
        'Room created successfully',
        backgroundColor: Colors.green,
      );
      emit(ConnectionEstablished(messages, response.data['data'], name));
      add(ConnectChatStream(response.data['data']));
    });
  }
}
