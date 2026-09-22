import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/widgets/topbar.dart';

class UnidadeData {
  // Dados básicos
  final String nome;
  final String horario;
  final String telefone;
  final int incidentes;
  final bool unidadePesquisa;

  // Território
  final double areaTotal;
  final double areaRegularizada;
  final double areaMonitorada;
  final double integridadeTerritorial;

  // Preservação
  final double areaPreservada;
  final double preservacaoLocal;

  // Fiscalização
  final int pontosMonitorados;
  final int pontosPrevistos;
  final double fiscalizacao;

  // Conectividade ecológica
  final double areaBasePorCorredor;
  final int quantCorredores;
  final int corredoresNecessarios;
  final double conectividadeEcologica;

  // Biodiversidade
  final int quantEspecies;
  final int quantEspeciesEsperadas;
  final double biodiversidade;

  // Qualidade ambiental
  final double qualidadeAgua;
  final double qualidadeSolo;
  final double gestaoResiduos;
  final double qualidadeAmbiental;

  // Fotos
  final List<String> fotos;

  const UnidadeData({
    required this.nome,
    required this.horario,
    required this.telefone,
    required this.incidentes,
    required this.unidadePesquisa,

    required this.areaTotal,
    required this.areaRegularizada,
    required this.areaMonitorada,
    required this.integridadeTerritorial,

    required this.areaPreservada,
    required this.preservacaoLocal,

    required this.pontosMonitorados,
    required this.pontosPrevistos,
    required this.fiscalizacao,

    required this.areaBasePorCorredor,
    required this.quantCorredores,
    required this.corredoresNecessarios,
    required this.conectividadeEcologica,

    required this.quantEspecies,
    required this.quantEspeciesEsperadas,
    required this.biodiversidade,

    required this.qualidadeAgua,
    required this.qualidadeSolo,
    required this.gestaoResiduos,
    required this.qualidadeAmbiental,

    required this.fotos,
  });
}

// Mock
final UnidadeData unidadeMock = UnidadeData(
  nome: 'Unidade de Conservação X',

  horario: 'Aberto até 21:00',
  telefone: '(19) 99999-9999',
  incidentes: 7,
  unidadePesquisa: true,

  // Território
  areaTotal: 67,
  areaRegularizada: 64,
  areaMonitorada: 42,
  integridadeTerritorial: 67,

  // Preservação
  areaPreservada: 40,
  preservacaoLocal: 59,

  // Fiscalização
  pontosMonitorados: 8,
  pontosPrevistos: 12,
  fiscalizacao: 75,

  // Conectividade
  areaBasePorCorredor: 10,
  quantCorredores: 3,
  corredoresNecessarios: 5,
  conectividadeEcologica: 69,

  // Biodiversidade
  quantEspecies: 82,
  quantEspeciesEsperadas: 100,
  biodiversidade: 82,

  // Qualidade ambiental
  qualidadeAgua: 78,
  qualidadeSolo: 84,
  gestaoResiduos: 71,
  qualidadeAmbiental: 78,

  fotos: [
    'https://images.unsplash.com/photo-1448375240586-882707db888b',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e',
    'https://images.unsplash.com/photo-1511497584788-876760111969',
  ],
);

// Página
class UnidadeDetalhes extends StatelessWidget {
  final UnidadeData unidade;

  const UnidadeDetalhes({super.key, required this.unidade});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Topbar(
                hasLogo: false,
                hasReturn: true,
                text: "Detalhes da unidade",
              ),

              const SizedBox(height: 20),

              // =================================================
              // NOME DA UNIDADE
              // =================================================
              Text(
                unidade.nome,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 14),

              // =================================================
              // FOTOS
              // =================================================
              _PhotoGallery(fotos: unidade.fotos),

              const SizedBox(height: 14),

