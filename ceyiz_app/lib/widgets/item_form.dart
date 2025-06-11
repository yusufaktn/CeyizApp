import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/bohca_item_model.dart';
import '../models/ceyiz_item_model.dart';
import '../utils/currency_formatter.dart';
import '../viewmodels/bohca_view_model.dart';
import '../viewmodels/ceyiz_view_model.dart';

enum FormType { ceyiz, bohca }

class ItemForm extends StatefulWidget {
  final FormType formType;
  final dynamic item; // CeyizItemModel veya BohcaItemModel
  final bool isEditing;

  const ItemForm({
    super.key,
    required this.formType,
    this.item,
    this.isEditing = false,
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  String _selectedCategory = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Düzenleme modunda ise form alanlarını doldur
    if (widget.item != null) {
      _nameController = TextEditingController(text: widget.item.name);
      _descriptionController = TextEditingController(text: widget.item.description);
      _priceController = TextEditingController(
          text: CurrencyFormatter.format(widget.item.price).replaceAll('₺', '').trim());
      _selectedCategory = widget.item.category;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      _selectedCategory = '';
    }

    // Kategorileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.formType == FormType.ceyiz) {
        Provider.of<CeyizViewModel>(context, listen: false).loadCategories();
      } else {
        Provider.of<BohcaViewModel>(context, listen: false).loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (widget.formType == FormType.ceyiz) {
        final ceyizViewModel = Provider.of<CeyizViewModel>(context, listen: false);
        await ceyizViewModel.addTempPhoto(File(image.path));
      } else {
        final bohcaViewModel = Provider.of<BohcaViewModel>(context, listen: false);
        await bohcaViewModel.addTempPhoto(File(image.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.formType == FormType.ceyiz ? _buildCeyizForm() : _buildBohcaForm();
  }

  Widget _buildCeyizForm() {
    return Consumer<CeyizViewModel>(
      builder: (context, viewModel, child) {
        return _buildForm(
          viewModel: viewModel,
          categories: viewModel.categories,
          tempPhotos: viewModel.tempPhotos,
          backgroundColor: AppColors.ceyizCategoryColor,
        );
      },
    );
  }

  Widget _buildBohcaForm() {
    return Consumer<BohcaViewModel>(
      builder: (context, viewModel, child) {
        return _buildForm(
          viewModel: viewModel,
          categories: viewModel.categories,
          tempPhotos: viewModel.tempPhotos,
          backgroundColor: AppColors.bohcaCategoryColor,
        );
      },
    );
  }

  Widget _buildForm({
    required dynamic viewModel,
    required List<String> categories,
    required List<String> tempPhotos,
    required Color backgroundColor,
  }) {
    // Kategori listesinden ana başlıklar ve 'Diğer' çıkarılıyor
    final filteredCategories =
        categories.where((cat) => cat != 'Çeyiz' && cat != 'Bohça' && cat != 'Diğer').toList();
    // Varsayılan kategori listenin başı
    if (_selectedCategory.isEmpty && filteredCategories.isNotEmpty) {
      _selectedCategory = filteredCategories.first;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360; // Küçük ekranlar için kontrol

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Ürün Bilgileri Bölümü
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      'Ürün Bilgileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ad alanı
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Ürün Adı',
                        hintText: 'Örn: Nevresim Takımı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: backgroundColor),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                        prefixIcon: const Icon(Icons.shopping_bag_outlined),
                        contentPadding: isSmallScreen
                            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir ad girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Açıklama alanı
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Açıklama',
                        hintText: 'Ürün hakkında detaylar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: backgroundColor),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                        prefixIcon: const Icon(Icons.description_outlined),
                        contentPadding: isSmallScreen
                            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                            : null,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Kategori ve fiyat - küçük ekranlarda alt alta, büyük ekranlarda yan yana
                    isSmallScreen
                        ? Column(
                            children: [
                              _buildCategoryDropdown(filteredCategories, backgroundColor, isDark),
                              const SizedBox(height: 16),
                              _buildPriceField(backgroundColor, isDark),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildCategoryDropdown(
                                    filteredCategories, backgroundColor, isDark),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: _buildPriceField(backgroundColor, isDark),
                              ),
                            ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Fotoğraflar Bölümü
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                      'Fotoğraflar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: backgroundColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_photo_alternate, color: backgroundColor),
                          onPressed: _pickImage,
                          tooltip: 'Fotoğraf Ekle',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Fotoğraf listesi
                    if (tempPhotos.isEmpty)
                      Container(
                        height: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 40,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fotoğraf eklemek için tıklayın',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: tempPhotos.length,
                          itemBuilder: (context, index) {
                            final photoUrl = tempPhotos[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                    Image.file(
                                      File(photoUrl),
                                      height: 104,
                                      width: 104,
                                      fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                      top: 4,
                                      right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (widget.formType == FormType.ceyiz) {
                                          (viewModel as CeyizViewModel).removeTempPhoto(photoUrl);
                                        } else {
                                          (viewModel as BohcaViewModel).removeTempPhoto(photoUrl);
                                        }
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.7),
                                            shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                ),
                              ),
                            );
                          },
                      ),
                    ),
                  ],
                ),
              ),
            ),

