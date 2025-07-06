class ItemData {
  final String name;
  final int quantity;
  final String urgency;

  ItemData({required this.name, required this.quantity, required this.urgency});
}

class GroceryItem {
  String? key;
  GroceryItemData? itemData;

  GroceryItem(this.key, this.itemData);

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      json['key'] ?? '', // Default to empty string if 'key' is null
      json.containsKey('itemData') ? GroceryItemData.fromJson(json['itemData']) : null,
    );
  }

  // Method for converting an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key, // key can be null or empty since we use push() for auto-generating
      'itemData': itemData?.toJson(),
    };
  }
}


class GroceryItemData {
  String? name;
  int? quantity;
  String? urgency;
  String? addedBy;
  String? timestamp;
  String? category;
  List<String>? tags;
  bool? isCompleted;
  bool? isSynced; // For offline support 

  
  

  GroceryItemData({
    this.name, 
    this.quantity, 
    this.urgency, 
    this.addedBy, 
    this.timestamp,
    this.category,
    this.tags,
    this.isCompleted = false,
    this.isSynced = true,
  });

  factory GroceryItemData.fromJson(Map<String, dynamic> json) {
    return GroceryItemData(
      name: json['name'],
      quantity: json['quantity'],
      urgency: json['urgency'],
      addedBy: json['addedBy'],
      timestamp: json['timestamp'],
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isCompleted: json['isCompleted'] ?? false,
      isSynced: json['isSynced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'urgency': urgency,
      'addedBy': addedBy,
      'timestamp': timestamp,
      'category': category,
      'tags': tags,
      'isCompleted': isCompleted,
      'isSynced': isSynced,
    };
  }
}
