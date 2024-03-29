import 'package:flutter/material.dart';
import 'package:shinda_app/constants/routes.dart';
import 'package:shinda_app/enums/menu_action.dart';
import 'package:shinda_app/responsive/desktop_scaffold.dart';
import 'package:shinda_app/responsive/mobile_scaffold.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/responsive/tablet_scaffold.dart';
import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_service.dart';
import 'package:shinda_app/utilities/show_error_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final user = AuthService.supabase().currentUser;

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileScaffold: MobileScaffold(),
      tabletScaffold: TabletScaffold(),
      desktopScaffold: DesktopScaffold(),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Home"), actions: [
  //       PopupMenuButton<MenuAction>(
  //         onSelected: (value) async {
  //           switch (value) {
  //             case MenuAction.logout:
  //               final isLogout = await showLogOutDialog(context);
  //               if (isLogout) {
  //                 try {
  //                   await AuthService.supabase().logOut();
  //                   if (context.mounted) {
  //                     Navigator.of(context).pushNamedAndRemoveUntil(
  //                       loginRoute,
  //                       (_) => false,
  //                     );
  //                   }
  //                 } on UserNotLoggedInAuthException {
  //                   if (context.mounted) {
  //                     Navigator.of(context).pushNamedAndRemoveUntil(
  //                       loginRoute,
  //                       (_) => false,
  //                     );
  //                   }
  //                 } on GenericAuthException {
  //                   if (context.mounted) {
  //                     await showErrorDialog(
  //                       context,
  //                       "An error occurred. Try again.",
  //                     );
  //                   }
  //                 } catch (_) {
  //                   if (context.mounted) {
  //                     await showErrorDialog(
  //                       context,
  //                       "An error occurred. Try again.",
  //                     );
  //                   }
  //                 }
  //               }
  //               break;
  //             default:
  //           }
  //         },
  //         itemBuilder: (context) {
  //           return [
  //             const PopupMenuItem<MenuAction>(
  //               value: MenuAction.logout,
  //               child: Text("Logout"),
  //             )
  //           ];
  //         },
  //       )
  //     ]),
  //     body: const Center(
  //       child: Text('Done'),
  //     ),
  //   );
  // }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: const Color.fromRGBO(241, 249, 249, 1),
          title: const Text("Log out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                    fontSize: 16, color: Color.fromRGBO(0, 121, 107, 1)),
              ),
            ),
            FilledButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color.fromRGBO(0, 121, 107, 1),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Log out",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      }).then((value) => value ?? false);
}
