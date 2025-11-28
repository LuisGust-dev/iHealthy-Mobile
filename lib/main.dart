

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ihealthy/features/auth/presentation/pages/dashboard_page.dart';
import 'features/auth/logic/auth_bloc.dart';
import 'features/auth/logic/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';


void main() {
  runApp(const IHealthyApp());
}

class IHealthyApp extends StatelessWidget {
  const IHealthyApp({super.key});

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween =
            Tween(begin: const Offset(0.1, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut));
        final fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AuthBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'iHealthy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
                return const MainPage();
            } else if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const LoginForm();
            }
          },
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return _createRoute(const LoginForm());
            case '/register':
              return _createRoute(const RegisterPage());
            case '/dashboard':
              return _createRoute(const DashboardPage());
            default:
              return _createRoute(const LoginForm());
          }
        },
      ),
    );
  }
}