import 'package:ceyiz_app/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/bohca_item_model.dart';
import '../viewmodels/bohca_view_model.dart';
import '../widgets/filter_sort_dialogs.dart';
import '../widgets/item_card.dart';
import '../widgets/item_dialogs.dart';
import '../widgets/summary_card.dart';

class BohcaScreen extends StatefulWidget {
  const BohcaScreen({super.key});

  @override
  State<BohcaScreen> createState() => _BohcaScreenState();
}

class _BohcaScreenState extends State<BohcaScreen> {
  @override
  void initState() {
    super.initState();
    // ViewModel'i başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BohcaViewModel>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Bohça Listesi',
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(context),
            tooltip: 'Sırala',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filtrele',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: Consumer<BohcaViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_giftcard_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz bohça öğesi eklenmemiş',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yeni bir öğe eklemek için + butonuna tıklayın',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.items.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.items[index];
                    return ItemCard(
                      item: item,
                      onTogglePurchased: () => viewModel.togglePurchaseStatus(item.id),
                      onEdit: () => _showEditDialog(context, item),
                      onDelete: () => _showDeleteConfirmation(context, item),
                      onAddPhoto: () => _showAddPhotoDialog(context, item),
                      onDeletePhoto: (photoUrl) => viewModel.removePhotoFromItem(item.id, photoUrl),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.bohcaCategoryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<BohcaViewModel>(
      builder: (context, viewModel, child) {
        return SummaryCard(
          totalItems: viewModel.totalItems,
          purchasedItems: viewModel.purchasedItems,
          totalPrice: viewModel.totalPrice,
          purchaseProgress: viewModel.purchaseProgress,
          gradientColors: AppColors.secondaryGradient,
          shadowColor: AppColors.secondaryColor,
          itemIcon: Icons.card_giftcard_outlined,
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    ItemDialogs.showAddBohcaDialog(context);
  }

  void _showEditDialog(BuildContext context, BohcaItemModel item) {
    ItemDialogs.showEditBohcaDialog(context, item);
  }

  void _showAddPhotoDialog(BuildContext context, BohcaItemModel item) {
    final viewModel = Provider.of<BohcaViewModel>(context, listen: false);
    ItemDialogs.showAddPhotoBohcaDialog(context, item, viewModel);
  }

  void _showDeleteConfirmation(BuildContext context, BohcaItemModel item) {
    final viewModel = Provider.of<BohcaViewModel>(context, listen: false);
    ItemDialogs.showDeleteBohcaConfirmation(context, item, viewModel);
  }

  void _showSortDialog(BuildContext context) {
    final viewModel = Provider.of<BohcaViewModel>(context, listen: false);

    FilterSortDialogs.showSortDialog(
      context,
      onSortByName: () {
        // İsme göre sıralama
        viewModel.sortByName();
      },
      onSortByPriceAsc: () {
        // Fiyata göre sıralama (artan)
        viewModel.sortByPriceAscending();
      },
      onSortByPriceDesc: () {
        // Fiyata göre sıralama (azalan)
        viewModel.sortByPriceDescending();
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final viewModel = Provider.of<BohcaViewModel>(context, listen: false);

    FilterSortDialogs.showFilterDialog(
      context,
      onFilterAll: () {
        // Tüm öğeleri göster
        viewModel.filterAll();
      },
      onFilterPurchased: () {
        // Sadece alınanları göster
        viewModel.filterPurchased();
      },
      onFilterNotPurchased: () {
        // Sadece alınmayanları göster
        viewModel.filterNotPurchased();
      },
    );
  }
}
