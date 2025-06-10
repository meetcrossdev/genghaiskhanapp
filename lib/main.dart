import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gzresturent/core/constant/themenotfier.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
import 'package:gzresturent/firebase_options.dart';
import 'package:gzresturent/models/user_models.dart';
import 'package:gzresturent/nav_screen.dart';
import 'package:gzresturent/services/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gzresturent/features/boarding_screen.dart';
import 'package:gzresturent/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();
  Stripe.publishableKey =
      'pk_live_51RBzTUHxu36eGrkMgWKdSCFFsAYYvFpgYB0MbTQnrMkRbYGFIzrOSsOpnJwhQ9cfI9kGMYM9I7nUv2V5cKCaVMby00GUv5SWmP';
  await Stripe.instance.applySettings();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;
  bool? isFirstLaunch;

  @override
  void initState() {
    super.initState();
    NotificationService.initialize(context);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Handle tap when app is in background but not terminated
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Handle initial notification tap
      }
    });

    checkFirstLaunch();
  }

  Future<void> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    completeOnboarding();
    setState(() {});
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
  }

  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .read(authControllerProvider.notifier)
        .getSpecificUserData(data.uid);
    ref.watch(userProvider.notifier).update((state) => userModel);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authStateProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        Size designSize;

        if (constraints.maxWidth >= 1000) {
          // iPad Pro 12.9", large Android tablets
          designSize = const Size(1024, 1366);
        } else if (constraints.maxWidth >= 800) {
          // iPad Pro 11", standard Android tablets
          designSize = const Size(834, 1194);
        } else {
          // Phones
          designSize = const Size(360, 690);
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
                textTheme: GoogleFonts.poppinsTextTheme(),
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: const ColorScheme.dark(),
              ),
              themeMode: themeMode,
              onGenerateRoute: (settings) => generateRoute(settings),
              home: authState.when(
                data: (user) {
                  if (isFirstLaunch == null) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (user != null) {
                    getData(ref, user);
                  }

                  return isFirstLaunch! ? OnboardingScreen() : NavScreen();
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
      },
    );
  }
}
