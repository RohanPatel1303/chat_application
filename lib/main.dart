import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Features/Auth/Screens/auth.dart';
import 'Features/Chat/Screens/chat.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final annonkey = dotenv.env['SUPABASE_ANON_KEY'];

  await Supabase.initialize(url: supabaseUrl!, anonKey: annonkey!);
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
class SupabaseAuthNotifier extends ChangeNotifier{
  SupabaseAuthNotifier(){
    supabase.auth.onAuthStateChange.listen((_){
      notifyListeners();
    });
  }
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});
  @override
  State<MyApp> createState()=>_MyAppState();

}
class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/chat',
      refreshListenable: SupabaseAuthNotifier(),
      routes: [
        GoRoute(path: '/auth',
          pageBuilder: (context, state) =>
          const MaterialPage(child: AuthPage()),
        ),
        GoRoute(path: '/chat',
          pageBuilder: (context, state) => MaterialPage(child: ChatPage()),)
      ],
      redirect: (context, state) {
        final loggedIn = supabase.auth.currentSession != null;
        final goingToAuth = state.matchedLocation == '/auth';
        if (!loggedIn) return goingToAuth ? null : '/auth';
        if (goingToAuth) return '/chat';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Supabase Based Chat Application',
    );

  }
}