// void deleteBook(String docId) async {
//   try {
//     // Delete the document from Firestore
//     await .doc(docId).delete();
//     // Optionally, you can show a confirmation message
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Book deleted successfully'))
//     );
//   } catch (e) {
//     // Handle any errors that occur during deletion
//     print('Error deleting book: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete book'))
//     );
//   }
// }
