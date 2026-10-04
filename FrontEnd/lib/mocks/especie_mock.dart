import 'package:conport/models/especie.dart';

/// Espécies da unidade para quando a API está desligada (`usarApi == false`).
/// Espelha o seed do backend (3 de fauna e 4 de flora).
class EspecieMock {
  static const String _capivara =
      'https://upload.wikimedia.org/wikipedia/commons/f/fb/Lone_capybara.jpg';
  static const String _mata =
      'https://upload.wikimedia.org/wikipedia/commons/b/b9/The_tree_in_forest.jpg';

  static List<Especie> listar(int unidadeId) {
    return [
      Especie(
        id: 1,
        nome: 'Capivara',
        nomeCientifico: 'Hydrochoerus hydrochaeris',
        descricao:
            'Maior roedor do mundo, de hábitos semiaquáticos. Vive em grupos '
            'perto de rios, lagos e áreas alagadas da unidade.',
        imagem: _capivara,
        tipo: TipoEspecie.fauna,
      ),
      Especie(
        id: 2,
        nome: 'Lobo-guará',
        nomeCientifico: 'Chrysocyon brachyurus',
        descricao:
            'Carnívoro endêmico da América do Sul, procura alimento mainly '
            'em áreas abertas de grama e mato.',
        tipo: TipoEspecie.fauna,
      ),
      Especie(
        id: 3,
        nome: 'Jaguatirica',
        nomeCientifico: 'Leopardus pardalis',
        descricao:
            'Felino de porte pequeno e noturno, registrado na faixa de '
            'vegetação mais densa da mata.',
        tipo: TipoEspecie.fauna,
      ),
      Especie(
        id: 4,
        nome: 'Araucária',
        nomeCientifico: 'Araucaria angustifolia',
        descricao:
            'Árvore símbolo da Mata Atlântica, com copas altas que marcam o '
            'dossel da floresta da unidade.',
        imagem: _mata,
        tipo: TipoEspecie.flora,
      ),
      Especie(
        id: 5,
        nome: 'Ipê-amarelo',
        nomeCientifico: 'Handroanthus albus',
        descricao:
            'Árvore nativa que floresce no fim do inverno e é uma das '
            'espécies mais frequentes na unidade.',
        tipo: TipoEspecie.flora,
      ),
      Especie(
        id: 6,
        nome: 'Palmeira-leque',
        nomeCientifico: 'Syagrus romanzoffiana',
        descricao:
            'Palmeira comum nas áreas de borda da mata, com frutos '
            'aproveitados pela fauna nativa.',
        tipo: TipoEspecie.flora,
      ),
      Especie(
        id: 7,
        nome: 'Samambaia',
        nomeCientifico: 'Pteridophyta',
        descricao:
            'Vegetação que se destaca nas áreas úmidas e nas margens dos '
            'cursos d’água da unidade.',
        tipo: TipoEspecie.flora,
      ),
    ];
  }
}