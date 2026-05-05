import 'package:equatable/equatable.dart';

abstract class HomePageState extends Equatable{

  @override
  List<Object?> get props => [];
}

class HomePageInitial extends HomePageState{
  final String name ; 
  HomePageInitial(this.name);
}

// class ConnectionEstablished extends HomePageState{
//   final List<dynamic> message ;

//   ConnectionEstablished(this.message);
//   @override
//     List<Object?> get props => [message];

// }

class ConnectionEstablished extends HomePageState{
    final List<Map<String , dynamic>> message ;
    final String? code ;
    final String name;

  ConnectionEstablished(this.message , this.code, this.name);
  @override
  List<Object?> get props => [message,code, name];
}

class MailChosen extends HomePageState{
  final String name;
  MailChosen(this.name);
}

class NameRequired extends HomePageState{
  // final String name ; 

  // NameRequired(this.name);

  // @override 
  // List<Object?> get props =>[name];
}

class RenameRequired extends HomePageState{}