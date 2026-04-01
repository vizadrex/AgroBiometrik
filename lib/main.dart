import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/service_locator.dart' as di;
import 'core/theme.dart';
import 'presentation/screens/home_screen.dart';
import 'core/error/global_error_handler.dart';
import 'core/error/global_bloc_observer.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      Bloc.observer = GlobalBlocObserver();
      FlutterError.onError = GlobalErrorHandler.onFlutterError;

      runApp(const AgroBiometrikApp());
    },
    (error, stack) {
      GlobalErrorHandler.onError(error, stack);
    },
  );
}

class AgroBiometrikApp extends StatefulWidget {
  const AgroBiometrikApp({super.key});

  @override
  State<AgroBiometrikApp> createState() => _AgroBiometrikAppState();
}

class _AgroBiometrikAppState extends State<AgroBiometrikApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = di.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroBiometrik',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Initialization Error:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ),
              );
            }
            return const HomeScreen();
          }
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing AgroBiometrik...'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
