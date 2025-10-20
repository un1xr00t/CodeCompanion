import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/ios26_theme.dart';
import 'providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'CodeCompanion',
      debugShowCheckedModeBanner: false,
      theme: Ios26Theme.lightTheme,
      darkTheme: Ios26Theme.darkTheme,
      themeMode: ThemeMode.system,
      home: authState.isLoading
          ? const SplashScreen()
          : authState.isAuthenticated
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}