import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'DataModel.dart';

class DatabaseHelper {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  // Delete a grocery item from the database.
  Future<void> deleteGroceryItem(String key) async {
    await databaseReference.child("groceryItems").child(key).remove();
  }


  Future<void> readFirebaseRealtimeDBMain(Function(List<GroceryItem>) productListCallback) async{
    databaseReference.child("groceryItems").onValue.listen((groceryDataJson) {
      if (!groceryDataJson.snapshot.exists) {
        productListCallback([]);
        return;
      }
      final groceryList = groceryDataJson.snapshot.children.map((element) {
        final value = Map<String, dynamic>.from(element.value as Map<Object?, Object?>);
        return GroceryItem(element.key, GroceryItemData.fromJson(value));
      }).toList();
      productListCallback(groceryList);
    }, onError: (error) {
      productListCallback([]);
    });
  }


  Future<void> addNewGroceryItem(GroceryItemData groceryItemData) async {
  final User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    groceryItemData.addedBy = user.email ?? "Unknown User"; // Get the user's email
  } else {
    groceryItemData.addedBy = "Anonymous"; // Fallback if user is not logged in
  }

  // Get the current date and format it as a string (e.g., "2024-10-05")
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  groceryItemData.timestamp = formattedDate; // Store only the date

  Map<String, dynamic> data = groceryItemData.toJson();
  await databaseReference.child('groceryItems').push().set(data);
}




}
