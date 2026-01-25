import 'dart:convert';
import 'package:flutter/material.dart';

class CustomProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double iconSize;
  final Color placeholderColor;

  const CustomProfileImage({
    super.key,
    required this.imageUrl,
    this.size = 55,
    this.iconSize = 32,
    this.placeholderColor = const Color(0xFF0d4f9d),
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    try {
      if (imageUrl!.startsWith('data:image')) {
        final base64String = imageUrl!.split(',').last;
        return ClipOval(
          child: Image.memory(
            base64Decode(base64String),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        );
      }

      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Image load error: $error');
            return _buildPlaceholder();
          },
        ),
      );
    } catch (e) {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Icon(Icons.person, size: iconSize, color: placeholderColor),
    );
  }
}
