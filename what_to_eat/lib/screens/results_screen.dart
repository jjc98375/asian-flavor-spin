import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cuisine.dart';
import '../models/restaurant.dart';
import '../services/location_service.dart';
import '../services/yelp_service.dart';
import '../services/places_service.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_detail_screen.dart';

enum _ViewMode { list, map }

class ResultsScreen extends StatefulWidget {
  final Cuisine cuisine;
  final String dishType;

  const ResultsScreen({
    super.key,
    required this.cuisine,
    required this.dishType,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  static const _yelpApiKey = String.fromEnvironment('YELP_API_KEY');
  static const _placesApiKey = String.fromEnvironment('PLACES_API_KEY');

  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String? _errorMessage;
  _ViewMode _viewMode = _ViewMode.list;

  // Map state
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _markers = {};
      _selectedRestaurant = null;
    });

    try {
      final position = await LocationService().getCurrentPosition();

      List<Restaurant> results = [];

      // Try Yelp first
      if (_yelpApiKey.isNotEmpty) {
        try {
          results = await YelpService(apiKey: _yelpApiKey).searchRestaurants(
            dishType: widget.dishType,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        } on YelpServiceException {
          results = [];
        }
      }

      // Fallback to Google Places if Yelp returned nothing
      if (results.isEmpty && _placesApiKey.isNotEmpty) {
        results = await PlacesService(apiKey: _placesApiKey).searchRestaurants(
          dishType: widget.dishType,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      // Fetch Google ratings in parallel and merge
      if (_placesApiKey.isNotEmpty && results.isNotEmpty) {
        final placesService = PlacesService(apiKey: _placesApiKey);
        final ratingFutures = results.map(
          (r) => placesService
              .getPlaceRating(r.name, r.latitude, r.longitude)
              .catchError((_) => (rating: null, reviewCount: null)),
        );
        final ratings = await Future.wait(ratingFutures);
        results = [
          for (var i = 0; i < results.length; i++)
            results[i].withGoogleRating(
              googleRating: ratings[i].rating,
              googleReviewCount: ratings[i].reviewCount,
            ),
        ];
      }

      // Sort by combined rating descending
      results.sort((a, b) => b.combinedRating.compareTo(a.combinedRating));

      // Build map markers
      final markers = <Marker>{};
      for (var i = 0; i < results.length; i++) {
        final r = results[i];
        if (r.latitude == 0 && r.longitude == 0) continue;
        markers.add(
          Marker(
            markerId: MarkerId('restaurant_$i'),
            position: LatLng(r.latitude, r.longitude),
            infoWindow: InfoWindow(
              title: r.name,
              snippet:
                  '${r.combinedRating.toStringAsFixed(1)} ★  •  Tap for details',
              onTap: () => _navigateToDetail(r),
            ),
            onTap: () {
              setState(() => _selectedRestaurant = r);
            },
          ),
        );
      }

      setState(() {
        _restaurants = results;
        _markers = markers;
        _isLoading = false;
      });
    } on LocationServiceException catch (e) {
      setState(() {
        _errorMessage = '📍 ${e.message}';
        _isLoading = false;
      });
    } on PlacesServiceException catch (e) {
      setState(() {
        _errorMessage = '🔍 ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '⚠️ Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openYelpUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToDetail(Restaurant restaurant) {
    if (restaurant.yelpId != null && _yelpApiKey.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(
            restaurant: restaurant,
            yelpApiKey: _yelpApiKey,
            placesApiKey: _placesApiKey,
          ),
        ),
      );
    } else if (restaurant.yelpUrl != null) {
      _openYelpUrl(restaurant.yelpUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuisineColor = widget.cuisine.color;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigation row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          '← Change dish',
                          style: TextStyle(
                            color: cuisineColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: cuisineColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: cuisineColor.withValues(alpha: 0.30),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 14,
                                color: cuisineColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Spin again',
                                style: TextStyle(
                                  color: cuisineColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    widget.dishType,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: Color(0xFFAAAAAA),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'Near you',
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCCCCC),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Yelp + Google',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // View toggle (only show when results loaded)
                  if (!_isLoading && _restaurants.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildViewToggle(cuisineColor),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Body
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(Color cuisineColor) {
    return Row(
      children: [
        _ToggleButton(
          icon: Icons.list_rounded,
          label: 'List',
          selected: _viewMode == _ViewMode.list,
          color: cuisineColor,
          onTap: () => setState(() => _viewMode = _ViewMode.list),
        ),
        const SizedBox(width: 8),
        _ToggleButton(
          icon: Icons.map_rounded,
          label: 'Map',
          selected: _viewMode == _ViewMode.map,
          color: cuisineColor,
          onTap: () => setState(() => _viewMode = _ViewMode.map),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: widget.cuisine.color,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Finding great spots...',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadRestaurants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🍽️',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'No restaurants found nearby.\nTry a different dish type.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Change dish'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF666666),
                      side: const BorderSide(color: Color(0xFFCCCCCC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Spin again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return _viewMode == _ViewMode.list ? _buildListView() : _buildMapView();
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _restaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
          rank: index + 1,
          onTap: () => _navigateToDetail(restaurant),
          onYelpTap: restaurant.yelpUrl != null
              ? () => _openYelpUrl(restaurant.yelpUrl!)
              : null,
        );
      },
    );
  }

  Widget _buildMapView() {
    if (_restaurants.isEmpty) return const SizedBox.shrink();

    final first = _restaurants.first;
    final initialTarget = LatLng(first.latitude, first.longitude);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: 13.5,
          ),
          markers: _markers,
          onMapCreated: (controller) => _mapController = controller,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onTap: (_) => setState(() => _selectedRestaurant = null),
        ),
        // Selected restaurant card at bottom
        if (_selectedRestaurant != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildMapCard(_selectedRestaurant!),
          ),
      ],
    );
  }

  Widget _buildMapCard(Restaurant r) {
    return GestureDetector(
      onTap: () => _navigateToDetail(r),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: r.imageUrl != null && r.imageUrl!.isNotEmpty
                    ? Image.network(
                        r.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _mapCardPlaceholder(),
                      )
                    : _mapCardPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 15, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        r.combinedRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${r.combinedReviewCount} reviews)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    r.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF777777),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCCCCCC), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _mapCardPlaceholder() {
    return Container(
      color: const Color(0xFFF5EDE4),
      child: const Center(
        child: Text('🍽️', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15, color: selected ? Colors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
