// import 'package:cloudinary_flutter/cloudinary_context.dart';
// import 'package:cloudinary_flutter/cloudinary_object.dart';
// import 'package:cloudinary_url_gen/cloudinary.dart';
// import 'package:cloudinary_url_gen/config/cloudinary_config.dart';
import 'package:batchshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:batchshare/HomePage/Views/HomePage.dart';
import 'package:batchshare/Config/redirect_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle URL Shortener redirect before launching MaterialApp/GetMaterialApp
  final redirected = await checkAndRedirect();
  if (redirected) return;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => HomePageBloc())],
      child: GetMaterialApp(
        title: 'batchshare',
        debugShowCheckedModeBanner: false,
        home: const Homepage(),
        theme: ThemeData(fontFamily: 'Bebas',
        ),
      ),
    );
  }
}
