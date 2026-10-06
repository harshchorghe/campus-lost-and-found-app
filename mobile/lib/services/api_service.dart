import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/item.dart';

class ApiService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionPath = 'items';

  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Health check verifying Firestore connection
  Future<bool> checkHealth() async {
    try {
      await _firestore.collection(_collectionPath).limit(1).get();
      return true;
    } catch (e) {
      debugPrint('[ApiService] Firestore Health check failed: $e');
      return false;
    }
  }

  /// Get all items with optional status, category, and search filter
  Future<List<Item>> getItems({String? status, String? category, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query query = _firestore.collection(_collectionPath);

      if (status != null && status.isNotEmpty && status != 'All') {
        query = query.where('status', isEqualTo: status);
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      List<Item> fetchedItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Item.fromJson(data, docId: doc.id);
      }).toList();

      // Sort by createdAt descending
      fetchedItems.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(b.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      // Substring search filter
      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        fetchedItems = fetchedItems.where((item) {
          return item.name.toLowerCase().contains(s) ||
              item.description.toLowerCase().contains(s) ||
              item.location.toLowerCase().contains(s) ||
              item.category.toLowerCase().contains(s);
        }).toList();
      }

      _items = fetchedItems;
    } catch (e) {
      debugPrint('[ApiService] getItems Firestore error: $e');
      _errorMessage = 'Failed to fetch items from Firestore: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _items;
  }

  /// Get single item by ID
  Future<Item?> getItem(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Item.fromJson(doc.data()!, docId: doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('[ApiService] getItem Firestore error: $e');
      return null;
    }
  }

  /// Create a new lost/found item directly in Firestore
  Future<Item?> createItem({
    required Item item,
    required String? idToken,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final itemData = item.toJson();
      itemData['createdAt'] = item.createdAt.isNotEmpty ? item.createdAt : now;
      itemData['updatedAt'] = now;

      final docRef = await _firestore.collection(_collectionPath).add(itemData);
      final newItem = item.copyWith(id: docRef.id, createdAt: itemData['createdAt'], updatedAt: now);

      _items.insert(0, newItem);
      notifyListeners();
      return newItem;
    } catch (e) {
      debugPrint('[ApiService] createItem Firestore error: $e');
      rethrow;
    }
  }

  /// Update an existing item in Firestore
  Future<Item?> updateItem({
    required String id,
    required Item item,
    required String? idToken,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final itemData = item.toJson();
      itemData['updatedAt'] = now;

      await _firestore.collection(_collectionPath).doc(id).update(itemData);

      final updatedItem = item.copyWith(id: id, updatedAt: now);
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        _items[index] = updatedItem;
      }
      notifyListeners();
      return updatedItem;
    } catch (e) {
      debugPrint('[ApiService] updateItem Firestore error: $e');
      rethrow;
    }
  }

  /// Delete an item document from Firestore
  Future<bool> deleteItem({
    required String id,
    required String? idToken,
  }) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ApiService] deleteItem Firestore error: $e');
      rethrow;
    }
  }
}
