import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final int rank;
  final VoidCallback? onTap;
  final VoidCallback? onYelpTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.rank,
    this.onTap,
    this.onYelpTap,
  });

  Color get _rankColor {
    return switch (rank) {
      1 => const Color(0xFFFF6B35),
      2 => const Color(0xFFFFA94D),
      3 => const Color(0xFF69DB7C),
      _ => const Color(0xFF74C0FC),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo header
            _buildPhotoHeader(),
            // Details section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + rank badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            fontSize: 17,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _rankColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating row
                  _buildRatingRow(),
                  const SizedBox(height: 8),
                  // Categories
                  if (restaurant.categories.isNotEmpty) ...[
                    _buildCategoryChips(),
                    const SizedBox(height: 8),
                  ],
                  // Address + distance
                  _buildAddressRow(),
                  // Phone
                  if (restaurant.phone != null &&
                      restaurant.phone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: Color(0xFFAAAAAA),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          restaurant.phone!,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  // View on Yelp button
                  if (restaurant.yelpUrl != null)
                    _buildYelpButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoHeader() {
    return Stack(
      children: [
        // Photo or placeholder
        SizedBox(
          height: 180,
          width: double.infinity,
          child: restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: restaurant.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _photoPlaceholder(),
                  errorWidget: (context, url, error) => _photoPlaceholder(),
                )
              : _photoPlaceholder(),
        ),
        // Gradient overlay at bottom of photo
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.25),
                ],
              ),
            ),
          ),
        ),
        // Price badge on photo
        if (restaurant.priceLevelDisplay.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                restaurant.priceLevelDisplay,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        // Distance badge on photo
        if (restaurant.distanceDisplay.isNotEmpty)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.distanceDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFF5EDE4),
      child: const Center(
        child: Text('🍽️', style: TextStyle(fontSize: 52)),
      ),
    );
  }

  Widget _buildRatingRow() {
    final combined = restaurant.combinedRating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Star icons based on combined rating
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final filled = i < combined.floor();
                final half = !filled && i < combined;
                return Icon(
                  filled
                      ? Icons.star_rounded
                      : half
                          ? Icons.star_half_rounded
                          : Icons.star_outline_rounded,
                  size: 16,
                  color: const Color(0xFFF59E0B),
                );
              }),
            ),
            const SizedBox(width: 6),
            Text(
              combined.toStringAsFixed(1),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${_formatReviewCount(restaurant.combinedReviewCount)})',
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        _buildRatingSourceLine(),
      ],
    );
  }

  Widget _buildRatingSourceLine() {
    final hasYelp = restaurant.rating > 0;
    final hasGoogle =
        restaurant.googleRating != null && restaurant.googleRating! > 0;

    if (!hasYelp && !hasGoogle) return const SizedBox.shrink();

    final parts = <String>[];
    if (hasYelp) parts.add('Yelp ${restaurant.rating.toStringAsFixed(1)}');
    if (hasGoogle) {
      parts.add('Google ${restaurant.googleRating!.toStringAsFixed(1)}');
    }

    return Text(
      parts.join(' · '),
      style: const TextStyle(
        color: Color(0xFFAAAAAA),
        fontSize: 12,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: restaurant.categories.take(3).map((cat) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFFD4B8),
              width: 1,
            ),
          ),
          child: Text(
            cat,
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 14,
          color: Color(0xFFAAAAAA),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            restaurant.address,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 13,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildYelpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onYelpTap,
        icon: const Text(
          'y',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: Color(0xFFFF1A1A),
          ),
        ),
        label: const Text(
          'View on Yelp',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD32323),
          side: const BorderSide(color: Color(0xFFD32323), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      final k = count / 1000.0;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return count.toString();
  }
}
