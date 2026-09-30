import 'package:conport/config/app_config.dart';
import 'package:conport/models/unidade_mapa.dart';
import 'package:conport/mocks/unidade_mapa_mock.dart';

class MapService {
  const MapService();

  Future<UnidadeMapa> buscarUnidade(int id) async {
    if (!AppConfig.usarApi) {
      return UnidadeMapaMock.buscar(id);
    }

    // TODO: integrar com a api mas esse trabalho n é meu

    throw Exception(
      'A API ainda não fornece todos os dados necessários para UnidadeMapa.',
    );
  }
}
