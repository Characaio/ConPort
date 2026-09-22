import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class HomeMap extends StatefulWidget {
  const HomeMap({super.key});

  @override
  State<HomeMap> createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  final MapController _mapController = MapController();

  LatLng? _currentPosition;

  bool _isLoading = true;
  String? _errorMessage;

  Future<vt.Style>? _styleFuture;
  vt.Style? _style;

  static const LatLng _fallbackLocation = LatLng(40.7128, -74.0060);

  @override
  void initState() {
    super.initState();

    _styleFuture = const vt.StyleReader(
      uri: 'https://tiles.openfreemap.org/styles/liberty',
    ).read();

    _determinePosition();
  }

  Future<void> _determinePosition() async {
    if (kIsWeb) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Permissão de localização negada: $permission');
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: WebSettings(
            accuracy: LocationAccuracy.high,
            maximumAge: Duration(minutes: 5),
            timeLimit: Duration(seconds: 45),
          ),
        );

        final location = LatLng(position.latitude, position.longitude);

        debugPrint('LOCATION: ${position.latitude}, ${position.longitude}');
        debugPrint('ACCURACY: ${position.accuracy}m');

        if (!mounted) return;

        setState(() {
          _currentPosition = location;
          _isLoading = false;
          _errorMessage = null;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(location, 15);
          }
        });

        return;
      } catch (e, stack) {
        debugPrint('LOCATION ERROR: $e');
        debugPrintStack(stackTrace: stack);

        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage = 'Não foi possível obter sua localização:\n$e';
        });

        return;
      }
    }
  }

  @override
  void dispose() {
    _style?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<vt.Style>(
      future: _styleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar o mapa:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final style = snapshot.data!;

        _style ??= style;

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_errorMessage != null) {
          return Center(child: Text(_errorMessage!));
        }

        final center = _currentPosition ?? style.center ?? _fallbackLocation;

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15,
                minZoom: 2,
                maxZoom: 21,
              ),
              children: [
                vt.VectorTileLayer(
                  theme: style.theme,
                  tileProviders: style.providers,
                  rasterSources: style.rasterSources,
                  sprites: style.sprites,
                ),

                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),

                if (style.attributions.isNotEmpty)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '© OpenFreeMap · OpenStreetMap',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () {
                  _determinePosition();
                },
                child: Icon(Icons.my_location, color: colors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
