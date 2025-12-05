import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final annonkey = dotenv.env['SUPABASE_ANON_KEY'];

  await Supabase.initialize(url: supabaseUrl!, anonKey: annonkey!);
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build (BuildContext context){
    return MaterialApp(

    );
  }
}