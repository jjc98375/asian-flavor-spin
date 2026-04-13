import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';
import '../models/yelp_review.dart';
import '../services/yelp_service.dart';
import '../services/places_service.dart';
import '../widgets/photo_viewer.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;
  final String yelpApiKey;
  final String placesApiKey;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    required this.yelpApiKey,
    required this.placesApiKey,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  RestaurantDetail? _detail;
  List<String> _allPhotos = [];
  List<YelpReview> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  static const _warmBg = Color(0xFFFFF8F0);
  static const _orange = Color(0xFFFF6B35);
  static const _textDark = Color(0xFF1A1A1A);
  static const _textMid = Color(0xFF666666);
  static const _textLight = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final yelpService = YelpService(apiKey: widget.yelpApiKey);

      // Fetch Yelp detail and reviews in parallel
      final results = await Future.wait([
        yelpService.getBusinessDetails(widget.restaurant.yelpId!),
        yelpService.getBusinessReviews(widget.restaurant.yelpId!),
      ]);

      final detail = results[0] as RestaurantDetail;
      final reviews = results[1] as List<YelpReview>;

      // Start with Yelp photos
      final yelpPhotos = List<String>.from(detail.photos);

      // Fetch Google Places photos to supplement (up to 10 total)
      List<String> googlePhotos = [];
      if (widget.placesApiKey.isNotEmpty) {
        try {
          googlePhotos = await PlacesService(apiKey: widget.placesApiKey)
              .getPlacePhotos(
            widget.restaurant.name,
            widget.restaurant.latitude,
            widget.restaurant.longitude,
          );
        } catch (_) {
          // Google photos are supplemental; ignore failures
        }
      }

      // Combine: Yelp first, then Google (deduped by URL), cap at 10
      final seen = <String>{};
      final combined = <String>[];
      for (final url in [...yelpPhotos, ...googlePhotos]) {
        if (url.isNotEmpty && seen.add(url)) {
          combined.add(url);
          if (combined.length >= 10) break;
        }
      }

      // Fall back to the list-level image if we still have nothing
      if (combined.isEmpty && widget.restaurant.imageUrl != null) {
        combined.add(widget.restaurant.imageUrl!);
      }

      if (mounted) {
        setState(() {
          _detail = detail;
          _allPhotos = combined;
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load details. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openDirections() async {
    final r = widget.restaurant;
    final lat = r.latitude;
    final lng = r.longitude;
    final name = Uri.encodeComponent(r.name);
    final appleUri = Uri.parse('maps://?q=$name&ll=$lat,$lng');
    final googleUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(appleUri)) {
      await launchUrl(appleUri);
    } else {
      await launchUrl(googleUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroImage =
        _allPhotos.isNotEmpty ? _allPhotos[0] : widget.restaurant.imageUrl;

    return Scaffold(
      backgroundColor: _warmBg,
      body: CustomScrollView(
        slivers: [
          // Collapsing app bar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: _warmBg,
            foregroundColor: _textDark,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: heroImage != null && heroImage.isNotEmpty
                  ? GestureDetector(
                      onTap: _allPhotos.isNotEmpty
                          ? () => showPhotoViewer(context, _allPhotos, 0)
                          : null,
                      child: CachedNetworkImage(
                        imageUrl: heroImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _photoPlaceholder(),
                        errorWidget: (_, __, ___) => _photoPlaceholder(),
                      ),
                    )
                  : _photoPlaceholder(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildContent(widget.restaurant),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _orange, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Loading details...',
              style: TextStyle(color: _textLight, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textMid, fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Restaurant restaurant) {
    final detail = _detail!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo carousel + thumbnails
        if (_allPhotos.isNotEmpty) _buildPhotoGallery(_allPhotos),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // Rating + reviews
              _buildRatingRow(restaurant),
              const SizedBox(height: 12),

              // Price + categories
              _buildPriceCategoryRow(restaurant),
              const SizedBox(height: 12),

              // Open/closed + transactions
              _buildStatusRow(detail),
              const SizedBox(height: 20),

              // Address card
              _buildInfoCard(children: [
                _buildAddressSection(restaurant),
              ]),
              const SizedBox(height: 12),

              // Phone card
              if (restaurant.phone != null &&
                  restaurant.phone!.isNotEmpty) ...[
                _buildInfoCard(children: [
                  _buildPhoneSection(restaurant.phone!),
                ]),
                const SizedBox(height: 12),
              ],

              // Hours card
              if (detail.hours.isNotEmpty) ...[
                _buildInfoCard(children: [
                  _buildHoursSection(detail.hours),
                ]),
                const SizedBox(height: 12),
              ],

              // Reviews section
              if (_reviews.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildReviewsSection(_reviews),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // ── Photo gallery ──────────────────────────────────────────────────────────

  Widget _buildPhotoGallery(List<String> photos) {
    return Column(
      children: [
        // Main carousel
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _currentPhotoIndex = i),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => showPhotoViewer(context, photos, index),
                child: CachedNetworkImage(
                  imageUrl: photos[index],
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _photoPlaceholder(),
                  errorWidget: (_, __, ___) => _photoPlaceholder(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Counter + dot indicator row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPhotoIndex + 1}/${photos.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textMid,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ...List.generate(photos.length.clamp(0, 8), (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPhotoIndex == i ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _currentPhotoIndex == i
                      ? _orange
                      : const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
            if (photos.length > 8) ...[
              const SizedBox(width: 4),
              const Text('…',
                  style: TextStyle(color: _textLight, fontSize: 13)),
            ],
          ],
        ),

        const SizedBox(height: 10),

        // Thumbnail strip
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final isSelected = index == _currentPhotoIndex;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _orange : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: photos[index],
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: const Color(0xFFF5EDE4)),
                      errorWidget: (_, __, ___) =>
                          Container(color: const Color(0xFFF5EDE4)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Reviews ────────────────────────────────────────────────────────────────

  Widget _buildReviewsSection(List<YelpReview> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 12),
        ...reviews.map((r) => _buildReviewCard(r)),
      ],
    );
  }

  Widget _buildReviewCard(YelpReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer name + avatar + rating
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF5EDE4),
                backgroundImage: review.userImageUrl != null &&
                        review.userImageUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(review.userImageUrl!)
                    : null,
                child: (review.userImageUrl == null ||
                        review.userImageUrl!.isEmpty)
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: _orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      _formatReviewDate(review.timeCreated),
                      style: const TextStyle(
                          fontSize: 12, color: _textLight),
                    ),
                  ],
                ),
              ),
              // Star rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final filled = i < review.rating.floor();
                  final half = !filled && i < review.rating;
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
            ],
          ),
          const SizedBox(height: 10),
          // Review text
          Text(
            review.text,
            style: const TextStyle(
              fontSize: 14,
              color: _textMid,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Existing section builders ──────────────────────────────────────────────

  Widget _buildRatingRow(Restaurant restaurant) {
    final combined = restaurant.combinedRating;
    final hasYelp = restaurant.rating > 0;
    final hasGoogle =
        restaurant.googleRating != null && restaurant.googleRating! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary combined rating with stars
        Row(
          children: [
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
                  size: 20,
                  color: const Color(0xFFF59E0B),
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              combined.toStringAsFixed(1),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _textDark),
            ),
            const SizedBox(width: 4),
            Text(
              '(${_formatReviewCount(restaurant.combinedReviewCount)} reviews)',
              style: const TextStyle(fontSize: 14, color: _textLight),
            ),
          ],
        ),
        // Source breakdown
        if (hasYelp || hasGoogle) ...[
          const SizedBox(height: 6),
          _buildRatingBreakdown(restaurant, hasYelp, hasGoogle),
        ],
      ],
    );
  }

  Widget _buildRatingBreakdown(
      Restaurant restaurant, bool hasYelp, bool hasGoogle) {
    final parts = <InlineSpan>[];

    if (hasYelp) {
      parts.add(const TextSpan(
        text: 'Yelp: ',
        style: TextStyle(fontSize: 13, color: _textMid),
      ));
      parts.add(const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
      ));
      parts.add(TextSpan(
        text:
            ' ${restaurant.rating.toStringAsFixed(1)} (${_formatReviewCount(restaurant.reviewCount)})',
        style: const TextStyle(
          fontSize: 13,
          color: _textDark,
          fontWeight: FontWeight.w500,
        ),
      ));
      if (hasGoogle) {
        parts.add(const TextSpan(
          text: '  ·  ',
          style: TextStyle(fontSize: 13, color: _textLight),
        ));
      }
    }

    if (hasGoogle) {
      parts.add(const TextSpan(
        text: 'Google: ',
        style: TextStyle(fontSize: 13, color: _textMid),
      ));
      parts.add(const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
      ));
      parts.add(TextSpan(
        text:
            ' ${restaurant.googleRating!.toStringAsFixed(1)} (${_formatReviewCount(restaurant.googleReviewCount ?? 0)})',
        style: const TextStyle(
          fontSize: 13,
          color: _textDark,
          fontWeight: FontWeight.w500,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        children: parts,
        style: const TextStyle(fontFamily: ''),
      ),
    );
  }

  Widget _buildPriceCategoryRow(Restaurant restaurant) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (restaurant.priceLevelDisplay.isNotEmpty)
          _chip(
            restaurant.priceLevelDisplay,
            bg: const Color(0xFFFFF0E8),
            border: const Color(0xFFFFD4B8),
            text: _orange,
          ),
        ...restaurant.categories.take(4).map((cat) => _chip(
              cat,
              bg: const Color(0xFFFFF0E8),
              border: const Color(0xFFFFD4B8),
              text: _orange,
            )),
      ],
    );
  }

  Widget _buildStatusRow(RestaurantDetail detail) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(
          detail.isOpenNow ? 'Open Now' : 'Closed',
          bg: detail.isOpenNow
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFFFEBEE),
          border: detail.isOpenNow
              ? const Color(0xFFA5D6A7)
              : const Color(0xFFEF9A9A),
          text: detail.isOpenNow
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
          icon: detail.isOpenNow
              ? Icons.check_circle_outline
              : Icons.cancel_outlined,
        ),
        ...detail.transactions.map((t) => _chip(
              _formatTransaction(t),
              bg: const Color(0xFFE3F2FD),
              border: const Color(0xFF90CAF9),
              text: const Color(0xFF1565C0),
              icon: _transactionIcon(t),
            )),
      ],
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildAddressSection(Restaurant restaurant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on_rounded, size: 20, color: _orange),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.address,
                style: const TextStyle(
                    fontSize: 15, color: _textDark, height: 1.4),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection(String phone) {
    return Row(
      children: [
        const Icon(Icons.phone_rounded, size: 20, color: _orange),
        const SizedBox(width: 10),
        Expanded(
          child:
              Text(phone, style: const TextStyle(fontSize: 15, color: _textDark)),
        ),
        TextButton(
          onPressed: () => _callPhone(phone),
          style: TextButton.styleFrom(
            foregroundColor: _orange,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: _orange, width: 1.5),
            ),
          ),
          child: const Text('Call',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildHoursSection(List<DailyHours> hours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.schedule_rounded, size: 20, color: _orange),
            SizedBox(width: 10),
            Text(
              'Hours',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textDark),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...hours.map((h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      h.dayName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textDark),
                    ),
                  ),
                  Text(
                    h.timeRange,
                    style: TextStyle(
                        fontSize: 14,
                        color: h.isClosed ? _textLight : _textMid),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _chip(
    String label, {
    required Color bg,
    required Color border,
    required Color text,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
                color: text, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFF5EDE4),
      child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 52))),
    );
  }

  String _formatTransaction(String t) {
    return switch (t) {
      'delivery' => 'Delivery',
      'pickup' => 'Pickup',
      'restaurant_reservation' => 'Reservations',
      _ => t[0].toUpperCase() + t.substring(1),
    };
  }

  IconData _transactionIcon(String t) {
    return switch (t) {
      'delivery' => Icons.delivery_dining_rounded,
      'pickup' => Icons.shopping_bag_outlined,
      'restaurant_reservation' => Icons.event_seat_outlined,
      _ => Icons.check_circle_outline,
    };
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      final k = count / 1000.0;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return count.toString();
  }

  String _formatReviewDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
