import 'dart:async';
import 'dart:convert';

import 'package:conport/core/navigation/page_loader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:conport/services/reportService.dart';
import 'package:conport/widgets/topbar.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final ReportService _reportService = ReportService();
  double urgencia = 0.5;
  String tipoSelecionado = 'QUEIMADA';

  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  
  Future<void> _enviarReport() async{
    const int usuarioId = 2;
    const int unidadeId = 1;

    try{
      await _reportService.postarReport(
        unidadeId: unidadeId,
        usuarioId: usuarioId,
        tipo: tipoSelecionado,
        descricao: _descricaoController.text,
        prioridade: (urgencia * 5).round(),
        dataDoOcorrido: DateTime.now(),
      );
      if(!mounted) return;

      PageLoader.go(context, PageLoader.myreports);

    }catch (e){
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar Report: $e'),),
        );
    }
  }
 
  Timer? _localSearchDebounce;

  List<LocalSugestao> _localSugestoes = [];

  bool _pesquisandoLocal = false;

  LocalSugestao? _localSelecionado;

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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  initialSelection: 'queimada',
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'queimada', label: 'Queimada'),
                    DropdownMenuEntry(
                      value: 'animal_ferido',
                      label: 'Animal Ferido',
                    ),
                    DropdownMenuEntry(
                      value: 'animal_exotico',
                      label: 'Animal Exótico',
                    ),
                    DropdownMenuEntry(value: 'poluicao', label: 'Poluição'),
                    DropdownMenuEntry(
                      value: 'desmatamento',
                      label: 'Desmatamento',
                    ),
                  ],
                  onSelected: (value) {
                    if(value !=null){
                      setState(() {
                        tipoSelecionado = value.toUpperCase();
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
                  constraints: const BoxConstraints(minHeight: 170),
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
                        minLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Descreva o que aconteceu...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          const Spacer(),

                          const Icon(Icons.attach_file, size: 18),
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
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: _pesquisandoLocal
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
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
                // INFORMAÇÕES
                // ==========================================
                const Text('Veja o que se fazer referente a queimadas:'),

                const SizedBox(height: 2),

                const Text(
                  'Lorem ipsum dolor sit amet, consectetur '
                  'adipiscing elit. Nunc commodo turpis leo, '
                  'ut fringilla lorem posuere a. Mauris ut '
                  'tellus in justo venenatis tristique '
                  'efficitur sit amet metus.',
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 8),

                Container(
                  height: 145,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.videocam_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ==========================================
                // BOTÕES
                // ==========================================
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:_enviarReport,                   
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Enviar'),
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

