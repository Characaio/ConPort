import 'package:conport/models/unidade_mapa.dart';

class UnidadeMapaMock {
  static UnidadeMapa buscar(int id) {
    return UnidadeMapa(
      id: id,
      nome: 'Parque Estadual de Exemplo',
      tipo: 'Unidade de Conservação',
      local: 'Santa Bárbara d’Oeste - SP',
      telefone: '(19) 3456-7890',
      horario: '08:00 às 17:00',
      descricao:
          'Área destinada à preservação ambiental, conservação da biodiversidade e visitação pública.',
      aviso: 'Área parcialmente interditada para manutenção.',
      imagens: const [
        'https://picsum.photos/800/500?random=1',
        'https://picsum.photos/800/500?random=2',
        'https://picsum.photos/800/500?random=3',
      ],
    );
  }
}
