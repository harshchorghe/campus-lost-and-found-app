import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../widgets/item_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/web_responsive_wrapper.dart';
import 'add_item_screen.dart';
import 'item_details_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    await apiService.getItems(
      status: _selectedStatus == 'All' ? null : _selectedStatus,
    );
  }

  List<Item> _filterItems(List<Item> items) {
    if (_searchQuery.isEmpty) return items;
    final query = _searchQuery.toLowerCase();
    return items.where((item) {
      final name = item.name.toLowerCase();
      final category = item.category.toLowerCase();
      final location = item.location.toLowerCase();
      final description = item.description.toLowerCase();
      return name.contains(query) ||
          category.contains(query) ||
          location.contains(query) ||
          description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final filteredItems = _filterItems(apiService.items);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Campus Lost & Found',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: WebResponsiveWrapper(
        maxWidth: 900,
        child: Column(
          children: [
            // Search & Filter Header Container
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Search Input
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search lost or found items...',
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips (All, Lost, Found)
                  Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Lost'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Found'),
                    ],
                  ),
                ],
              ),
            ),

            // Items Content List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadItems,
                child: apiService.isLoading
                    ? const LoadingWidget(message: 'Fetching campus items...')
                    : apiService.errorMessage != null && apiService.items.isEmpty
                        ? EmptyStateWidget(
                            title: 'Connection Issue',
                            message: apiService.errorMessage!,
                            icon: Icons.wifi_off_rounded,
                            onRefresh: _loadItems,
                          )
                        : filteredItems.isEmpty
                            ? EmptyStateWidget(
                                title: _searchQuery.isNotEmpty
                                    ? 'No Matching Items'
                                    : 'No Reports Yet',
                                message: _searchQuery.isNotEmpty
                                    ? 'Try searching with a different item name or location.'
                                    : 'Be the first to report a lost or found item on campus!',
                                icon: Icons.search_off_rounded,
                                onRefresh: _loadItems,
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final int crossAxisCount = constraints.maxWidth > 400 ? 2 : 1;
                                  final double aspectRatio = constraints.maxWidth > 600 ? 1.05 : 0.92;

                                  return GridView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(12),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: aspectRatio,
                                    ),
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      return ItemCard(
                                        item: item,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ItemDetailsScreen(itemId: item.id),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
          if (result == true) {
            _loadItems();
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Report Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedStatus == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatus = label;
          });
          _loadItems();
        }
      },
      selectedColor: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      showCheckmark: false,
    );
  }
}
