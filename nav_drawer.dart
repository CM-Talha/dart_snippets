// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app/app_provider.dart';
import '../core/routes/app_routes.dart';
import '../core/assets/app_images.dart';
import '../core/assets/app_icons.dart';
import '../features/school_list_page/screen/school_list_screen.dart';
import 'alerts/alert_dialog.dart';
import 'alerts/custom_snack_bar.dart';

Widget navDrawer(BuildContext context) {
  var provider = Provider.of<AppProvider>(context);
  return Drawer(
    width: MediaQuery.of(context).size.width * 0.7,
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: UserAccountsDrawerHeader(
            currentAccountPicture: Image.asset(
              AppImages.appLogo,
              scale: 2,
              filterQuality: FilterQuality.high,
              fit: BoxFit.fill,
            ),
            currentAccountPictureSize: const Size(150, 100),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            accountName: Text(
              "User No 1",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  //color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              'John Doe',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(
          height: 0,
        ),
        DrawerItem(
          title: 'Refresh',
          onTap: () async {
            Navigator.of(context).pop();
            var alert = AlertDialogNew(
              context,
              title: "Refreshing Data....",
              showButtons: false,
              showCrossButton: false,
              content: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => alert);
            await provider.refreshData().whenComplete(() async {
              showSnackBar(context,
                  type: SnackBarType.success,
                  message: "Data refreshed from server successfully");
              await Future.delayed(const Duration(seconds: 1));
              // ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.dashboardScreen, (route) => false);
            });
          },
          icon: Image.asset(
            AppIcons.refreshIcon,
            height: 27,
            width: 27,
            scale: 1,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Divider(),
        DrawerItem(
          title: 'Home',
          icon: Image.asset(
            AppIcons.homeIcon,
            height: 27,
            width: 27,
            scale: 1.1,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () async {
            // await Navigator.of(context).push(
            //     MaterialPageRoute(builder: (context) => SchoolListScreen()));
          },
        ),
        DrawerItem(
          title: 'Mark Activity',
          icon: Image.asset(
            AppIcons.activity2Icon,
            height: 27,
            width: 27,
            scale: 0.5,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () async {},
        ),
        DrawerItem(
          title: 'Save',
          icon: Image.asset(
            AppIcons.saveIcon,
            height: 27,
            width: 27,
            scale: 0.5,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () async {},
        ),
        DrawerItem(
          title: 'Offline Activity',
          icon: Image.asset(
            AppIcons.offlineIcon,
            height: 27,
            width: 27,
            scale: 0.5,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () async {
            await Navigator.of(context)
                .pushNamed(AppRoutes.viewOfflineActivitiesScreen);
          },
        ),
        DrawerItem(
          onTap: () async {
            var alert = AlertDialogNew(
              context,
              title: "Logout ?",
              contentText: "Are you sure you want to logout ?",
              confirmButtonCallback: () {
                Navigator.of(context).pop(true);
              },
              cancelButtonCallback: () {
                Navigator.of(context).pop(false);
              },
              showCrossButton: false,
            );
            bool? result = await showDialog(
              context: context,
              builder: (context) {
                return alert;
              },
            );
            if (result ?? false) {
              await Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.loginScreen, (route) => false);
            }
          },
          title: 'Logout',
          icon: Image.asset(
            AppIcons.logoutIcon,
            height: 27,
            width: 27,
            scale: 0.5,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    ),
  );
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
  }) : super(key: key);
  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      subtitle: subtitle == null ? null : Text(subtitle!),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 5,
          ),
          icon,
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: GoogleFonts.asar(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
