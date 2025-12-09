import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/landmark_provider.dart';
import '../models/landmark.dart';
import '../widgets/landmark_bottom_sheet.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LandmarkProvider>().fetchLandmarks();
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please enable location services'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () {
                    Geolocator.openLocationSettings();
                  },
                ),
              ),
            );
          }
          return;
        }

        // Check if permission is precise location
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        // Get current position with best accuracy
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          timeLimit: const Duration(seconds: 10),
        );

        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        _mapController.move(_currentLocation!, 15.0);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}\nAccuracy: ${position.accuracy.toStringAsFixed(1)}m',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                'This app needs location permission to show your current position on the map. Please enable it in app settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e\nMake sure GPS is enabled and you\'re outdoors for better accuracy.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showLandmarkDetails(Landmark landmark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LandmarkBottomSheet(landmark: landmark),
    );
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmark Overview'),
        actions: [
          Consumer<LandmarkProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: provider.isOnline ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.isOnline ? 'Online' : 'Offline - Showing cached data',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LandmarkProvider>().fetchLandmarks();
            },
          ),
        ],
      ),
      body: Consumer<LandmarkProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.landmarks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final landmarks = provider.landmarks;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(23.6850, 90.3563),
                  initialZoom: 7.0,
                  minZoom: 3.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.cse489.landmarkapp',
                  ),
                  MarkerLayer(
                    markers: [
                      // Current location marker
                      if (_currentLocation != null)
                        Marker(
                          point: _currentLocation!,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ),
                      // Landmark markers
                      ...landmarks.map((landmark) {
                        return Marker(
                          point: LatLng(landmark.lat, landmark.lon),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showLandmarkDetails(landmark),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
              if (provider.isLoading)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Loading landmarks...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (landmarks.isEmpty && !provider.isLoading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No landmarks found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first landmark!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              // Zoom Controls
              Positioned(
                right: 16,
                top: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      onPressed: _zoomIn,
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      onPressed: _zoomOut,
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'my_location',
            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
            child: _isLoadingLocation
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'center_bangladesh',
            onPressed: () {
              _mapController.move(const LatLng(23.6850, 90.3563), 7.0);
            },
            child: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }
}