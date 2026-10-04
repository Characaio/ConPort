import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:conport/core/conquistas/conquistas.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:conport/pages/avistamento.dart';
import 'package:conport/services/reportService.dart';
import 'package:conport/widgets/dicas_do_tipo.dart';
import 'package:conport/widgets/topbar.dart';

class Report extends StatefulWidget {
  /// Permite trocar o seletor de anexos (usado nos testes).
  /// Por padrão usa o mesmo seletor de imagem do "Enviar Avistamento".
  final Future<XFile?> Function(BuildContext context)? seletorDeImagem;

  const Report({super.key, this.seletorDeImagem});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final ReportService _reportService = ReportService();
  double urgencia = 0.5;
  String tipoSelecionado = 'QUEIMADA';

  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _localController = TextEditingController();

  /// Anexos selecionados para o report (imagens).
  final List<XFile> _anexos = [];

  /// Trava o botão enquanto o report está sendo enviado.
  bool _enviando = false;

  // ==========================================
  // ANEXOS
  // ==========================================

  Future<void> _adicionarAnexo() async {
    final seletor = widget.seletorDeImagem ?? escolherImagem;

    final anexo = await seletor(context);

    if (anexo == null || !mounted) return;

    setState(() => _anexos.add(anexo));
  }

  void _removerAnexo(XFile anexo) {
    setState(() => _anexos.remove(anexo));
  }

  Widget _caixaDoAnexo(int indice) {
    final anexo = _anexos[indice];

    return _CaixaAnexo(anexo: anexo, onRemover: () => _removerAnexo(anexo));
  }

