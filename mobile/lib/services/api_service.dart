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

  /// Get all items with optional status, category, and search filter, merging Firestore + Mock data
  Future<List<Item>> getItems({String? status, String? category, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    List<Item> firestoreItems = [];
    try {
      Query query = _firestore.collection(_collectionPath);

      if (status != null && status.isNotEmpty && status != 'All') {
        query = query.where('status', isEqualTo: status);
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      firestoreItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Item.fromJson(data, docId: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('[ApiService] getItems Firestore notice: $e');
    }

    // Filter mock items according to status and category filters
    List<Item> mockFiltered = List.from(_mockItems);
    if (status != null && status.isNotEmpty && status != 'All') {
      mockFiltered = mockFiltered.where((i) => i.status == status).toList();
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      mockFiltered = mockFiltered.where((i) => i.category == category).toList();
    }

    // Combine Firestore real items + Mock items (avoiding duplicate IDs)
    final Set<String> firestoreIds = firestoreItems.map((i) => i.id).toSet();
    final List<Item> combined = [
      ...firestoreItems,
      ...mockFiltered.where((m) => !firestoreIds.contains(m.id)),
    ];

    // Sort by createdAt descending so newest reports appear first
    combined.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse(b.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    // Substring search filter across both Firebase and Mock items
    List<Item> finalItems = combined;
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      finalItems = combined.where((item) {
        return item.name.toLowerCase().contains(s) ||
            item.description.toLowerCase().contains(s) ||
            item.location.toLowerCase().contains(s) ||
            item.category.toLowerCase().contains(s);
      }).toList();
    }

    _items = finalItems;
    _isLoading = false;
    notifyListeners();

    return _items;
  }

  static final List<Item> _mockItems = [
    Item(
      id: 'mock_1',
      name: 'HP Envy 15 Laptop Bag',
      description: 'Dark gray water-resistant laptop bag left on the table with a blue notebook inside.',
      category: 'Electronics',
      status: 'Lost',
      location: 'Central Library, 2nd Floor',
      date: '2026-10-06',
      contact: '+91 9823411209',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&auto=format&fit=crop',
      userId: 'mock_user_1',
      createdAt: '2026-10-06T14:30:00Z',
      updatedAt: '2026-10-06T14:30:00Z',
    ),
    Item(
      id: 'mock_2',
      name: 'Fossil Silver Watch',
      description: 'Found a metallic silver chronograph watch under seat #12 near the food court.',
      category: 'Accessories',
      status: 'Found',
      location: 'Campus Canteen, Main Court',
      date: '2026-10-07',
      contact: '+91 9711204982',
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&auto=format&fit=crop',
      userId: 'mock_user_2',
      createdAt: '2026-10-07T09:15:00Z',
      updatedAt: '2026-10-07T09:15:00Z',
    ),
    Item(
      id: 'mock_3',
      name: 'Leather Wallet & Student ID',
      description: 'Lost brown leather wallet containing college ID card, driving license, and library card.',
      category: 'Wallet',
      status: 'Lost',
      location: 'Engineering Block B, Room 302',
      date: '2026-10-05',
      contact: 'alex.student@campus.edu',
      imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=600&auto=format&fit=crop',
      userId: 'mock_user_3',
      createdAt: '2026-10-05T18:00:00Z',
      updatedAt: '2026-10-05T18:00:00Z',
    ),
    Item(
      id: 'mock_4',
      name: 'AirPods Pro Charging Case',
      description: 'Found an Apple AirPods Pro case with a clear protective silicone cover.',
      category: 'Electronics',
      status: 'Found',
      location: 'Sports Complex Basketball Court',
      date: '2026-10-07',
      contact: '+91 9884512093',
      imageUrl: 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=600&auto=format&fit=crop',
      userId: 'mock_user_4',
      createdAt: '2026-10-07T11:45:00Z',
      updatedAt: '2026-10-07T11:45:00Z',
    ),
    Item(
      id: 'mock_5',
      name: 'Bunch of 3 House Keys',
      description: 'Found a key ring with 3 brass keys and a red Tech Club keychain.',
      category: 'Keys',
      status: 'Found',
      location: 'Computer Science Lab 1',
      date: '2026-10-06',
      contact: '+91 9920145871',
      imageUrl: 'https://images.unsplash.com/photo-1582139329536-e7284fece509?w=600&auto=format&fit=crop',
      userId: 'mock_user_5',
      createdAt: '2026-10-06T16:20:00Z',
      updatedAt: '2026-10-06T16:20:00Z',
    ),
    Item(
      id: 'mock_6',
      name: 'Blue Denim Jacket (Size M)',
      description: 'Left a denim jacket on the back row seat during the guest lecture.',
      category: 'Other',
      status: 'Lost',
      location: 'Main Auditorium, Ground Floor',
      date: '2026-10-04',
      contact: 'sarah.m@campus.edu',
      imageUrl: 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=600&auto=format&fit=crop',
      userId: 'mock_user_6',
      createdAt: '2026-10-04T12:00:00Z',
      updatedAt: '2026-10-04T12:00:00Z',
    ),
    Item(
      id: 'mock_7',
      name: 'Sony WH-1000XM4 Headphones',
      description: 'Lost black wireless noise-canceling headphones in a black zip pouch.',
      category: 'Electronics',
      status: 'Lost',
      location: 'Central Library, Quiet Reading Area',
      date: '2026-10-07',
      contact: '+91 9876501234',
      imageUrl: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop',
      userId: 'mock_user_7',
      createdAt: '2026-10-07T15:10:00Z',
      updatedAt: '2026-10-07T15:10:00Z',
    ),
    Item(
      id: 'mock_8',
      name: 'Casio Scientific Calculator',
      description: 'Lost FX-991EX ClassWiz scientific calculator during linear algebra lecture.',
      category: 'Electronics',
      status: 'Lost',
      location: 'Math Block, Lecture Hall 104',
      date: '2026-10-06',
      contact: 'student.math@campus.edu',
      imageUrl: 'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?w=600&auto=format&fit=crop',
      userId: 'mock_user_8',
      createdAt: '2026-10-06T11:00:00Z',
      updatedAt: '2026-10-06T11:00:00Z',
    ),
  ];

  /// Get single item by ID (checking Firestore first, then Mock list)
  Future<Item?> getItem(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Item.fromJson(doc.data()!, docId: doc.id);
      }
    } catch (e) {
      debugPrint('[ApiService] getItem Firestore error: $e');
    }
    try {
      return _mockItems.firstWhere((item) => item.id == id);
    } catch (_) {
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
