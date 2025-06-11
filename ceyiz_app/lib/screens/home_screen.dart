import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/bohca_item_model.dart';
import '../models/ceyiz_item_model.dart';
import '../viewmodels/bohca_view_model.dart';
import '../viewmodels/ceyiz_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/theme_view_model.dart';
import '../widgets/category_card.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // ViewModel'leri başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).init();
      Provider.of<CeyizViewModel>(context, listen: false).init();
      Provider.of<BohcaViewModel>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      appBar: GradientAppBar(
        title: AppConstants.appName,
        actions: [
          IconButton(
            icon: Icon(
              themeViewModel.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeViewModel.toggleTheme(),
            tooltip: themeViewModel.isDarkMode ? 'Aydınlık Tema' : 'Karanlık Tema',
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.pushNamed(context, AppConstants.categoryRoute),
            tooltip: 'Kategoriler',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Menü işlemleri
              switch (value) {
                case 'settings':
                  // Ayarlar sayfası
                  break;
                case 'about':
                  // Hakkında sayfası
                  _showAboutDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Ayarlar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Hakkında'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),

                // Kategori Kartları
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Kategoriler',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Çeyiz Kategorisi
                        Expanded(
                          child: CategoryCard(
                            title: 'Çeyiz',
                            icon: Icons.inventory_2_outlined,
                            backgroundColor: AppColors.ceyizCategoryColor,
                            onTap: () => Navigator.pushNamed(context, AppConstants.ceyizRoute),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Bohça Kategorisi
                        Expanded(
                          child: CategoryCard(
                            title: 'Bohça',
                            icon: Icons.card_giftcard_outlined,
                            backgroundColor: AppColors.bohcaCategoryColor,
                            onTap: () => Navigator.pushNamed(context, AppConstants.bohcaRoute),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Son Eklenenler
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Son Eklenenler',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showViewAllDialog(context),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Tümünü Gör'),
                      ),
                    ],
                  ),
                ),

                // Son eklenen öğeler
                Consumer2<CeyizViewModel, BohcaViewModel>(
                  builder: (context, ceyizViewModel, bohcaViewModel, child) {
                    if (ceyizViewModel.isLoading || bohcaViewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Tüm öğeleri birleştir
                    final allItems = <dynamic>[];

                    // Çeyiz öğelerini ekle
                    for (final item in ceyizViewModel.items) {
                      allItems.add({
                        'type': 'ceyiz',
                        'item': item,
                        'date': item.createdAt,
                      });
                    }

                    // Bohça öğelerini ekle
                    for (final item in bohcaViewModel.items) {
                      allItems.add({
                        'type': 'bohca',
                        'item': item,
                        'date': item.createdAt,
                      });
                    }

                    // Tarihe göre sırala (en yeni önce)
                    allItems.sort((a, b) => b['date'].compareTo(a['date']));

                    if (allItems.isEmpty) {
                      return _buildEmptyState(
                        'Henüz hiç öğe eklenmemiş',
                        'Yeni bir öğe eklemek için + butonuna tıklayın',
                        Icons.add_shopping_cart,
                      );
                    }

                    // Son 5 öğeyi göster
                    final recentItems = allItems.length > 5 ? allItems.sublist(0, 5) : allItems;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recentItems.length,
                      itemBuilder: (context, index) {
                        final itemData = recentItems[index];
                        if (itemData['type'] == 'ceyiz') {
                          return _buildRecentCeyizItemCard(context, itemData['item']);
                        } else {
                          return _buildRecentBohcaItemCard(context, itemData['item']);
                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptionsDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Öğe Ekle'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCeyizItemCard(BuildContext context, CeyizItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor.withOpacity(0.7),
                AppColors.primaryColor.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2_outlined, color: Colors.white),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: item.isPurchased ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${item.category} • ${item.price.toStringAsFixed(2)} ₺',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: item.isPurchased
            ? const Icon(Icons.check_circle, color: AppColors.successColor)
            : const Icon(Icons.check_circle_outline, color: Colors.grey),
        onTap: () => Navigator.pushNamed(context, AppConstants.ceyizRoute),
      ),
    );
  }

  Widget _buildRecentBohcaItemCard(BuildContext context, BohcaItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bohcaCategoryColor.withOpacity(0.7),
                AppColors.bohcaCategoryColor.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.card_giftcard_outlined, color: Colors.white),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: item.isPurchased ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${item.category} • ${item.price.toStringAsFixed(2)} ₺',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: item.isPurchased
            ? const Icon(Icons.check_circle, color: AppColors.successColor)
            : const Icon(Icons.check_circle_outline, color: Colors.grey),
        onTap: () => Navigator.pushNamed(context, AppConstants.bohcaRoute),
      ),
    );
  }

  void _showViewAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Tümünü Görüntüle'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.ceyizRoute);
            },
            child: const ListTile(
              leading: Icon(Icons.inventory_2_outlined, color: AppColors.ceyizCategoryColor),
              title: Text('Çeyiz Listesi'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.bohcaRoute);
            },
            child: const ListTile(
              leading: Icon(Icons.card_giftcard_outlined, color: AppColors.bohcaCategoryColor),
              title: Text('Bohça Listesi'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Yeni Öğe Ekle'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.ceyizRoute);
            },
            child: const ListTile(
              leading: Icon(Icons.inventory_2_outlined, color: AppColors.ceyizCategoryColor),
              title: Text('Çeyiz Öğesi Ekle'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.bohcaRoute);
            },
            child: const ListTile(
              leading: Icon(Icons.card_giftcard_outlined, color: AppColors.bohcaCategoryColor),
              title: Text('Bohça Öğesi Ekle'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çeyiz Uygulaması Hakkında'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bu uygulama çeyiz ve bohça listelerinizi yönetmek için tasarlanmıştır.'),
            SizedBox(height: 8),
            Text('Sürüm: 1.0.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