              const SizedBox(height: 24),

            // Kaydet butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: backgroundColor,
                  foregroundColor: Colors.white,
                elevation: 0,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: _isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Text(widget.isEditing ? 'Güncelle' : 'Kaydet'),
              ),
            ],
          ),
        ),
    );
  }

  // Kategori dropdown widget'ı
  Widget _buildCategoryDropdown(
      List<String> filteredCategories, Color backgroundColor, bool isDark) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Kategori',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: backgroundColor),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
        prefixIcon: const Icon(Icons.category_outlined),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      value: filteredCategories.contains(_selectedCategory)
          ? _selectedCategory
          : (filteredCategories.isNotEmpty ? filteredCategories.first : null),
      items: filteredCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir kategori seçin';
        }
        return null;
      },
      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: backgroundColor),
      isExpanded: true,
    );
  }

  // Fiyat alanı widget'ı
  Widget _buildPriceField(Color backgroundColor, bool isDark) {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: 'Fiyat',
        hintText: '0,00 ₺',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: backgroundColor),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
        prefixIcon: const Icon(Icons.attach_money),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        CurrencyInputFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Fiyat girin';
        }
        final price = CurrencyFormatter.parse(value);
        if (price <= 0) {
          return 'Geçersiz fiyat';
        }
        return null;
      },
    );
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final name = _nameController.text.trim();
        final description = _descriptionController.text.trim();
        final price = CurrencyFormatter.parse(_priceController.text.trim());

        print(
            'ItemForm._saveItem: Saving item - name: $name, category: $_selectedCategory, price: $price');

        if (widget.formType == FormType.ceyiz) {
          final viewModel = Provider.of<CeyizViewModel>(context, listen: false);

          if (widget.isEditing && widget.item != null) {
            final updatedItem = (widget.item as CeyizItemModel).copyWith(
              name: name,
              description: description,
              category: _selectedCategory,
              price: price,
              photoUrls: [
                ...widget.item.photoUrls,
                ...viewModel.tempPhotos,
              ],
            );
            print('ItemForm._saveItem: Updating existing item (id: ${updatedItem.id})');
            await viewModel.updateItem(updatedItem);
            viewModel.clearTempPhotos();
          } else {
            print('ItemForm._saveItem: Adding new Ceyiz item');
            await viewModel.addItem(name, description, _selectedCategory, price);
            print('ItemForm._saveItem: Item added to CeyizViewModel');
          }
        } else {
          final viewModel = Provider.of<BohcaViewModel>(context, listen: false);

          if (widget.isEditing && widget.item != null) {
            final updatedItem = (widget.item as BohcaItemModel).copyWith(
              name: name,
              description: description,
              category: _selectedCategory,
              price: price,
              photoUrls: [
                ...widget.item.photoUrls,
                ...viewModel.tempPhotos,
              ],
            );
            print('ItemForm._saveItem: Updating existing item (id: ${updatedItem.id})');
            await viewModel.updateItem(updatedItem);
            viewModel.clearTempPhotos();
          } else {
            print('ItemForm._saveItem: Adding new Bohca item');
            await viewModel.addItem(name, description, _selectedCategory, price);
            print('ItemForm._saveItem: Item added to BohcaViewModel');
          }
        }

        if (mounted) {
          print('ItemForm._saveItem: Form completed, closing dialog');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    widget.isEditing ? 'Ürün başarıyla güncellendi' : 'Ürün başarıyla eklendi')),
          );
        }
      } catch (e) {
        print('ItemForm._saveItem: ERROR: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
