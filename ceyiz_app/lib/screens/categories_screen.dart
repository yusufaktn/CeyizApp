import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/bohca_view_model.dart';
import '../viewmodels/ceyiz_view_model.dart';

class CategoriesScreen extends StatefulWidget {
  final bool isCeyiz;
  const CategoriesScreen({super.key, this.isCeyiz = true});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dynamic viewModel = widget.isCeyiz
        ? Provider.of<CeyizViewModel>(context)
        : Provider.of<BohcaViewModel>(context);
    final List<String> categories = viewModel.categories;
    // Ana kategorileri filtrele
    final List<String> filteredCategories =
        categories.where((cat) => cat != 'Çeyiz' && cat != 'Bohça' && cat != 'Diğer').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategoriler'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Yeni Kategori Ekle',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final newCategory = _controller.text.trim();
                          if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
                            setState(() => _isLoading = true);
                            await viewModel.addCategory(newCategory);
                            _controller.clear();
                            setState(() => _isLoading = false);
                          }
                        },
                ),
              ),
              onSubmitted: (val) async {
                final newCategory = val.trim();
                if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
                  setState(() => _isLoading = true);
                  await viewModel.addCategory(newCategory);
                  _controller.clear();
                  setState(() => _isLoading = false);
                }
              },
            ),
            const SizedBox(height: 24),
            Text('Kategoriler', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: filteredCategories.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return ListTile(
                    title: Text(category),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        await viewModel.removeCategory(category);
                        setState(() => _isLoading = false);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
