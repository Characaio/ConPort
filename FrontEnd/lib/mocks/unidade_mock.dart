import 'package:conport/models/unidade.dart';

class UnidadeMock {
  static Unidade buscarStatusPrincipal(int id) {
    return Unidade(
      id: id,
      nome: 'Parque Estadual de Exemplo',
      localizacao: 'Santa Bárbara d\'Oeste - SP',
      bioma: 'Mata Atlântica',
      telefone: '(19) 99999-9999',

      horaDeAbertura: '08:00',
      horaDeFechamento: '17:00',

      tipoDaUnidade: TipoDeUnidade.PARQUE_NACIONAL,

      areaTotal: 1250.0,
      areaRegularizada: 1100.0,
      areaPreservada: 950.0,
      areaMonitorada: 800.0,
      areaBasePorCorredor: 150.0,

      pontosMonitorados: 12,
      pontosPrevistos: 20,
      quantidadeEspecies: 87,
      quantidadeEspeciesEsperadas: 100,

      qualidaAgua: 82.0,
      qualidadeSolo: 76.0,
      gestaoResiduos: 90.0,

      corredoresExistentes: 4,
      quantReports: 7,
      integridadeTerritorial: 85.0,
      corredoresNecessarios: 5,
      conectividadeEcologica: 78.0,
      qualidadeAmbiental: 88.0,
      preservacaoLocal: 92.0,
      fiscalizaocao: 70.0,
      biodiversidade: 81.0,

      fiscalizacaoEmString: 'Alto',
      biodiversidadeEmString: 'Alto',
    );
  }
}
