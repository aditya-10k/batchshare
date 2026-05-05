import 'package:equatable/equatable.dart';

abstract class HomePageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectChatStream extends HomePageEvent {
  final String code;

  ConnectChatStream(this.code);
  @override
  List<Object?> get props => [code];
}

class EnterName extends HomePageEvent {}

class DisconnectChatStream extends HomePageEvent {}

class SendChatMessage extends HomePageEvent {
  final String chatCode;
  final String sentBy;
  final String message;
  final String messageType;
  final String url;

  SendChatMessage(
    this.messageType,
    this.url, {
    required this.message,
    required this.chatCode,
    required this.sentBy,
  });
  @override
  List<Object?> get props => [chatCode, sentBy, message, messageType, url];
}

class MessageReceived extends HomePageEvent {
  final dynamic message;
  final String code;

  MessageReceived(this.message, this.code);
  @override
  List<Object?> get props => [message, code];
}

class LoadEarlierMessages extends HomePageEvent {
  final String code;

  LoadEarlierMessages(this.code);
  @override
  List<Object?> get props => [code];
}

class GoToMailPage extends HomePageEvent {}

class GoToHomePage extends HomePageEvent {}

class CreateRoom extends HomePageEvent {}

class JoinRoom extends HomePageEvent {
  final String code;

  JoinRoom(this.code);
  @override
  List<Object?> get props => [code];
}

class AppStartUp extends HomePageEvent{}

class SaveName extends HomePageEvent{
  final String name ;

  SaveName(this.name);

  @override
  List<Object?> get props => [name];
}

class Rename extends HomePageEvent{
  // final String name ;

  // Rename(this.name);

  // @override
  // List<Object?> get props => [name];
}
