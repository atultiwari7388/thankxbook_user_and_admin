import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_admin/common/app_style.dart';
import 'package:library_admin/utils/constants.dart';
import '../../services/firebase_services.dart';

class TotalCustomerScreens extends StatefulWidget {
  static const String id = "total-customer";

  const TotalCustomerScreens({super.key});

  @override
  State<TotalCustomerScreens> createState() => _TotalCustomerScreensState();
}

class _TotalCustomerScreensState extends State<TotalCustomerScreens> {
  final TextEditingController searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _customersStream;
  int _perPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _customersStream = _getCustomerStream();
  }

  Stream<List<DocumentSnapshot>> _getCustomerStream() {
    Query query = FirebaseDatabaseServices().allUsersList;

    // Apply orderBy and where clauses based on search text
    if (searchController.text.isNotEmpty) {
      query = query
          .orderBy("phoneNumber")
          .where("phoneNumber",
              isGreaterThanOrEqualTo: "+91${searchController.text}")
          .where("phoneNumber",
              isLessThanOrEqualTo: "+91${searchController.text}\uf8ff");
    } else {
      query = query.orderBy("created_at", descending: true);
    }

    return query.limit(_perPage).snapshots().map((snapshot) => snapshot.docs);
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _perPage += 10;
      _customersStream = _getCustomerStream(); // Update the stream
      log(_currentPage.toString());
      log(_perPage.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total User's",
                  style: appStyle(16, kRed, FontWeight.normal)),
            ],
          ),
          const SizedBox(height: 30),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search by number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0), // Make it circular
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(30.0), // Keep the same value
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    _customersStream =
                        _getCustomerStream(); // Update the stream
                  });
                },
              ),
            ),
            onChanged: (value) {
              setState(() {
                _customersStream = _getCustomerStream(); // Update the stream
              });
            },
          ),
          const SizedBox(height: 30),
          reusableRowHeadingWidget("#", "Name", "Email", "Phone", "What'sApp"),
          //===================== PaginatedGridView Section ====================

          StreamBuilder<List<DocumentSnapshot>>(
            stream: _customersStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final drivers = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display List of Drivers
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: drivers.length,
                      itemBuilder: (context, index) {
                        final data =
                            drivers[index].data() as Map<String, dynamic>;
                        final serialNumber = index + 1;
                        final name = data["userName"] ?? "";
                        final email = data["email"] ?? "";
                        final phoneNumber = data["phoneNumber"] ?? "";
                        final whatsApp = data["whatsAppNumber"];

                        return reusableRowWidget(
                          serialNumber.toString(),
                          name ?? "",
                          email.toString(),
                          phoneNumber,
                          whatsApp.toString(),
                        );
                      },
                    ),
                    // Pagination Button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(
                        child: TextButton(
                          onPressed: _loadNextPage,
                          child: const Text("Next"),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget reusableRowHeadingWidget(srNum, name, email, phone, tags) {
    return Container(
      padding:
          const EdgeInsets.only(top: 18.0, left: 10, right: 10, bottom: 10),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(srNum, style: appStyle(20, kWhite, FontWeight.normal)),
          ),
          Expanded(
            flex: 1,
            child: Text(name, style: appStyle(20, kWhite, FontWeight.normal)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              email,
              style: appStyle(20, kWhite, FontWeight.normal),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              phone,
              style: appStyle(20, kWhite, FontWeight.normal),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              tags,
              textAlign: TextAlign.center,
              style: appStyle(20, kWhite, FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Widget reusableRowWidget(
    text1,
    name,
    email,
    phoneNumber,
    role,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  text1,
                  style: appStyle(16, kDark, FontWeight.normal),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  name,
                  style: appStyle(16, kDark, FontWeight.normal),
                ),
              ),
              Expanded(
                flex: 1,
                child:
                    Text(email, style: appStyle(16, kDark, FontWeight.normal)),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  phoneNumber,
                  style: appStyle(16, kDark, FontWeight.normal),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  role,
                  textAlign: TextAlign.center,

                  style: appStyle(16, kRed, FontWeight.normal),
                  // style: AppFontStyles.font16Style.copyWith(
                  //     color: AppColors.kRedColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
        ],
      ),
    );
  }
}
