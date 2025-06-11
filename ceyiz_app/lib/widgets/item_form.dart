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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7B1FA2),
            Color(0xFF1976D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ad alanı
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ürün Adı',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Kategori seçimi
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      value: filteredCategories.contains(_selectedCategory)
                          ? _selectedCategory
                          : (filteredCategories.isNotEmpty ? filteredCategories.first : null),
                      items: filteredCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
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
                    ),
                    const SizedBox(height: 16),
                    // Fiyat alanı
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Fiyat (₺)',
                        hintText: '0,00',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        CurrencyInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir fiyat girin';
                        }
                        final price = CurrencyFormatter.parse(value);
                        if (price <= 0) {
                          return 'Geçerli bir fiyat girin';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Fotoğraf ekleme
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Fotoğraflar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (tempPhotos.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: tempPhotos.length,
                          itemBuilder: (context, index) {
                            final photoUrl = tempPhotos[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(photoUrl),
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (widget.formType == FormType.ceyiz) {
                                          (viewModel as CeyizViewModel).removeTempPhoto(photoUrl);
                                        } else {
                                          (viewModel as BohcaViewModel).removeTempPhoto(photoUrl);
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
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
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Fotoğraf Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: backgroundColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.isEditing ? 'Güncelle' : 'Kaydet'),
              ),
            ],
          ),
        ),
      ),
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
