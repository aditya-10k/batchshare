import 'dart:async';
import 'dart:convert';

import 'package:batchshare/Config/redirect_helper.dart';
import 'package:batchshare/Elements/Loading.dart';
import 'package:batchshare/HomePage/Bloc/HomePageEvent.dart';
import 'package:batchshare/HomePage/Bloc/HomePageState.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  // Base URL Configurations
  static String get baseUrl => getBaseUrl();

  static Map<String, dynamic> parseResponseMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        print("Failed to parse response data as JSON. Raw data preview (first 200 chars): \${data.length > 200 ? data.substring(0, 200) : data}");
      }
    }
    throw Exception("Expected JSON Map response, got: \${data.runtimeType}");
  }

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
      print("The name is $name");

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
        if (service != null) {
          service!.deactivate();
        }
        service = StompClient(
          config: StompConfig.sockJS(
            url: '$baseUrl/ws',
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

    on<DisconnectChatStream>((event, emit) async {
      if (service != null) {
        service!.deactivate();
        service = null;
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
          "type": event.messageType.toUpperCase(),
          "urls": event.url.isNotEmpty ? [event.url] : [],
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

    on<UploadFile>((event, emit) async {
      try {
        final result = await FilePicker.platform.pickFiles();
        if (result == null || result.files.isEmpty) return;

        Get.dialog(const Loading());

        final fileInfo = result.files.first;
        MultipartFile file;

        if (fileInfo.bytes != null) {
          file = MultipartFile.fromBytes(
            fileInfo.bytes!,
            filename: fileInfo.name,
          );
        } else if (fileInfo.path != null) {
          file = await MultipartFile.fromFile(
            fileInfo.path!,
            filename: fileInfo.name,
          );
        } else {
          throw Exception("Unable to read file contents");
        }

        final formData = FormData.fromMap({"file": file});

        final response = await Dio().post(
          '$baseUrl/api/cloudinary/upload',
          data: formData,
        );

        final responseData = parseResponseMap(response.data);
        final String fileUrl = responseData['data'];

        add(
          SendChatMessage(
            'FILE',
            fileUrl,
            message: fileInfo.name,
            chatCode: event.chatCode,
            sentBy: event.sentBy,
          ),
        );
      } catch (e) {
        print(e);
        Get.snackbar(
          'Error',
          'File upload failed: $e',
          backgroundColor: Colors.red,
        );
      } finally {
        Get.back();
      }
    });

    on<JoinRoom>((event, emit) async {
      add(ConnectChatStream(event.code));
      add(LoadEarlierMessages(event.code));
    });

    on<LoadEarlierMessages>((event, emit) async {
      Get.dialog(Loading());
      try {
        final response = await Dio().get(
          '$baseUrl/all-messages/${event.code}',
        );
        final responseData = parseResponseMap(response.data);
        final List<dynamic> fetchedMessages = responseData['messages'] ?? [];

        final List<Map<String, dynamic>> typedMessages = fetchedMessages
            .map((m) => Map<String, dynamic>.from(m as Map))
            .toList();

        final pref = await SharedPreferences.getInstance();
        final name = pref.getString("Name") ?? '';

        emit(ConnectionEstablished(typedMessages, event.code, name));
      } catch (e) {
        print(e);
        Get.snackbar('Error', 'Could not load earlier messages: $e');
      } finally {
        Get.back();
      }
    });

    on<GoToMailPage>((event, emit) async {
      Get.dialog(Loading());
      final pref = await SharedPreferences.getInstance();
      final name = pref.getString("Name") ?? '';
      emit(MailChosen(name));
      Get.back();
    });

    on<GoToHomePage>((event, emit) async {
      add(DisconnectChatStream());
      final pref = await SharedPreferences.getInstance();
      final name = pref.getString("Name");
      emit(HomePageInitial(name ?? ''));
    });

    on<CreateRoom>((event, emit) async {
      Get.dialog(const Loading());
      try {
        final response = await Dio().get('$baseUrl/createRoom');
        final responseData = parseResponseMap(response.data);
        final pref = await SharedPreferences.getInstance();
        final name = pref.getString("Name") ?? '';
        print(response);
        Get.snackbar(
          'Success',
          'Room created successfully',
          backgroundColor: Colors.green,
        );
        emit(ConnectionEstablished(messages, responseData['data'], name));
        add(ConnectChatStream(responseData['data']));
      } catch (e) {
        print(e);
        Get.snackbar('Error', 'Failed to create room: $e');
      } finally {
        Get.back();
      }
    });

    on<SendMail>((event, emit) async {
      Get.dialog(const Loading());
      try {
        final pref = await SharedPreferences.getInstance();
        final String senderName = pref.getString("Name") ?? 'User';

        final payload = {
          "name": senderName,
          "mails": event.recipientEmails,
          "messages": event.messages,
          "urls": event.urls,
          "fileNames": event.fileNames,
        };

        await Dio().post('$baseUrl/mailer/send', data: payload);

        Get.back(); // Dismiss loading dialog
        Get.snackbar(
          'Success',
          'Email sent successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.back(); // Dismiss loading dialog
        print(e);
        Get.snackbar(
          'Error',
          'Failed to send email: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }
}
