import 'package:ceyiz_app/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/ceyiz_item_model.dart';
import '../viewmodels/ceyiz_view_model.dart';
import '../widgets/filter_sort_dialogs.dart';
import '../widgets/item_card.dart';
import '../widgets/item_dialogs.dart';
import '../widgets/summary_card.dart';

class CeyizScreen extends StatefulWidget {
  const CeyizScreen({super.key});

  @override
  State<CeyizScreen> createState() => _CeyizScreenState();
}

class _CeyizScreenState extends State<CeyizScreen> {
  @override
  void initState() {
    super.initState();
    // ViewModel'i başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CeyizViewModel>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Çeyiz Listesi',
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
            child: Consumer<CeyizViewModel>(
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
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz çeyiz öğesi eklenmemiş',
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
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<CeyizViewModel>(
      builder: (context, viewModel, child) {
        return SummaryCard(
          totalItems: viewModel.totalItems,
          purchasedItems: viewModel.purchasedItems,
          totalPrice: viewModel.totalPrice,
          purchaseProgress: viewModel.purchaseProgress,
          gradientColors: AppColors.primaryGradient,
          shadowColor: AppColors.primaryColor,
          itemIcon: Icons.inventory_2_outlined,
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    ItemDialogs.showAddCeyizDialog(context);
  }

  void _showEditDialog(BuildContext context, CeyizItemModel item) {
    ItemDialogs.showEditCeyizDialog(context, item);
  }

  void _showAddPhotoDialog(BuildContext context, CeyizItemModel item) {
    final viewModel = Provider.of<CeyizViewModel>(context, listen: false);
    ItemDialogs.showAddPhotoCeyizDialog(context, item, viewModel);
  }

  void _showDeleteConfirmation(BuildContext context, CeyizItemModel item) {
    final viewModel = Provider.of<CeyizViewModel>(context, listen: false);
    ItemDialogs.showDeleteCeyizConfirmation(context, item, viewModel);
  }

  void _showSortDialog(BuildContext context) {
    final viewModel = Provider.of<CeyizViewModel>(context, listen: false);

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
      onSortByCategory: () {
        // Kategoriye göre sıralama
        viewModel.sortByCategory();
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final viewModel = Provider.of<CeyizViewModel>(context, listen: false);

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
