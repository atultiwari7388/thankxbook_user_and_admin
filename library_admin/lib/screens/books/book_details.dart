import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_admin/screens/customers/user_details_screen.dart';

class BookDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bookData;
  final String userId;

  const BookDetailsScreen(
      {super.key, required this.bookData, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookData['bookName'] ?? "Book Details"),
        actions: [
          TextButton(
              onPressed: () {
                Get.to(() => UserDetailsScreen(userId: userId));
              },
              child: const Text("View User Details"))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Book Name: ${bookData['bookName']}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Description: ${bookData['description']}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("MRP: ₹${bookData['mrp']}",
                  style: const TextStyle(fontSize: 16, color: Colors.red)),
              const SizedBox(height: 10),
              Text("Selling Price: ₹${bookData['sellingPrice']}",
                  style: const TextStyle(fontSize: 16, color: Colors.green)),
              const SizedBox(height: 20),
              // Display Front Image
              if (bookData['frontImageUrl'] != null)
                Image.network(
                  bookData['frontImageUrl'],
                  height: 200,
                  fit: BoxFit.cover,
                  // headers: const {"Access-Control-Allow-Origin": "*"},
                  // errorBuilder: (context, error, stackTrace) =>
                  //     const Icon(Icons.error),
                ),

              const SizedBox(height: 20),

              // Display Other Images
              if (bookData['otherImageUrls'] != null &&
                  bookData['otherImageUrls'] is List)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (bookData['otherImageUrls'] as List).length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.network(
                          bookData['otherImageUrls'][index],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          // headers: const {"Access-Control-Allow-Origin": "*"},
                          // errorBuilder: (context, error, stackTrace) =>
                          //     const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