              // =================================================
              // INDICADORES PRINCIPAIS
              // =================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _Indicator(
                          icon: Symbols.schedule,
                          text: unidade.horario,
                        ),

                        _Indicator(icon: Symbols.call, text: unidade.telefone),

                        _Indicator(
                          icon: Symbols.heart_check,
                          text:
                              'Integridade: ${_percent(unidade.integridadeTerritorial)}',
                        ),

                        _Indicator(
                          icon: Symbols.sync_alt,
                          text:
                              'Conectividade Ecológica: ${_percent(unidade.conectividadeEcologica)}',
                        ),

                        _Indicator(
                          icon: Symbols.siren,
                          text:
                              'Fiscalização: ${_quality(unidade.fiscalizacao)}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      children: [
                        _Indicator(
                          icon: Symbols.nest_eco_leaf,
                          text:
                              'Diversidade: ${_quality(unidade.biodiversidade)}',
                        ),

                        _Indicator(
                          icon: Symbols.cloud_alert,
                          text:
                              'Qualidade Ambiental: ${_quality(unidade.qualidadeAmbiental)}',
                        ),

                        _Indicator(
                          icon: Symbols.forest,
                          text:
                              'Preservação: ${_quality(unidade.preservacaoLocal)}',
                        ),

                        _Indicator(
                          icon: Symbols.emergency_home,
                          text: 'Incidentes: ${unidade.incidentes}',
                        ),

                        _Indicator(
                          icon: Symbols.local_library,
                          text: unidade.unidadePesquisa
                              ? 'Unidade de Pesquisa'
                              : 'Sem pesquisa',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =================================================
              // DIVISOR
              // =================================================
              Row(
                children: [
                  const Expanded(child: Divider()),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Todos os Dados',
                      style: TextStyle(color: colors.onSurface, fontSize: 14),
                    ),
                  ),

                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 8),

              // =================================================
              // TERRITÓRIO
              // =================================================
              _DataSection(
                title: 'Território',
                icon: Symbols.terrain,
                children: [
                  _DataRow('Área total', '${_number(unidade.areaTotal)}km²'),
                  _DataRow(
                    'Área regularizada',
                    '${_number(unidade.areaRegularizada)}km²',
                  ),
                  _DataRow(
                    'Área monitorada',
                    '${_number(unidade.areaMonitorada)}km²',
                  ),
                  _DataRow(
                    'Integridade territorial',
                    _percent(unidade.integridadeTerritorial),
                  ),
                ],
              ),

              // =================================================
              // PRESERVAÇÃO
              // =================================================
              _DataSection(
                title: 'Preservação',
                icon: Symbols.forest,
                children: [
                  _DataRow(
                    'Área preservada',
                    '${_number(unidade.areaPreservada)}km²',
                  ),
                  _DataRow(
                    'Preservação local',
                    _percent(unidade.preservacaoLocal),
                  ),
                ],
              ),

              // =================================================
              // FISCALIZAÇÃO
              // =================================================
              _DataSection(
                title: 'Fiscalização',
                icon: Symbols.siren,
                children: [
                  _DataRow(
                    'Pontos monitorados',
                    '${unidade.pontosMonitorados}',
                  ),
                  _DataRow('Pontos previstos', '${unidade.pontosPrevistos}'),
                  _DataRow('Fiscalização', _percent(unidade.fiscalizacao)),
                ],
              ),

              // =================================================
              // CONECTIVIDADE
              // =================================================
              _DataSection(
                title: 'Conectividade Ecológica',
                icon: Symbols.sync_alt,
                children: [
                  _DataRow(
                    'Corredores necessários',
                    '${unidade.corredoresNecessarios}',
                  ),
                  _DataRow(
                    'Quantidade de corredores',
                    '${unidade.quantCorredores}',
                  ),
                  _DataRow(
                    'Área por corredor',
                    '${_number(unidade.areaBasePorCorredor)}km²',
                  ),
                  _DataRow(
                    'Conectividade ecológica',
                    _percent(unidade.conectividadeEcologica),
                  ),
                ],
              ),

              // =================================================
              // BIODIVERSIDADE
              // =================================================
              _DataSection(
                title: 'Biodiversidade',
                icon: Symbols.nest_eco_leaf,
                children: [
                  _DataRow(
                    'Quantidade de espécies',
                    '${unidade.quantEspecies}',
                  ),
                  _DataRow(
                    'Espécies esperadas',
                    '${unidade.quantEspeciesEsperadas}',
                  ),
                  _DataRow('Biodiversidade', _percent(unidade.biodiversidade)),
                ],
              ),

              // =================================================
              // QUALIDADE AMBIENTAL
              // =================================================
              _DataSection(
                title: 'Qualidade Ambiental',
                icon: Symbols.eco,
                children: [
                  _DataRow(
                    'Qualidade da água',
                    _percent(unidade.qualidadeAgua),
                  ),
                  _DataRow(
                    'Qualidade do solo',
                    _percent(unidade.qualidadeSolo),
                  ),
                  _DataRow(
                    'Gestão de resíduos',
                    _percent(unidade.gestaoResiduos),
                  ),
                  _DataRow(
                    'Qualidade ambiental',
                    _percent(unidade.qualidadeAmbiental),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GALERIA
// ============================================================

class _PhotoGallery extends StatelessWidget {
  final List<String> fotos;

  const _PhotoGallery({required this.fotos});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (fotos.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Icon(Symbols.image, size: 48)),
      );
    }

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          // Foto principal
          Expanded(
            flex: 5,
            child: _Photo(
              url: fotos[0],
              radius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Fotos secundárias
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: _Photo(
                    url: fotos.length > 1 ? fotos[1] : fotos[0],
                    radius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),

                if (fotos.length > 2) ...[
                  const SizedBox(height: 6),

                  Expanded(
                    child: _Photo(
                      url: fotos[2],
                      radius: const BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  final String url;
  final BorderRadius radius;

  const _Photo({required this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: colors.surfaceContainerHighest,
        child: Image.network(
          url,
          fit: BoxFit.cover,

          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Symbols.image,
                size: 40,
                color: colors.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// INDICADOR
// ============================================================

class _Indicator extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Indicator({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),

          const SizedBox(width: 8),

          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}

// ============================================================
// SEÇÃO
// ============================================================

class _DataSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DataSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 21),

              const SizedBox(width: 7),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LINHA DE DADO
// ============================================================

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text('$label: $value', style: const TextStyle(fontSize: 13.5)),
    );
  }
}

// ============================================================
// FORMATADORES
// ============================================================

String _percent(double value) {
  return '${value.toStringAsFixed(0)}%';
}

String _number(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(1);
}

String _quality(double value) {
  if (value >= 80) {
    return 'Alta';
  }

  if (value >= 60) {
    return 'Média';
  }

  return 'Baixa';
}
