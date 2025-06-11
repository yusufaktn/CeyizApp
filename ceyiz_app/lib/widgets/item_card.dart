import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../utils/photo_helper.dart';

class ItemCard extends StatelessWidget {
  final dynamic item; // CeyizItemModel veya BohcaItemModel
  final VoidCallback onTogglePurchased;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddPhoto;
  final Function(String)? onDeletePhoto;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTogglePurchased,
    required this.onEdit,
    required this.onDelete,
    this.onAddPhoto,
    this.onDeletePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhotos = item.photoUrls.isNotEmpty;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7B1FA2), // Mor
            Color(0xFF1976D2), // Mavi
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: Colors.white.withOpacity(isDark ? 0.08 : 0.85),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasPhotos) _buildPhotoHeader(context),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: onTogglePurchased,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: item.isPurchased
                                        ? Colors.green.withOpacity(0.15)
                                        : isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                    border: Border.all(
                                      color: item.isPurchased ? Colors.green : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      item.isPurchased ? Icons.check : null,
                                      size: 18,
                                      color: item.isPurchased ? Colors.green : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        item.isPurchased ? TextDecoration.lineThrough : null,
                                    color: item.isPurchased ? Colors.grey : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B1FA2).withOpacity(0.13),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            CurrencyFormatter.format(item.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF7B1FA2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Eklenme: ${DateFormatter.formatShort(item.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.photo_camera_outlined,
                              onPressed: onAddPhoto,
                              tooltip: 'Fotoğraf Ekle',
                            ),
                            _buildActionButton(
                              icon: Icons.edit_outlined,
                              onPressed: onEdit,
                              tooltip: 'Düzenle',
                            ),
                            _buildActionButton(
                              icon: Icons.delete_outline,
                              onPressed: onDelete,
                              tooltip: 'Sil',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
      splashRadius: 20,
    );
  }

  Widget _buildPhotoHeader(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: item.photoUrls.length,
            controller: PageController(),
            itemBuilder: (context, index) {
              final photoUrl = item.photoUrls[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  PhotoHelper.buildPhotoWidget(photoUrl),
                  _buildDeletePhotoButton(photoUrl),
                ],
              );
            },
          ),
          _buildAddPhotoButton(),
          if (item.photoUrls.length > 1) _buildPhotoIndicators(),

          // İptal edildi/alındı göstergesi (eğer item alındıysa)
          if (item.isPurchased)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ALINDI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeletePhotoButton(String photoUrl) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white, size: 18),
          onPressed: () => onDeletePhoto?.call(photoUrl),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          splashRadius: 20,
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.add_a_photo, color: Colors.white, size: 18),
          onPressed: () => onAddPhoto?.call(),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          splashRadius: 20,
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          item.photoUrls.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
