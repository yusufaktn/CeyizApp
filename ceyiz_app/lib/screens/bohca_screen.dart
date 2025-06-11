import 'dart:io';

import 'package:ceyiz_app/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> _showAddPhotoDialog(BuildContext context, BohcaItemModel item) async {
    print('BohcaScreen: Fotoğraf ekleme dialogu açılıyor...');
    print('BohcaScreen: Item ID: ${item.id}');

    final viewModel = Provider.of<BohcaViewModel>(context, listen: false);

    // Fotoğraf kaynağı seçimi için bottom sheet göster
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Fotoğraf Kaynağı Seçin',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera ile Çek'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    // Seçilen kaynaktan fotoğraf al
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null && context.mounted) {
      print('BohcaScreen: Fotoğraf seçildi/çekildi: ${image.path}');

      // Geçici fotoğraflar listesine ekle
      await viewModel.addTempPhoto(File(image.path));

      // Item'ı güncelle
      final updatedItem = item.copyWith(
        photoUrls: [...item.photoUrls, ...viewModel.tempPhotos],
      );

      // Item'ı güncelle ve geçici fotoğrafları temizle
      await viewModel.updateItem(updatedItem);
      viewModel.clearTempPhotos();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf başarıyla eklendi')),
        );
      }
    }
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
