import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../viewmodels/bohca_view_model.dart';
import '../viewmodels/ceyiz_view_model.dart';
import '../widgets/gradient_app_bar.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int selectedMainIndex = 0; // 0: Çeyiz, 1: Bohça
  int selectedCategoryIndex = 0;
  int selectedFilterIndex = 0; // 0: Hepsi, 1: Aldıklarım, 2: Almadıklarım
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CeyizViewModel>(context, listen: false).init();
      Provider.of<BohcaViewModel>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ceyizViewModel = Provider.of<CeyizViewModel>(context);
    final bohcaViewModel = Provider.of<BohcaViewModel>(context);

    final anaKategoriler = ['Çeyiz', 'Bohça'];
    final ceyizKategoriler = ceyizViewModel.categories
        .where((cat) => cat != 'Çeyiz' && cat != 'Bohça' && cat != 'Diğer')
        .toList();
    final bohcaKategoriler = bohcaViewModel.categories
        .where((cat) => cat != 'Çeyiz' && cat != 'Bohça' && cat != 'Diğer')
        .toList();
    final altKategoriler = selectedMainIndex == 0 ? ceyizKategoriler : bohcaKategoriler;
    if (altKategoriler.isEmpty) {
      return const Center(child: Text('Hiç kategori yok. Lütfen kategori ekleyin.'));
    }
    final selectedCategory = altKategoriler[selectedCategoryIndex];
    final viewModel = selectedMainIndex == 0 ? ceyizViewModel : bohcaViewModel;

    // Filtreleme
    List filteredItems =
        viewModel.items.where((item) => item.category == selectedCategory).toList();
    if (selectedFilterIndex == 1) {
      filteredItems = filteredItems.where((item) => item.isPurchased).toList();
    } else if (selectedFilterIndex == 2) {
      filteredItems = filteredItems.where((item) => !item.isPurchased).toList();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: GradientAppBar(
        title: 'Kategoriler',
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Kategoriler', style: Theme.of(context).textTheme.titleLarge),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    // Ana kategoriler
                    ...List.generate(anaKategoriler.length, (mainIdx) {
                      final isSelectedMain = selectedMainIndex == mainIdx;
                      final subCategories = mainIdx == 0 ? ceyizKategoriler : bohcaKategoriler;
                      return ExpansionTile(
                        initiallyExpanded: isSelectedMain,
                        title: Text(
                          anaKategoriler[mainIdx],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelectedMain ? AppColors.primaryColor : null,
                          ),
                        ),
                        children: subCategories.isEmpty
                            ? [const ListTile(title: Text('Alt kategori yok'))]
                            : List.generate(subCategories.length, (subIdx) {
                                final isSelected =
                                    isSelectedMain && selectedCategoryIndex == subIdx;
                                return ListTile(
                                  title: Text(subCategories[subIdx]),
                                  selected: isSelected,
                                  selectedTileColor: AppColors.primaryColor.withOpacity(0.08),
                                  onTap: () {
                                    setState(() {
                                      selectedMainIndex = mainIdx;
                                      selectedCategoryIndex = subIdx;
                                    });
                                    Navigator.of(context).maybePop();
                                  },
                                );
                              }),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alt kategori seçimi (ChoiceChip)
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: altKategoriler.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ChoiceChip(
                  label: Text(altKategoriler[index]),
                  selected: selectedCategoryIndex == index,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                  },
                  selectedColor: AppColors.primaryColor,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: selectedCategoryIndex == index ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          // Aldıklarım / Almadıklarım / Hepsi toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ToggleButtons(
              isSelected: [
                selectedFilterIndex == 0,
                selectedFilterIndex == 1,
                selectedFilterIndex == 2
              ],
              onPressed: (index) {
                setState(() {
                  selectedFilterIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: AppColors.primaryColor,
              color: AppColors.primaryColor,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Hepsi'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Aldıklarım'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Almadıklarım'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedFilterIndex == 1
                              ? 'Bu kategoride aldığınız ürün yok.'
                              : selectedFilterIndex == 2
                                  ? 'Bu kategoride alınmayan ürün yok.'
                                  : 'Bu kategoride ürün yok.',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bu kategoriye ürün eklemek için ilgili listeye gidin',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [
                                    const Color(0xFF2C2C2C),
                                    const Color(0xFF1F1F1F),
                                  ]
                                : [
                                    const Color(0xFFF5F5F5),
                                    Colors.white,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              decoration: item.isPurchased
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? item.isPurchased
                                      ? Colors.grey
                                      : Colors.white
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Fiyat: ${item.price.toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : null,
                                ),
                              ),
                              Text(
                                'Açıklama: ${item.description}',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : null,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            item.isPurchased ? Icons.check_circle : Icons.check_circle_outline,
                            color: item.isPurchased
                                ? isDarkMode
                                    ? Colors.tealAccent[400]
                                    : AppColors.primaryColor
                                : isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey,
                          ),
                          onTap: () {
                            viewModel.togglePurchaseStatus(item.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
