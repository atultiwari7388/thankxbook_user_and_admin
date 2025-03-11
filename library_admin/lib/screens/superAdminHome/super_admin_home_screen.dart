import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:library_admin/common/app_style.dart';
import 'package:library_admin/screens/books/total_books.dart';
import 'package:library_admin/services/firebase_services.dart';
import 'package:library_admin/utils/constants.dart';
import '../../common/custom_text.dart';
import '../analytics_screen/analytics_screen.dart';
import '../customers/total_customer.dart';

class SuperAdminHomeScreen extends StatefulWidget {
  static const String id = "admin-menu";

  const SuperAdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<SuperAdminHomeScreen> createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  Widget _selectedScreen = const SuperAdminAnalyticsScreen();

  screenSelector(item) {
    switch (item.route) {
      case SuperAdminAnalyticsScreen.id:
        setState(() {
          _selectedScreen = const SuperAdminAnalyticsScreen();
        });
        break;

      case TotalCustomerScreens.id:
        setState(() {
          _selectedScreen = const TotalCustomerScreens();
        });
        break;

      case TotalBooksScreen.id:
        setState(() {
          _selectedScreen = const TotalBooksScreen();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: const Color(0xFFEEEEEE),
        backgroundColor: kPrimary,
        elevation: 0,
        title: Row(
          children: [
            const Visibility(
              child: CustomTextWidget(
                text: "thankxbook",
                size: 20,
                color: kWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: Container()),
            Container(
              width: 1,
              height: 22,
              color: kWhite,
            ),
            const SizedBox(width: 24),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to Logout."),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("No",
                            style: appStyle(12, kRed, FontWeight.normal)),
                      ),
                      TextButton(
                        onPressed: () =>
                            FirebaseDatabaseServices().signOut(context),
                        child: Text("Yes",
                            style:
                                appStyle(12, Colors.green, FontWeight.normal)),
                      ),
                    ],
                  ),
                );
              },
              child: const Row(
                children: [
                  CustomTextWidget(
                    text: "LogOut",
                    color: kWhite,
                  ),
                  SizedBox(width: 10),
                  FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: kWhite),
                ],
              ),
            )
          ],
        ),
        iconTheme: const IconThemeData(color: kWhite),
      ),
      sideBar: SideBar(
        textStyle: appStyle(18, kWhite, FontWeight.normal),
        iconColor: kWhite,
        backgroundColor: kPrimary,
        activeBackgroundColor: kWhite,
        activeIconColor: kPrimary,
        items: const [
          AdminMenuItem(
            title: 'Dashboard',
            route: SuperAdminAnalyticsScreen.id,
            icon: FontAwesomeIcons.arrowTrendUp,
          ),
          AdminMenuItem(
            title: "User's",
            route: TotalCustomerScreens.id,
            icon: FontAwesomeIcons.users,
          ),
          AdminMenuItem(
            title: "Books's",
            route: TotalBooksScreen.id,
            icon: FontAwesomeIcons.book,
          ),
        ],
        selectedRoute: SuperAdminHomeScreen.id,
        onSelected: (item) {
          screenSelector(item);
        },
        footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: Center(
            child: Text(
              DateTimeFormat.format(DateTime.now(),
                  format: AmericanDateFormats.dayOfWeek),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(child: _selectedScreen),
    );
  }
}
