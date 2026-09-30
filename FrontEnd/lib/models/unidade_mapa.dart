class UnidadeMapa {
  final int id;
  final String nome;
  final String tipo;
  final String local;
  final String telefone;
  final String horario;
  final String descricao;
  final String? aviso;
  final List<String> imagens;

  const UnidadeMapa({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.local,
    required this.telefone,
    required this.horario,
    required this.descricao,
    this.aviso,
    required this.imagens,
  });
}
