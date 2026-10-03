import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapEmbed extends StatefulWidget {
  const MapEmbed({super.key});

  @override
  State<MapEmbed> createState() => MapEmbedState();
}

class LocalSugestao {
  final String nome;
  final double latitude;
  final double longitude;

  const LocalSugestao({
    required this.nome,
    required this.latitude,
    required this.longitude,
  });
}

class MapEmbedState extends State<MapEmbed> {
  final MapController _mapController = MapController();

  LatLng? _currentPosition;

  bool _isLoadingLocation = false;
  String? _locationError;

  Future<void>? _locationRequest;

  Future<vt.Style>? _styleFuture;
  vt.Style? _style;

  // Posição usada quando ainda não foi possível obter a localização.
  // Santa Bárbara d'Oeste - SP
  static const LatLng _fallbackLocation = LatLng(-22.7542, -47.4147);

  @override
  void initState() {
    super.initState();

    _styleFuture = const vt.StyleReader(
      uri: 'https://tiles.openfreemap.org/styles/liberty',
    ).read().timeout(const Duration(seconds: 15));

    // Tenta obter a localização sem impedir o mapa de carregar.
    _determinePosition();
  }

  // ============================================================
  // LOCALIZAÇÃO
  // ============================================================

  Future<void> _determinePosition() {
    // Se já existe uma requisição acontecendo,
    // retorna a mesma Future em vez de iniciar outra.
    if (_locationRequest != null) {
      return _locationRequest!;
    }

    final request = _fetchLocation();

    _locationRequest = request;

    request.whenComplete(() {
      if (identical(_locationRequest, request)) {
        _locationRequest = null;
      }
    });

    return request;
  }

  Future<void> _fetchLocation() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final location = LatLng(position.latitude, position.longitude);

      debugPrint('LOCATION: ${position.latitude}, ${position.longitude}');

      debugPrint('ACCURACY: ${position.accuracy}m');

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = location;
        _isLoadingLocation = false;
        _locationError = null;
      });
    } catch (e, stack) {
      debugPrint('LOCATION ERROR: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Não foi possível obter sua localização.';
      });
    }
  }

  // ============================================================
  // BOTÃO DE CENTRALIZAR LOCALIZAÇÃO
  // ============================================================

  Future<void> centralizarLocalizacao() async {
    try {
      // Se já temos a localização, centraliza imediatamente.
      if (_currentPosition != null) {
        if (!mounted) {
          return;
        }

        _moverMapaParaLocalizacao();
        return;
      }

      // Caso ainda não tenhamos localização,
      // espera a requisição atual terminar.
      await _determinePosition();

      if (!mounted) {
        return;
      }

      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _locationError ?? 'Não foi possível obter sua localização.',
            ),
          ),
        );

        return;
      }

      _moverMapaParaLocalizacao();
    } catch (e, stack) {
      debugPrint('CENTRALIZAR LOCALIZAÇÃO ERROR: $e');

      debugPrintStack(stackTrace: stack);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível acessar sua localização.'),
        ),
      );
    }
  }

  void _moverMapaParaLocalizacao() {
    if (!mounted || _currentPosition == null) {
      return;
    }

    final location = _currentPosition!;

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
  }

  // ============================================================
  // PESQUISA DE LOCAL
  // ============================================================
  Future<List<LocalSugestao>> buscarSugestoes(String consulta) async {
    final texto = consulta.trim();

    if (texto.isEmpty) {
      return [];
    }

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': texto,
        'format': 'jsonv2',
        'limit': '5',
        'addressdetails': '1',
      });

      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'ConPort/1.0'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro na pesquisa: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map<LocalSugestao?>((resultado) {
            final latitude = double.tryParse(
              resultado['lat']?.toString() ?? '',
            );

            final longitude = double.tryParse(
              resultado['lon']?.toString() ?? '',
            );

            if (latitude == null || longitude == null) {
              return null;
            }

            final nome = resultado['display_name']?.toString();

            if (nome == null || nome.isEmpty) {
              return null;
            }

            return LocalSugestao(
              nome: nome,
              latitude: latitude,
              longitude: longitude,
            );
          })
          .whereType<LocalSugestao>()
          .toList();
    } catch (e, stack) {
      debugPrint('SUGGESTIONS ERROR: $e');
      debugPrintStack(stackTrace: stack);

      return [];
    }
  }

  Future<void> pesquisarLocal(String consulta) async {
    final sugestoes = await buscarSugestoes(consulta);

    if (sugestoes.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Local não encontrado.')));

      return;
    }

    final local = sugestoes.first;

    if (!mounted) {
      return;
    }

    _mapController.move(LatLng(local.latitude, local.longitude), 16);
  }

  void irParaLocal(LocalSugestao sugestao) {
    _mapController.move(LatLng(sugestao.latitude, sugestao.longitude), 16);
  }

  // ============================================================
  // DESCARTAR
  // ============================================================

  @override
  void dispose() {
    _style?.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FutureBuilder<vt.Style>(
      future: _styleFuture,
      builder: (context, snapshot) {
        // --------------------------------------------------------
        // CARREGANDO MAPA
        // --------------------------------------------------------

        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // --------------------------------------------------------
        // ERRO AO CARREGAR MAPA
        // --------------------------------------------------------

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Não foi possível carregar o mapa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                          uri: 'https://tiles.openfreemap.org/styles/liberty',
                        ).read().timeout(const Duration(seconds: 15));
                      });
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        // --------------------------------------------------------
        // ESTILO DO MAPA
        // --------------------------------------------------------

        final style = snapshot.data!;

        _style ??= style;

        // Se a localização ainda não chegou,
        // utiliza Santa Bárbara d'Oeste como posição inicial.
        final center = _currentPosition ?? style.center ?? _fallbackLocation;

        // --------------------------------------------------------
        // MAPA
        // --------------------------------------------------------

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
                // ------------------------------------------------
                // CAMADA DO MAPA
                // ------------------------------------------------
                vt.VectorTileLayer(
                  theme: style.theme,
                  tileProviders: style.providers,
                  rasterSources: style.rasterSources,
                  sprites: style.sprites,
                ),

                // ------------------------------------------------
                // MARCADOR DA LOCALIZAÇÃO
                // ------------------------------------------------
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: colors.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),

                // ------------------------------------------------
                // ATRIBUIÇÃO
                // ------------------------------------------------
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

            // ----------------------------------------------------
            // INDICADOR DE LOCALIZAÇÃO
            // ----------------------------------------------------
            if (_isLoadingLocation)
              const Positioned(
                top: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
