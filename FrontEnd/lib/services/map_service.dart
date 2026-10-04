import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conport/config/app_config.dart';
import 'package:conport/models/unidade_mapa.dart';
import 'package:conport/mocks/unidade_mapa_mock.dart';
import 'package:conport/services/aviso_service.dart';

class MapService {
  const MapService();

  Future<UnidadeMapa> buscarUnidade(int id) async {
    if (!AppConfig.usarApi) {
      return UnidadeMapaMock.buscar(id);
    }

    final url = Uri.parse(
      '${AppConfig.apiUrl}/unidade/$id/informacoes',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar informações da unidade: '
        '${response.statusCode}',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final String nome =
        (data['nome'] ?? '').toString();

    final String telefone =
        (data['telefone'] ?? '').toString();

    final String descricao =
        (data['descricao'] ?? '').toString();

    final String tipo =
        (data['tipoDeUnidade'] ?? '').toString();

    final String horario = _montarHorario(
      data['horaDeAbertura'],
      data['horaDeFechamento'],
    );

    final double? latitude =
        _toDouble(data['latitude']);

    final double? longitude =
        _toDouble(data['Longitude'] ?? data['longitude']);

    final String local =
        _montarLocal(latitude, longitude);

    // Foto da unidade: o banco traz uma URL; sem ela a gaveta fica sem imagem.
    final imagem = (data['imagem'] ?? data['Imagem'])?.toString().trim();

    String? aviso;

    try {
      aviso = await const AvisoService().buscarMaisRecente(id)?.then(
            (a) => a == null
                ? null
                : [a.titulo, a.texto].where((t) => t.isNotEmpty).join(': '),
          );
    } catch (_) {
      // O mapa continua funcionando mesmo se a rota de avisos
      // estiver indisponível.
      aviso = null;
    }

    return UnidadeMapa(
      id: _toInt(data['id']) ?? id,
      nome: nome,
      tipo: _formatarTipo(tipo),
      local: local,
      telefone: telefone,
      horario: horario,
      descricao: descricao,
      aviso: aviso,
      imagens: imagem == null || imagem.isEmpty ? const [] : [imagem],
    );
  }

  String _montarHorario(
    dynamic abertura,
    dynamic fechamento,
  ) {
    final aberturaTexto = _formatarHorario(abertura);
    final fechamentoTexto = _formatarHorario(fechamento);

    if (aberturaTexto.isEmpty && fechamentoTexto.isEmpty) {
      return '';
    }

    if (aberturaTexto.isEmpty) {
      return 'Fechamento: $fechamentoTexto';
    }

    if (fechamentoTexto.isEmpty) {
      return 'Abertura: $aberturaTexto';
    }

    return '$aberturaTexto às $fechamentoTexto';
  }

  String _formatarHorario(dynamic valor) {
    if (valor == null) {
      return '';
    }

    final texto = valor.toString();

    if (texto.length >= 5) {
      return texto.substring(0, 5);
    }

    return texto;
  }

  String _montarLocal(
    double? latitude,
    double? longitude,
  ) {
    if (latitude == null || longitude == null) {
      return 'Localização não informada';
    }

    return '${latitude.toStringAsFixed(6)}, '
        '${longitude.toStringAsFixed(6)}';
  }

  String _formatarTipo(String tipo) {
    if (tipo.isEmpty) {
      return 'Unidade de Conservação';
    }

    if (tipo.contains('.')) {
      tipo = tipo.split('.').last;
    }

    tipo = tipo.replaceAll('_', ' ').toLowerCase();

    return tipo
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .map(
          (parte) =>
              parte[0].toUpperCase() + parte.substring(1),
        )
        .join(' ');
  }

  double? _toDouble(dynamic valor) {
    if (valor == null) {
      return null;
    }

    if (valor is num) {
      return valor.toDouble();
    }

    return double.tryParse(valor.toString());
  }

  int? _toInt(dynamic valor) {
    if (valor == null) {
      return null;
    }

    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.toInt();
    }

    return int.tryParse(valor.toString());
  }
}