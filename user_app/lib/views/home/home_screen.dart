import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_app/views/home/widgets/list_of_books.dart';
import '../../common/app_style.dart';
import '../../constants/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 3.w, right: 8.w),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.0.w, vertical: 10.h),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.h),
                        border: Border.all(color: kGrayLight),
                        boxShadow: const [
                          BoxShadow(
                            color: kLightWhite,
                            spreadRadius: 0.2,
                            blurRadius: 1,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search books",
                            prefixIcon: const Icon(Icons.search),
                            prefixStyle: appStyle(14, kDark, FontWeight.w200)),
                      ),
                    ),
                  ),
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     // Implement filter functionality
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: kPrimary,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8.0.r),
                //     ),
                //     padding: EdgeInsets.symmetric(vertical: 5.w),
                //   ),
                //   child: const Icon(Icons.filter_alt, color: kWhite),
                // ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(bottom: 90.h),
                child: ListOfBooksWidget(searchText: searchText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
