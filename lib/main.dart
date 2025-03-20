import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/themenotfier.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/firebase_options.dart';
import 'package:gzresturent/models/user_models.dart';
import 'package:gzresturent/nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gzresturent/features/boarding_screen.dart';
import 'package:gzresturent/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;
  bool isFirstLaunch = true;
  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .read(authControllerProvider.notifier)
        .getSpecificUserData(data.uid);
    ref.read(userProvider.notifier).update((state) => userModel);
    log(userModel.toString());
    isFirstLaunch = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authStateProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
            textTheme: GoogleFonts.poppinsTextTheme(),
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text color in light mode
              ),
            ),
          ),
          darkTheme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme().apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            cardColor: Colors.grey[900],
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white, // Text color in dark mode
              ),
            ),
          ),
          themeMode: themeMode, // Apply the theme mode from Riverpod
          onGenerateRoute: (settings) => generateRoute(settings),
          home: authState.when(
            data: (user) {
              if (user != null) {
                if (isFirstLaunch) {
                  getData(ref, user);
                }

                return NavScreen(); // If user is authenticated, go to HomeScreen
              } else {
                return OnboardingScreen(); // Otherwise, show onboarding screen
              }
            },
            loading:
                () => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
            error:
                (err, stack) =>
                    Scaffold(body: Center(child: Text('Error: $err'))),
          ),
        );
      },
    );
  }
}
