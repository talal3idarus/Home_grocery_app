import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../shared/models/data_model.dart';
import '../../../core/constants/app_constants.dart';

class HistoryProvider with ChangeNotifier {
  List<ShoppingSession> _shoppingHistory = [];
  Map<String, int> _itemFrequency = {};
  Map<String, DateTime> _lastPurchased = {};

  List<ShoppingSession> get shoppingHistory => _shoppingHistory;
  Map<String, int> get itemFrequency => _itemFrequency;

  static const String _historyKey = AppConstants.shoppingHistoryKey;
  static const String _frequencyKey = AppConstants.itemFrequencyKey;
  static const String _lastPurchasedKey = AppConstants.lastPurchasedKey;

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load shopping history
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      final List<dynamic> historyList = json.decode(historyJson);
      _shoppingHistory = historyList.map((item) => ShoppingSession.fromJson(item)).toList();
    }

    // Load item frequency
    final frequencyJson = prefs.getString(_frequencyKey);
    if (frequencyJson != null) {
      final Map<String, dynamic> frequencyMap = json.decode(frequencyJson);
      _itemFrequency = frequencyMap.map((key, value) => MapEntry(key, value as int));
    }

    // Load last purchased dates
    final lastPurchasedJson = prefs.getString(_lastPurchasedKey);
    if (lastPurchasedJson != null) {
      final Map<String, dynamic> lastPurchasedMap = json.decode(lastPurchasedJson);
      _lastPurchased = lastPurchasedMap.map((key, value) => MapEntry(key, DateTime.parse(value)));
    }

    notifyListeners();
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save shopping history
    final historyJson = json.encode(_shoppingHistory.map((session) => session.toJson()).toList());
    await prefs.setString(_historyKey, historyJson);

    // Save item frequency
    final frequencyJson = json.encode(_itemFrequency);
    await prefs.setString(_frequencyKey, frequencyJson);

    // Save last purchased dates
    final lastPurchasedJson = json.encode(_lastPurchased.map((key, value) => MapEntry(key, value.toIso8601String())));
    await prefs.setString(_lastPurchasedKey, lastPurchasedJson);
  }

  void addShoppingSession(List<GroceryItem> completedItems) {
    if (completedItems.isEmpty) return;

    final session = ShoppingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: completedItems,
      timestamp: DateTime.now(),
      totalItems: completedItems.length,
      totalSpent: completedItems.length * AppConstants.defaultItemPrice, // Estimated price per item as placeholder
    );

    _shoppingHistory.insert(0, session);
    
    // Update frequency and last purchased
    for (final item in completedItems) {
      final itemName = item.itemData?.name ?? 'Unknown Item';
      _itemFrequency[itemName] = (_itemFrequency[itemName] ?? 0) + 1;
      _lastPurchased[itemName] = DateTime.now();
    }

    // Keep only last 50 sessions
    if (_shoppingHistory.length > AppConstants.maxHistorySessions) {
      _shoppingHistory = _shoppingHistory.take(AppConstants.maxHistorySessions).toList();
    }

    saveHistory();
    notifyListeners();
  }

  Map<String, dynamic> getShoppingAnalytics() {
    if (_shoppingHistory.isEmpty) {
      return {
        'totalSessions': 0,
        'averageItemsPerSession': 0.0,
        'averageSpentPerSession': 0.0,
        'mostFrequentItems': <String>[],
        'totalSpent': 0.0,
        'shoppingSessions': 0,
      };
    }

    final totalSessions = _shoppingHistory.length;
    final totalItems = _shoppingHistory.fold(0, (sum, session) => sum + session.totalItems);
    final totalSpent = _shoppingHistory.fold(0.0, (sum, session) => sum + session.totalSpent);
    
    final mostFrequent = _itemFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalSessions': totalSessions,
      'averageItemsPerSession': totalItems / totalSessions,
      'averageSpentPerSession': totalSpent / totalSessions,
      'mostFrequentItems': mostFrequent.take(5).map((e) => e.key).toList(),
      'totalSpent': totalSpent,
      'shoppingSessions': totalSessions,
    };
  }

  void clearHistory() {
    _shoppingHistory.clear();
    _itemFrequency.clear();
    _lastPurchased.clear();
    saveHistory();
    notifyListeners();
  }
}

class ShoppingSession {
  final String id;
  final List<GroceryItem> items;
  final DateTime timestamp;
  final int totalItems;
  final double totalSpent;

  ShoppingSession({
    required this.id,
    required this.items,
    required this.timestamp,
    required this.totalItems,
    required this.totalSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'totalItems': totalItems,
      'totalSpent': totalSpent,
    };
  }

  factory ShoppingSession.fromJson(Map<String, dynamic> json) {
    return ShoppingSession(
      id: json['id'],
      items: (json['items'] as List).map((item) => GroceryItem.fromJson(item)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
      totalItems: json['totalItems'],
      totalSpent: json['totalSpent'].toDouble(),
    );
  }
}
