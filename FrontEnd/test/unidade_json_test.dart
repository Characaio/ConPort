import 'package:flutter_test/flutter_test.dart';

import 'package:conport/models/aviso.dart';
import 'package:conport/models/especie.dart';
import 'package:conport/models/unidade.dart';

/// Regressão do status geral: `GET /unidade/{id}` devolve aninhado
/// (informacoes/indicadores/dadosAmbientais) e o front lia chapado, então
/// tudo zerava na tela de informações da unidade.
void main() {
  test('lê o status geral aninhado que o backend devolve', () {
    final unidade = Unidade.fromJson({
      'informacoes': {
        'id': 1,
        'nome': 'Parque Estadual da Serra Verde',
        'telefone': '1934567821',
        'descricao': 'Gourmet',
        'imagem': 'https://exemplo.com/unidade.jpg',
        'tipoDeUnidade': 'PARQUE_NACIONAL',
        'horaDeAbertura': '08:00:00',
        'horaDeFechamento': '17:00:00',
        'latitude': 10.0,
        'Longitude': 8.0,
      },
      'indicadores': {
        'integridadeTerritorial': 90.87,
        'corredoresNecessarios': 10,
        'conectividadeEcologica': 80.0,
        'qualidadeAmbiental': 86.02,
        'preservacaoLocal': 87.46,
        'fiscalizacao': 87.48,
        'biodiversidade': 90.83,
      },
      'dadosAmbientais': {
        'areaTotal': 4820.5,
        'areaRegularizada': 4380.2,
        'areaPreservada': 4215.8,
        'areaMonitorada': 3890.0,
        'areaBasePorCorredor': 500.0,
        'pontosMonitorados': 42,
        'pontosPrevistos': 50,
        'quantCorredores': 8,
        'quantEspecies': 327,
        'quantEspeciesEsperadas': 360,
        'qualidadeAgua': 86.5,
        'qualidadeSolo': 91.2,
        'gestaoResiduos': 78.0,
      },
      'quantReports': 5,
    });

    expect(unidade.id, 1);
    expect(unidade.nome, 'Parque Estadual da Serra Verde');
    expect(unidade.tipoDaUnidade, TipoDeUnidade.PARQUE_NACIONAL);
    expect(unidade.descricao, 'Gourmet');
    expect(unidade.imagem, 'https://exemplo.com/unidade.jpg');
    expect(unidade.horaDeAbertura, '08:00');

    // Dados ambientais, com as grafias abreviadas do DTO.
    expect(unidade.areaTotal, 4820.5);
    expect(unidade.pontosMonitorados, 42);
    expect(unidade.quantidadeEspecies, 327);
    expect(unidade.quantidadeEspeciesEsperadas, 360);
    expect(unidade.qualidaAgua, 86.5);
    expect(unidade.corredoresExistentes, 8);

    // Indicadores.
    expect(unidade.integridadeTerritorial, 90.87);
    expect(unidade.corredoresNecessarios, 10);
    expect(unidade.qualidadeAmbiental, 86.02);
    expect(unidade.quantReports, 5);
  });

  test('lê as informações chapadas de /unidade/{id}/informacoes', () {
    final unidade = Unidade.fromJson({
      'id': 1,
      'nome': 'Parque Estadual',
      'telefone': '1934567821',
      'descricao': 'Gourmet',
      'tipoDeUnidade': 'RPPN',
      'horaDeAbertura': '08:00:00',
      'horaDeFechamento': '17:00:00',
      'latitude': 10.0,
      'Longitude': 8.0,
    });

    expect(unidade.nome, 'Parque Estadual');
    expect(unidade.tipoDaUnidade, TipoDeUnidade.RPPN);
    expect(unidade.descricao, 'Gourmet');
  });

  test('Aviso.fromJson tolera o Titutlo do backend', () {
    final aviso = Aviso.fromJson({
      'id': 1,
      'Titutlo': 'Trilhas reabertas',
      'Descricao': 'As trilhas voltaram a receber visitantes.',
      'HorarioDoAviso': '2026-10-02T01:31:39.112633',
      'Fixo': true,
      'Imagem': 'https://exemplo.com/trilha.jpg',
    });

    expect(aviso.id, 1);
    expect(aviso.titulo, 'Trilhas reabertas');
    expect(aviso.texto, 'As trilhas voltaram a receber visitantes.');
    expect(aviso.fixado, isTrue);
    expect(aviso.imagem, 'https://exemplo.com/trilha.jpg');
    // O backend manda hora com fração de segundo; a tela só mostra minuto.
    expect(aviso.data, DateTime(2026, 10, 2, 1, 31, 39, 112, 633));
  });

  test('Aviso sem Fixo (criado antes do campo) não é fixado', () {
    final aviso = Aviso.fromJson({
      'id': 2,
      'Titutlo': 'Sem fixar',
      'Descricao': '',
      'HorarioDoAviso': '2026-10-02T01:31:39',
    });

    expect(aviso.fixado, isFalse);
    expect(aviso.imagem, isNull);
  });

  test('Especie.fromJson separa fauna de flora', () {
    final fauna = Especie.fromJson({
      'Id': 1,
      'Nome': 'Capivara',
      'NomeCientifico': 'Hydrochoerus hydrochaeris',
      'Descricao': 'Maior roedor do mundo.',
      'Imagem': 'https://exemplo.com/capivara.jpg',
      'Tipo': 'FAUNA',
    });

    final flora = Especie.fromJson({
      'Id': 4,
      'Nome': 'Araucaria',
      'NomeCientifico': 'Araucaria angustifolia',
      'Descricao': 'Arvore simbolo da Mata Atlantica.',
      'Imagem': null,
      'Tipo': 'FLORA',
    });

    expect(fauna.tipo, TipoEspecie.fauna);
    expect(fauna.nome, 'Capivara');
    expect(fauna.imagem, 'https://exemplo.com/capivara.jpg');

    expect(flora.tipo, TipoEspecie.flora);
    // Sem foto cadastrada: a tela mostra o placeholder.
    expect(flora.imagem, isNull);
  });
}