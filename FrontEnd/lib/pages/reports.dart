import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/services/reportService.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final ReportService _reportService = ReportService();

  final TextEditingController localController =
      TextEditingController();

  final TextEditingController descricaoController =
      TextEditingController();

  String opcaoSelecionada = '1';

  List<String> anexosSelecionados = [];

  bool enviando = false;

  @override
  void dispose() {
    localController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  // ============================================================
  // ENVIAR REPORT
  // ============================================================

  Future<void> _enviarReport() async {
    final descricao = descricaoController.text.trim();

    if (descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informe uma descrição para o ocorrido',
          ),
        ),
      );
      return;
    }

    final tipos = {
      '1': 'Queimada',
      '2': 'Animal Ferido',
      '3': 'Desmatamento',
      '4': 'Animal Exótico',
      '5': 'Poluição',
    };

    final tipo = tipos[opcaoSelecionada];

    if (tipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione um tipo de ocorrência',
          ),
        ),
      );
      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      final report = await _reportService.postarReport(
        unidadeId: 1,
        usuarioId: 1,
        tipo: tipo,
        descricao: descricao,
        dataDoOcorrido: DateTime.now(),

        // Por enquanto sem imagem.
        // Depois podemos ligar o upload real.
        caminhosDasImagens: [],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report ${report.id} enviado com sucesso!',
          ),
        ),
      );

      PageLoader.go(
        context,
        PageLoader.myreports,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao enviar report: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  // ============================================================
  // TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 700,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TÍTULO
                  // ==================================================

                  const Text(
                    'Novo Report',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Informe os detalhes da ocorrência.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // TIPO
                  // ==================================================

                  const Text(
                    'Tipo de ocorrência',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: opcaoSelecionada,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: '1',
                            child: Text('Queimada'),
                          ),
                          DropdownMenuItem(
                            value: '2',
                            child: Text('Animal ferido'),
                          ),
                          DropdownMenuItem(
                            value: '3',
                            child: Text('Desmatamento'),
                          ),
                          DropdownMenuItem(
                            value: '4',
                            child: Text('Animal exótico'),
                          ),
                          DropdownMenuItem(
                            value: '5',
                            child: Text('Poluição'),
                          ),
                        ],
                        onChanged: enviando
                            ? null
                            : (value) {
                                if (value == null) return;

                                setState(() {
                                  opcaoSelecionada = value;
                                });
                              },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // LOCAL
                  // ==================================================

                  const Text(
                    'Local da ocorrência',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: localController,
                    enabled: !enviando,
                    decoration: InputDecoration(
                      hintText: 'Informe o local da ocorrência',
                      prefixIcon: const Icon(
                        Symbols.location_on,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // DESCRIÇÃO
                  // ==================================================

                  const Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: descricaoController,
                    enabled: !enviando,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText:
                          'Descreva o que aconteceu...',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // ANEXOS
                  // ==================================================

                  const Text(
                    'Anexos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: enviando
                          ? null
                          : () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Upload de imagens será conectado em seguida.',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(
                        Symbols.attach_file,
                      ),
                      label: const Text(
                        'Adicionar anexos',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // BOTÃO ENVIAR
                  // ==================================================

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          enviando ? null : _enviarReport,
                      icon: enviando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Symbols.send,
                            ),
                      label: Text(
                        enviando
                            ? 'Enviando...'
                            : 'Enviar report',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        backgroundColor:
                            const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}