import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../utils/photo_helper.dart';

class ItemCard extends StatefulWidget {
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
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    final bool hasPhotos = widget.item.photoUrls.isNotEmpty;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF2C2C2C), // Koyu gri
                  const Color(0xFF1F1F1F), // Daha koyu gri
                ]
              : [
                  const Color(0xFF7B1FA2), // Mor
                  const Color(0xFF1976D2), // Mavi
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
            blurRadius: isDark ? 8 : 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.85),
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
                                onTap: widget.onTogglePurchased,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.item.isPurchased
                                        ? (isDark
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.15))
                                        : isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                    border: Border.all(
                                      color: widget.item.isPurchased
                                          ? (isDark ? Colors.green[700]! : Colors.green)
                                          : isDark
                                              ? Colors.grey[600]!
                                              : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      widget.item.isPurchased ? Icons.check : null,
                                      size: 18,
                                      color: widget.item.isPurchased
                                          ? (isDark ? Colors.green[400] : Colors.green)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.item.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        widget.item.isPurchased ? TextDecoration.lineThrough : null,
                                    color: isDark
                                        ? (widget.item.isPurchased
                                            ? Colors.grey[500]
                                            : Colors.white)
                                        : (widget.item.isPurchased ? Colors.grey : Colors.black87),
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
                            color: isDark
                                ? Colors.grey[850]
                                : const Color(0xFF7B1FA2).withOpacity(0.13),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            CurrencyFormatter.format(widget.item.price),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.grey[300] : const Color(0xFF7B1FA2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.item.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.black87,
                        ),
                      ),
                    ),
                    if (widget.item.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey,
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
                          'Eklenme: ${DateFormatter.formatShort(widget.item.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.photo_camera_outlined,
                              onPressed: widget.onAddPhoto,
                              tooltip: 'Fotoğraf Ekle',
                              isDark: isDark,
                            ),
                            _buildActionButton(
                              icon: Icons.edit_outlined,
                              onPressed: widget.onEdit,
                              tooltip: 'Düzenle',
                              isDark: isDark,
                            ),
                            _buildActionButton(
                              icon: Icons.delete_outline,
                              onPressed: widget.onDelete,
                              tooltip: 'Sil',
                              color: isDark ? Colors.red[300] : Colors.red,
                              isDark: isDark,
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
    bool isDark = false,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 20,
        color: color ?? (isDark ? Colors.grey[400] : null),
      ),
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
            itemCount: widget.item.photoUrls.length,
            controller: PageController(),
            itemBuilder: (context, index) {
              final photoUrl = widget.item.photoUrls[index];
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
          if (widget.item.photoUrls.length > 1) _buildPhotoIndicators(),

          // İptal edildi/alındı göstergesi (eğer item alındıysa)
          if (widget.item.isPurchased)
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
          onPressed: () => widget.onDeletePhoto?.call(photoUrl),
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
          onPressed: widget.onAddPhoto,
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
          widget.item.photoUrls.length,
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