  Future<void> _enviarReport() async {
    // O report precisa sair em nome de quem está logado: mandar um id fixo
    // fazia ele não aparecer na lista de quem enviou.
    final usuario = AuthSession.instance.usuario;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entre na sua conta para enviar um report.'),
        ),
      );
      return;
    }

    const int unidadeId = 1;

    setState(() => _enviando = true);

    // A localização vem da escolha feita na tela, se houver.
    final local = _localSelecionado;

    try {
      await _reportService.postarReport(
        unidadeId: unidadeId,
        usuarioId: usuario.id,
        tipo: tipoSelecionado,
        descricao: _descricaoController.text,
        urgencia: urgencia,
        dataDoOcorrido: DateTime.now(),
        latitude: local?.latitude,
        longitude: local?.longitude,
        imagens: _anexos,
      );

      if (!mounted) return;

      await registrarConquista(context, TipoConquista.reportEnviado);

      if (!mounted) return;

      PageLoader.go(context, PageLoader.myreports);
    } catch (e) {
      if (!mounted) return;

      // Fica na tela para a pessoa corrigir, em vez de sumir com o erro.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar Report: $e')));
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  Timer? _localSearchDebounce;

  List<LocalSugestao> _localSugestoes = [];

  bool _pesquisandoLocal = false;
  bool _obtendoLocalizacao = false;

  LocalSugestao? _localSelecionado;

  // ==========================================
  // LOCALIZAÇÃO ATUAL
  // ==========================================

  Future<void> _usarLocalizacaoAtual() async {
    if (_obtendoLocalizacao) return;

    setState(() => _obtendoLocalizacao = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Ative o serviço de localização do dispositivo.');
      }

      var permissao = await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }

      if (permissao == LocationPermission.deniedForever) {
        throw Exception(
          'Permissão de localização bloqueada. Habilite-a nas configurações.',
        );
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final local = await _buscarEnderecoPorCoordenadas(
        posicao.latitude,
        posicao.longitude,
      );

      if (!mounted) return;

      if (local != null) {
        _selecionarLocal(local);
      } else {
        final coordenadas =
            posicao.latitude.toStringAsFixed(6) +
            ', ' +
            posicao.longitude.toStringAsFixed(6);

        _localController.text = coordenadas;
        _localSelecionado = LocalSugestao(
          nome: coordenadas,
          latitude: posicao.latitude,
          longitude: posicao.longitude,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _obtendoLocalizacao = false);
      }
    }
  }

  Future<LocalSugestao?> _buscarEnderecoPorCoordenadas(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'jsonv2',
        'addressdetails': '1',
        'zoom': '18',
      });

      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'ConPort/1.0'},
      );

      if (response.statusCode != 200) return null;

      final resultado = jsonDecode(response.body);

      if (resultado is! Map) return null;

      final nome = resultado['display_name']?.toString();

      if (nome == null || nome.isEmpty) return null;

      return LocalSugestao(
        nome: nome,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('LOCAL REVERSE ERROR: $e');
      return null;
    }
  }

  // ==========================================
  // BUSCAR SUGESTÕES
  // ==========================================

  void _buscarSugestoesLocal(String texto) {
    _localSearchDebounce?.cancel();

    // Se o campo estiver vazio, limpa as sugestões.
    if (texto.trim().isEmpty) {
      setState(() {
        _localSugestoes = [];
        _pesquisandoLocal = false;
        _localSelecionado = null;
      });

      return;
    }

    setState(() {
      _pesquisandoLocal = true;
      _localSelecionado = null;
    });

    _localSearchDebounce = Timer(const Duration(milliseconds: 400), () async {
      final resultados = await _pesquisarLocal(texto);

      if (!mounted) {
        return;
      }

      setState(() {
        _localSugestoes = resultados;
        _pesquisandoLocal = false;
      });
    });
  }

  // ==========================================
  // CONSULTA NOMINATIM
  // ==========================================

  Future<List<LocalSugestao>> _pesquisarLocal(String consulta) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': consulta.trim(),
        'format': 'jsonv2',
        'limit': '5',
        'addressdetails': '1',
      });

      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'ConPort/1.0'},
      );

      if (response.statusCode != 200) {
        debugPrint('Erro Nominatim: ${response.statusCode}');

        return [];
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

            final nome = resultado['display_name']?.toString();

            if (latitude == null ||
                longitude == null ||
                nome == null ||
                nome.isEmpty) {
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
    } catch (e) {
      debugPrint('LOCAL SEARCH ERROR: $e');

      return [];
    }
  }

  // ==========================================
  // SELECIONAR LOCAL
  // ==========================================

  void _selecionarLocal(LocalSugestao sugestao) {
    setState(() {
      _localSelecionado = sugestao;
      _localController.text = sugestao.nome;
      _localSugestoes = [];
    });

    debugPrint('Local selecionado: ${sugestao.nome}');

    debugPrint('Latitude: ${sugestao.latitude}');

    debugPrint('Longitude: ${sugestao.longitude}');
  }

  // ==========================================
  // ENVIAR PESQUISA PELO TECLADO
  // ==========================================

  Future<void> _pesquisarLocalAoEnviar(String texto) async {
    _localSearchDebounce?.cancel();

    if (texto.trim().isEmpty) {
      return;
    }

    setState(() {
      _pesquisandoLocal = true;
    });

    final resultados = await _pesquisarLocal(texto);

    if (!mounted) {
      return;
    }

    setState(() {
      _pesquisandoLocal = false;
    });

    if (resultados.isNotEmpty) {
      _selecionarLocal(resultados.first);
    }
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    _localSearchDebounce?.cancel();

    _descricaoController.dispose();
    _localController.dispose();

    super.dispose();
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Topbar(hasLogo: false, hasReturn: true, text: 'Criar Report'),

                const SizedBox(height: 20),

                // ==========================================
                // O QUE ACONTECEU?
                // ==========================================
                const Text('O que aconteceu?'),

                const SizedBox(height: 6),

                DropdownMenu<String>(
                  width: double.infinity,
                  // Os valores são os mesmos enviados ao backend.
                  initialSelection: tipoSelecionado,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'QUEIMADA', label: 'Queimada'),
                    DropdownMenuEntry(
                      value: 'ANIMAL_FERIDO',
                      label: 'Animal Ferido',
                    ),
                    DropdownMenuEntry(
                      value: 'ANIMAL_EXOTICO',
                      label: 'Animal Exótico',
                    ),
                    DropdownMenuEntry(value: 'POLUICAO', label: 'Poluição'),
                    DropdownMenuEntry(
                      value: 'DESMATAMENTO',
                      label: 'Desmatamento',
                    ),
                  ],
                  onSelected: (value) {
                    if (value != null) {
                      setState(() {
                        tipoSelecionado = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // ==========================================
                // DESCRIÇÃO
                // ==========================================
                const Text('Descrição'),

                const SizedBox(height: 6),

                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 100),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _descricaoController,
                        maxLines: 5,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Descreva o que aconteceu...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(4),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 72,
                              child: _anexos.isNotEmpty
                                  ? SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.zero,
                                      child: Row(
                                        children: [
                                          for (
                                            var i = 0;
                                            i < _anexos.length;
                                            i++
                                          ) ...[
                                            if (i > 0) const SizedBox(width: 8),
                                            _caixaDoAnexo(i),
                                          ],
                                        ],
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ),

                          const SizedBox(width: 8),

                          IconButton(
                            tooltip: 'Adicionar anexo',
                            onPressed: _adicionarAnexo,
                            icon: const Icon(Icons.attach_file, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ==========================================
                // LOCAL
                // ==========================================
                const Text('Local'),

                const SizedBox(height: 6),

                TextField(
                  controller: _localController,
                  textInputAction: TextInputAction.search,
                  onChanged: _buscarSugestoesLocal,
                  onSubmitted: _pesquisarLocalAoEnviar,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar local...',
                    prefixIcon: _pesquisandoLocal
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Usar localização atual',
                            onPressed: _usarLocalizacaoAtual,
                            icon: _obtendoLocalizacao
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),

                // ==========================================
                // SUGESTÕES
                // ==========================================
                if (_localSugestoes.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _localSugestoes.length,
                      separatorBuilder: (context, index) {
                        return Divider(height: 1, color: Colors.grey.shade300);
                      },
                      itemBuilder: (context, index) {
                        final sugestao = _localSugestoes[index];

                        return InkWell(
                          onTap: () {
                            _selecionarLocal(sugestao);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    size: 20,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    sugestao.nome,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 14),

                // ==========================================
                // URGÊNCIA
                // ==========================================
                const Text('O quão urgente é o ocorrido'),

                const SizedBox(height: 4),

                Slider(
                  value: urgencia,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    setState(() {
                      urgencia = value;
                    });
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Pouco', style: TextStyle(fontSize: 15)),
                    Text('Muito', style: TextStyle(fontSize: 15)),
                  ],
                ),

                const SizedBox(height: 14),

                // ==========================================
                // DICAS E VÍDEOS DO TIPO ESCOLHIDO
                // ==========================================
                DicasDoTipo(tipo: tipoSelecionado),

                const SizedBox(height: 14),

                // ==========================================
                // BOTÕES
                // ==========================================
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _enviando ? null : _enviarReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(_enviando ? 'Enviando...' : 'Enviar'),
                      ),
                    ),

                    const SizedBox(width: 48),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          PageLoader.go(context, PageLoader.home);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
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

// ============================================================
// ANEXOS
// ============================================================

/// Caixa exibida enquanto o report não tem anexos, só para indicar
/// onde as imagens vão aparecer.
class _CaixaAnexoVazia extends StatelessWidget {
  const _CaixaAnexoVazia();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Uma caixa de anexo: preview da imagem e botão para removê-la.
class _CaixaAnexo extends StatefulWidget {
  final XFile anexo;
  final VoidCallback onRemover;

  const _CaixaAnexo({required this.anexo, required this.onRemover});

  @override
  State<_CaixaAnexo> createState() => _CaixaAnexoState();
}

class _CaixaAnexoState extends State<_CaixaAnexo> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _carregarBytes();
  }

  // Usar bytes (em vez de File) faz o preview funcionar também na web.
  Future<void> _carregarBytes() async {
    try {
      final bytes = await widget.anexo.readAsBytes();

      if (!mounted) return;

      setState(() => _bytes = bytes);
    } catch (e) {
      debugPrint('ANEXO PREVIEW ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _bytes == null
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Image.memory(_bytes!, fit: BoxFit.cover),
            ),
          ),

          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onRemover,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
