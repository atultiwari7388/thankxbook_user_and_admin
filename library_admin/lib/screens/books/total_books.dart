import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_admin/common/app_style.dart';
import 'package:library_admin/screens/books/book_details.dart';
import 'package:library_admin/screens/customers/user_details_screen.dart';
import 'package:library_admin/utils/constants.dart';
import '../../services/firebase_services.dart';
import '../../utils/toast_msg.dart';

class TotalBooksScreen extends StatefulWidget {
  static const String id = "total-books";

  const TotalBooksScreen({super.key});

  @override
  State<TotalBooksScreen> createState() => _TotalBooksScreenState();
}

class _TotalBooksScreenState extends State<TotalBooksScreen> {
  final TextEditingController searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _bookStream;
  int _perPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _bookStream = _getBookStream();
  }

  // Stream<List<DocumentSnapshot>> _getBookStream() {
  //   Query query = FirebaseDatabaseServices().allBookingList;

  //   // Apply orderBy and where clauses based on search text
  //   if (searchController.text.isNotEmpty) {
  //     query = query
  //         .orderBy("createdAt")
  //         .where("bookName",
  //             isGreaterThanOrEqualTo: searchController.text.toString())
  //         .where("bookName",
  //             isLessThanOrEqualTo: searchController.text.toString());
  //   } else {
  //     query = query.orderBy("createdAt", descending: true);
  //   }

  //   return query.limit(_perPage).snapshots().map((snapshot) => snapshot.docs);
  // }

  Stream<List<DocumentSnapshot>> _getBookStream() {
    Query query = FirebaseDatabaseServices().allBookingList;

    // Fetch all books first
    return query
        .orderBy("createdAt", descending: true)
        .limit(_perPage)
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs;

      // Local filtering for case-insensitive search
      final filteredBooks = books.where((book) {
        final bookName = book['bookName'].toString().toLowerCase();
        final searchText = searchController.text.trim().toLowerCase();

        return searchText.isEmpty || bookName.contains(searchText);
      }).toList();

      return filteredBooks;
    });
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _perPage += 10;
      _bookStream = _getBookStream(); // Update the stream
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
              Text("Total Book's",
                  style: appStyle(16, kRed, FontWeight.normal)),
            ],
          ),
          const SizedBox(height: 30),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search by book Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0), // Make it circular
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    _bookStream = _getBookStream();
                  });
                },
              ),
            ),
            onChanged: (value) {
              setState(() {
                _bookStream = _getBookStream();
              });
            },
          ),
          const SizedBox(height: 30),
          reusableRowHeadingWidget(
              "#", "Name", "description", "price", "P'Name", "Publish"),
          //===================== PaginatedGridView Section ====================

          StreamBuilder<List<DocumentSnapshot>>(
            stream: _bookStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final books = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final data =
                            books[index].data() as Map<String, dynamic>;
                        final serialNumber = index + 1;
                        final name = data["bookName"] ?? "";
                        final description = data["description"] ?? "";
                        final price = data["mrp"];
                        final bool publish = data["approved"];
                        final userId = data['userId'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("Users")
                              .doc(userId)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: SizedBox());
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return reusableRowWidget(
                                serialNumber.toString(),
                                name,
                                description.toString(),
                                price.toString(),
                                "Unknown User", // If user not found
                                publish,
                                books[index].reference,
                                data,
                                userId,
                              );
                            }

                            final userName = snapshot.data!.get("userName") ??
                                "Unknown User";
                            final userPhNumber =
                                snapshot.data!.get("phoneNumber") ?? "0000";

                            String formattedString =
                                "$userName ($userPhNumber)";

                            return reusableRowWidget(
                              serialNumber.toString(),
                              name,
                              description.toString(),
                              price.toString(),
                              formattedString,
                              publish,
                              books[index].reference,
                              data,
                              userId,
                            );
                          },
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

  Widget reusableRowHeadingWidget(
      srNum, name, description, price, pName, publish) {
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
              description,
              style: appStyle(20, kWhite, FontWeight.normal),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              price,
              style: appStyle(20, kWhite, FontWeight.normal),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              pName,
              style: appStyle(20, kWhite, FontWeight.normal),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              publish,
              textAlign: TextAlign.center,
              style: appStyle(20, kWhite, FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Widget reusableRowWidget(text1, name, description, price, pName, bool publish,
      DocumentReference docRef, dynamic data, String userId) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(
              bookData: data,
              userId: userId, // Passing book data
            ),
          ),
        );
      },
      child: Padding(
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
                  child: Text(description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: appStyle(16, kDark, FontWeight.normal)),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    price.toString(),
                    style: appStyle(16, kDark, FontWeight.normal),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(pName,
                      // overflow: TextOverflow.ellipsis,
                      style: appStyle(12, kDark, FontWeight.normal)),
                ),
                Expanded(
                  flex: 1,
                  child: Builder(builder: (context) {
                    return Switch(
                      key: UniqueKey(),
                      value: publish,
                      onChanged: (bool value) {
                        setState(() {
                          publish = value;
                        });
                        // Update Firestore with the new value
                        docRef.update({'approved': value}).then((value) {
                          showToastMessage(
                              "Success", "Value updated", Colors.green);
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
