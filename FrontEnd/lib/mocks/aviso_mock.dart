import 'package:conport/models/aviso.dart';

/// Anúncios da unidade para quando a API está desligada (`usarApi == false`).
/// Espelha o que o backend devolve: um fixado no topo e o resto por data.
class AvisoMock {
  static const String _mata =
      'https://upload.wikimedia.org/wikipedia/commons/b/b9/The_tree_in_forest.jpg';

  static List<Aviso> listar(int unidadeId) {
    final agora = DateTime.now();

    return [
      Aviso(
        id: 1,
        titulo: 'Trilhas reabertas',
        texto:
            'As trilhas da mata voltaram a receber visitantes depois da '
            'limpeza da semana passada. Continue atenta à sinalização.',
        data: agora.subtract(const Duration(days: 2)),
        fixado: true,
        imagem: _mata,
      ),
      Aviso(
        id: 2,
        titulo: 'Monitoramento da qualidade da água',
        texto:
            'A campanha de coleta de água do mês começa na próxima segunda. '
            'Os pontos de monitoramento serão sinalizados na trilha principal.',
        data: agora.subtract(const Duration(days: 6)),
      ),
      Aviso(
        id: 3,
        titulo: 'Campanha de fauna',
        texto:
            'Encontro de identificação de fauna com especialistas. As '
            'inscrições ficam abertas até o fim do mês.',
        data: agora.subtract(const Duration(days: 12)),
      ),
      Aviso(
        id: 4,
        titulo: 'Áreas de descanso',
        texto:
            'As áreas de descanso continuam fechadas para visitação. Use as '
            'dependências tracejadas.',
        data: agora.subtract(const Duration(days: 21)),
      ),
    ];
  }
}