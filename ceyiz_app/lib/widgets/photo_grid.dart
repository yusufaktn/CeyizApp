import 'dart:io';

import 'package:flutter/material.dart';

class PhotoGrid extends StatelessWidget {
  final List<String> photoUrls;
  final bool isEditable;
  final Function(String)? onDeletePhoto;
  final VoidCallback? onAddPhoto;

  const PhotoGrid({
    super.key,
    required this.photoUrls,
    this.isEditable = false,
    this.onDeletePhoto,
    this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fotoğraflar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (onAddPhoto != null)
              TextButton.icon(
                onPressed: onAddPhoto,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Ekle'),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (photoUrls.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Henüz fotoğraf eklenmemiş',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (onAddPhoto != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onAddPhoto,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Fotoğraf Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: photoUrls.length,
            itemBuilder: (context, index) {
              final photoUrl = photoUrls[index];
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showFullSizeImage(context, photoUrl),
                    child: Hero(
                      tag: photoUrl,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(photoUrl)),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isEditable && onDeletePhoto != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onDeletePhoto!(photoUrl),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
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
              );
            },
          ),
      ],
    );
  }

  void _showFullSizeImage(BuildContext context, String photoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Fotoğraf'),
            actions: [
              if (isEditable && onDeletePhoto != null)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    onDeletePhoto!(photoUrl);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          body: Center(
            child: Hero(
              tag: photoUrl,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(photoUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
