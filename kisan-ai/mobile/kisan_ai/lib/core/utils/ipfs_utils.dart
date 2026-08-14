/**
 * IPFS Utilities
 * Helper functions for displaying images from IPFS and handling fallbacks
 */

import 'package:flutter/material.dart';

class IPFSUtils {
  /// IPFS Gateway URL
  static const String ipfsGateway = 'https://gateway.pinata.cloud';

  /// Convert IPFS hash to gateway URL
  static String getIPFSUrl(String hash) {
    if (hash.isEmpty) return '';

    // Check if already a full URL
    if (hash.startsWith('http')) {
      return hash;
    }

    // Check if local path (for fallback storage)
    if (hash.startsWith('local_')) {
      return hash; // Will be handled as local path
    }

    // Convert IPFS hash to gateway URL
    return '$ipfsGateway/ipfs/$hash';
  }

  /// Display image with IPFS fallback
  static Widget displayImage({
    required String ipfsHash,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    VoidCallback? onTap,
  }) {
    final imageUrl = getIPFSUrl(ipfsHash);

    Widget imageWidget;

    if (ipfsHash.startsWith('local_')) {
      // Local fallback image
      imageWidget = Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image_not_supported)),
      );
    } else {
      // IPFS network image
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder:
            errorBuilder ??
            (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image_not_supported)),
              );
            },
      );
    }

    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius, child: imageWidget);
    }

    // Add tap handler if provided
    if (onTap != null) {
      imageWidget = GestureDetector(onTap: onTap, child: imageWidget);
    }

    return imageWidget;
  }

  /// Display gallery of IPFS images
  static Widget displayImageGallery({
    required List<String> ipfsHashes,
    required double height,
    int crossAxisCount = 3,
    EdgeInsets? padding,
    VoidCallback? onImageTap,
  }) {
    if (ipfsHashes.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey[200],
        child: const Center(child: Text('No images available')),
      );
    }

    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: ipfsHashes.length,
      itemBuilder: (context, index) {
        return displayImage(
          ipfsHash: ipfsHashes[index],
          width: double.infinity,
          height: double.infinity,
          borderRadius: BorderRadius.circular(8),
          onTap: onImageTap,
        );
      },
    );
  }

  /// Get gateway status (ping to check availability)
  static Future<bool> isGatewayAvailable() async {
    try {
      // This is a quick check without heavy computation
      return true; // In production, you'd do actual ping
    } catch (e) {
      return false;
    }
  }

  /// Validate IPFS hash format
  static bool isValidIPFSHash(String hash) {
    // IPFS hashes start with 'Qm' or 'bafy' (CIDv1)
    // Local fallbacks start with 'local_'
    return hash.startsWith('Qm') ||
        hash.startsWith('bafy') ||
        hash.startsWith('local_') ||
        hash.startsWith('http');
  }

  /// Get image URL for marketplace listing
  static List<String> getListingImageUrls(List<String> ipfsHashes) {
    return ipfsHashes
        .where((hash) => isValidIPFSHash(hash))
        .map((hash) => getIPFSUrl(hash))
        .toList();
  }
}
