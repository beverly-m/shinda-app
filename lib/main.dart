import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/responsive/desktop_scaffold.dart';
import 'package:shinda_app/responsive/mobile_scaffold.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/responsive/tablet_scaffold.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/utilities/navigation_provider.dart';
import 'package:shinda_app/views/dashboard/dashboard_view.dart';
import 'package:shinda_app/views/dashboard/debtors_view.dart';
import 'package:shinda_app/views/dashboard/home_view.dart';
import 'package:shinda_app/views/auth/login_view.dart';
import 'package:shinda_app/views/auth/register_view.dart';
import 'package:shinda_app/views/auth/verify_email_view.dart';
import 'package:shinda_app/views/dashboard/inventory_view.dart';
import 'package:shinda_app/views/dashboard/products_view.dart';
import 'package:shinda_app/views/dashboard/reports_view.dart';
import 'package:shinda_app/views/dashboard/sales_view.dart';
import 'package:shinda_app/views/dashboard/settings_view.dart';
import 'package:shinda_app/views/dashboard/users_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => NavigationProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const InitApp(),
        routes: {
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          homeRoute: (context) => const HomeView(),
          verifyEmailRoute: (context) => const VerifyEmailView(),
          dashboardRoute: (context) => const DashboardView(),
          salesRoute: (context) => const SalesView(),
          inventoryRoute: (context) => const InventoryView(),
          productsRoute: (context) => const ProductsView(),
          debtorsRoute: (context) => const DebtorsView(),
          reportsRoute: (context) => const ReportsView(),
          usersRoute: (context) => const UsersView(),
          settingsRoute: (context) => const SettingsView(),
        },
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class InitApp extends StatelessWidget {
  const InitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.supabase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final session = AuthService.supabase().currentSession;

            if (session == null) {
              return const LoginView();
            } else {
              return const HomeView();
            }

          default:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}
