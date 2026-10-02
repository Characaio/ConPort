import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/models/unidade.dart';
import 'package:conport/services/unidadeService.dart';
import 'package:conport/widgets/topbar.dart';

class MaisInfo extends StatefulWidget {
  final int unidadeId;
  final UnidadeService unidadeService;

  const MaisInfo({
    super.key,
    required this.unidadeId,
    required this.unidadeService,
  });

  @override
  State<MaisInfo> createState() => _MaisInfoState();
}

class _MaisInfoState extends State<MaisInfo> {
  Unidade? unidade;
  String? erro;

  // TODO: o model Unidade ainda não tem descrição nem fotos.
  // Quando o backend expor esses campos, troque por unidade!.descricao etc.
  static const String _descricaoPadrao =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Nunc commodo turpis leo, ut fringilla lorem posuere a. '
      'Mauris ut tellus in justo venenatis tristique efficitur sit amet metus.';
  static const String _imagem = 'assets/images/araraias.jpg';

  @override
  void initState() {
    super.initState();
    _carregarUnidade();
  }

  Future<void> _carregarUnidade() async {
    try {
      final dados = await widget.unidadeService.buscarStatusGeral(
        widget.unidadeId,
      );
      if (!mounted) return;
      setState(() => unidade = dados);
    } catch (e) {
      if (!mounted) return;
      setState(() => erro = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (erro != null) {
      return Scaffold(body: Center(child: Text(erro!)));
    }

    if (unidade == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final u = unidade!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Topbar(hasLogo: false, hasReturn: true, text: 'Informações'),
              const Divider(),
              const SizedBox(height: 12),

              // Nome e tipo
              Text(
                u.nome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _tipoEmTexto(u.tipoDaUnidade),
                style: const TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 14),

              // Telefone e horário
              Row(
                children: [
                  Expanded(
                    child: _IconeTexto(icon: Symbols.call, text: u.telefone),
                  ),
                  Expanded(
                    child: _IconeTexto(
                      icon: Symbols.schedule,
                      text: u.horaDeFechamento == null
                          ? 'Horário não informado'
                          : 'Aberto até às ${u.horaDeFechamento}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                _descricaoPadrao,
                style: TextStyle(fontSize: 12, height: 1.3),
              ),

              const SizedBox(height: 20),

              // Foto
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 285 / 135,
                    child: Image.asset(_imagem, fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              const Text(
                'Outros Dados',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 14),

              _LinhaDado(
                icon: Symbols.terrain,
                rotulo: 'Área total: ',
                valor: '${_number(u.areaTotal)}km²',
              ),
              _LinhaDado(
                icon: Symbols.local_fire_department,
                rotulo: 'Área comprometida: ',
                // Não existe campo "comprometida" no model. Estou usando
                // total - preservada; ajuste se a regra do backend for outra.
                valor: '${_number(u.areaTotal - u.areaPreservada)}km²',
              ),
              _LinhaDado(
                icon: Symbols.nest_eco_leaf,
                rotulo: 'Biodiversidade: ',
                valor: u.biodiversidadeEmString ?? 'Indefinida',
                extra: ' (${u.quantidadeEspecies} espécies)',
              ),
              _LinhaDado(
                icon: Symbols.thumb_up,
                rotulo: 'Qualidade ambiental: ',
                valor: u.qualidadeAmbiental == null
                    ? 'erro'
                    : '${u.qualidadeAmbiental!.toStringAsFixed(0)}%',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconeTexto extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconeTexto({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _LinhaDado extends StatelessWidget {
  final IconData icon;
  final String rotulo;
  final String valor;
  final String? extra;

  const _LinhaDado({
    required this.icon,
    required this.rotulo,
    required this.valor,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 24, fill: 1),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 14, color: cor),
                children: [
                  TextSpan(text: rotulo),
                  TextSpan(text: valor),
                  if (extra != null)
                    TextSpan(text: extra, style: const TextStyle(fontSize: 9)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _tipoEmTexto(TipoDeUnidade tipo) {
  switch (tipo) {
    case TipoDeUnidade.PARQUE_NACIONAL:
      return 'Parque Nacional';
    case TipoDeUnidade.RESERVA_BIOLOGICA:
      return 'Reserva Biológica';
    case TipoDeUnidade.MONUMENTO_NATURAL:
      return 'Monumento Natural';
    case TipoDeUnidade.FLONA:
      return 'Floresta Nacional';
    case TipoDeUnidade.RESERVA_EXTRATIVISTA:
      return 'Reserva Extrativista';
    case TipoDeUnidade.RPPN:
      return 'RPPN';
    case TipoDeUnidade.DESCONHECIDO:
      return 'Unidade de Conservação';
  }
}

String _number(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
