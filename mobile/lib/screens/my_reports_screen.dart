import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/item_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/web_responsive_wrapper.dart';
import 'item_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final apiService = Provider.of<ApiService>(context);

    final String currentUid = authService.uid;
    final List<Item> myItems = apiService.items.where((item) {
      if (currentUid.isEmpty) return true;
      return item.userId == currentUid || item.userId.isEmpty;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('My Reported Items'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: WebResponsiveWrapper(
        maxWidth: 850,
        child: apiService.isLoading
            ? const LoadingWidget(message: 'Loading your reports...')
            : myItems.isEmpty
                ? EmptyStateWidget(
                    title: 'No Reports Found',
                    message: 'You have not reported any lost or found items yet.',
                    icon: Icons.post_add_rounded,
                    onRefresh: () async {
                      await apiService.getItems();
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: myItems.length,
                    itemBuilder: (context, index) {
                      final item = myItems[index];
                      return ItemCard(
                        item: item,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ItemDetailsScreen(itemId: item.id),
                            ),
                          );
                          setState(() {});
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
