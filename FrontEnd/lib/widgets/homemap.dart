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

  bool _isLoadingLocation = false;

  String? _locationError;

  Future<vt.Style>? _styleFuture;

  vt.Style? _style;

  // Posição usada caso não seja possível pegar a localização.
  // Santa Bárbara d'Oeste - SP
  static const LatLng _fallbackLocation =
      LatLng(-22.7542, -47.4147);

  @override
  void initState() {
    super.initState();

    _styleFuture = const vt.StyleReader(
      uri: 'https://tiles.openfreemap.org/styles/liberty',
    ).read().timeout(
      const Duration(seconds: 15),
    );

    // A localização NÃO bloqueia mais o carregamento do mapa.
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    if (_isLoadingLocation) {
      return;
    }

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      debugPrint(
        'LOCATION: ${position.latitude}, ${position.longitude}',
      );

      debugPrint(
        'ACCURACY: ${position.accuracy}m',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = location;
        _isLoadingLocation = false;
        _locationError = null;
      });

      // Só move o mapa depois que ele estiver montado.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        try {
          _mapController.move(location, 15);
        } catch (e) {
          debugPrint('MAP MOVE ERROR: $e');
        }
      });
    } catch (e, stack) {
      debugPrint('LOCATION ERROR: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) {
        return;
      }

      // IMPORTANTE:
      // Falha na localização NÃO impede o mapa de aparecer.
      setState(() {
        _isLoadingLocation = false;
        _locationError =
            'Não foi possível obter sua localização.';
      });
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
        // Ainda carregando o estilo do mapa.
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Não conseguiu baixar o estilo.
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 48,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Não foi possível carregar o mapa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Verifique sua conexão com a internet.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _styleFuture = const vt.StyleReader(
                          uri:
                              'https://tiles.openfreemap.org/styles/liberty',
                        ).read().timeout(
                          const Duration(seconds: 15),
                        );
                      });
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final style = snapshot.data!;

        _style ??= style;

        // Se ainda não conseguiu localização,
        // usa a posição padrão.
        final center =
            _currentPosition ??
            style.center ??
            _fallbackLocation;

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

                // Marcador da localização real.
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
                          color: colors.surface.withValues(
                            alpha: 0.75,
                          ),
                          borderRadius:
                              BorderRadius.circular(4),
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

            // Botão de localização.
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: _determinePosition,
                child: _isLoadingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.my_location,
                        color: colors.primary,
                      ),
              ),
            ),        
          ],
        );
      },
    );
  }
}

