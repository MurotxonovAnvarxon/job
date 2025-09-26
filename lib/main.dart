import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'repositories/auth_repository.dart';
import 'repositories/job_repository.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/job/job_bloc.dart';
import 'screens/splash_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
//.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(AuthRepository())
            ..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => JobBloc(JobRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Job Post App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF9FC348),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9FC348)),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}