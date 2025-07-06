import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'DataModel.dart';
import 'LocalStorageHelper.dart';
import 'ConnectivityService.dart';

class DatabaseHelper {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final LocalStorageHelper _localStorage = LocalStorageHelper();
  final ConnectivityService _connectivity = ConnectivityService();

  // Delete a grocery item from the database.
  Future<void> deleteGroceryItem(String key) async {
    if (await _connectivity.isConnected()) {
      await databaseReference.child("groceryItems").child(key).remove();
    }
    await _localStorage.deleteGroceryItem(key);
  }

  Future<void> readFirebaseRealtimeDBMain(Function(List<GroceryItem>) productListCallback) async {
    if (await _connectivity.isConnected()) {
      databaseReference.child("groceryItems").onValue.listen((groceryDataJson) {
        if (!groceryDataJson.snapshot.exists) {
          productListCallback([]);
          return;
        }
        final groceryList = groceryDataJson.snapshot.children.map((element) {
          final value = Map<String, dynamic>.from(element.value as Map<Object?, Object?>);
          return GroceryItem(element.key, GroceryItemData.fromJson(value));
        }).toList();
        
        // Save to local storage
        _saveToLocalStorage(groceryList);
        productListCallback(groceryList);
      }, onError: (error) {
        // If online fails, load from local storage
        _loadFromLocalStorage(productListCallback);
      });
    } else {
      // Load from local storage when offline
      _loadFromLocalStorage(productListCallback);
    }
  }

  Future<void> _saveToLocalStorage(List<GroceryItem> items) async {
    await _localStorage.clearAllData();
    for (var item in items) {
      await _localStorage.insertGroceryItem(item);
    }
  }

  Future<void> _loadFromLocalStorage(Function(List<GroceryItem>) callback) async {
    final items = await _localStorage.getAllGroceryItems();
    callback(items);
  }

  Future<void> addNewGroceryItem(GroceryItemData groceryItemData) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      groceryItemData.addedBy = user.email ?? "Unknown User";
    } else {
      groceryItemData.addedBy = "Anonymous";
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    groceryItemData.timestamp = formattedDate;

    Map<String, dynamic> data = groceryItemData.toJson();
    
    if (await _connectivity.isConnected()) {
      // Add to Firebase
      final ref = databaseReference.child('groceryItems').push();
      await ref.set(data);
      groceryItemData.isSynced = true;
      
      // Save to local storage with Firebase key
      final item = GroceryItem(ref.key, groceryItemData);
      await _localStorage.insertGroceryItem(item);
    } else {
      // Save to local storage only, mark as unsynced
      groceryItemData.isSynced = false;
      final localKey = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final item = GroceryItem(localKey, groceryItemData);
      await _localStorage.insertGroceryItem(item);
    }
  }

  // Update a grocery item in the database
  Future<void> updateGroceryItem(String key, GroceryItemData groceryItemData) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      groceryItemData.addedBy = user.email ?? "Unknown User";
    } else {
      groceryItemData.addedBy = "Anonymous";
    }

    // Update timestamp
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    groceryItemData.timestamp = formattedDate;

    Map<String, dynamic> data = groceryItemData.toJson();
    
    if (await _connectivity.isConnected()) {
      await databaseReference.child('groceryItems').child(key).update(data);
      groceryItemData.isSynced = true;
    } else {
      groceryItemData.isSynced = false;
    }
    
    await _localStorage.updateGroceryItem(key, groceryItemData);
  }

  // Sync unsynced items when connection is restored
  Future<void> syncUnsyncedItems() async {
    if (!(await _connectivity.isConnected())) return;

    final unsyncedItems = await _localStorage.getUnsyncedItems();
    
    for (var item in unsyncedItems) {
      try {
        if (item.key!.startsWith('local_')) {
          // This is a new item, add to Firebase
          final ref = databaseReference.child('groceryItems').push();
          await ref.set(item.itemData!.toJson());
          
          // Update local storage with Firebase key
          await _localStorage.deleteGroceryItem(item.key!);
          item.key = ref.key;
          item.itemData!.isSynced = true;
          await _localStorage.insertGroceryItem(item);
        } else {
          // This is an updated item, update in Firebase
          await databaseReference.child('groceryItems').child(item.key!).update(item.itemData!.toJson());
          await _localStorage.markAsSynced(item.key!);
        }
      } catch (e) {
        // Handle sync errors - could add proper logging here
        // Optionally show error to user or retry later
      }
    }
  }

  // Get categories for the dropdown
  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _localStorage.getCategories();
  }

  // Add a new category
  Future<void> addCategory(String name, String color, String icon) async {
    await _localStorage.addCategory(name, color, icon);
  }

  // Toggle item completion status
  Future<void> toggleItemCompletion(String key, bool isCompleted) async {
    final item = await _localStorage.getGroceryItemByKey(key);
    if (item == null) return;

    item.itemData!.isCompleted = isCompleted;
    item.itemData!.isSynced = false; // Mark as unsynced for later sync

    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    item.itemData!.timestamp = formattedDate;

    if (await _connectivity.isConnected()) {
      await databaseReference.child('groceryItems').child(key).update({
        'isCompleted': isCompleted,
        'timestamp': formattedDate,
      });
      item.itemData!.isSynced = true;
    }
    
    await _localStorage.updateGroceryItem(key, item.itemData!);
  }
}
