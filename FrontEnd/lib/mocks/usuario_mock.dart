import 'package:conport/models/usuario.dart';

class UsuarioMock {
  static Usuario pegarDados(int id) {
    return Usuario(
      id: id,
      nome: 'Usuário Demo',
      apelido: 'demo',
      datanasc: DateTime(2005, 5, 15),
      estado: 'São Paulo',
      cidade: 'Santa Bárbara d\'Oeste',
      email: 'demo@conport.com',
      // O AuthMock compara esta senha no login mockado.
      senha: '123456',
      confiavel: true,
      xp: 670,
      level: 12,
      moedas: 150,
      avatar: null,
      datacadastro: DateTime(2025, 7, 6),
      seguidores: 11,
      seguindo: 12,
      reportsEnviados: 5,
      reportsResolvidos: 3,
      reportsRejeitados: 1,
      reportsPendentes: 1,
      missoesConcluidas: 18,
    );
  }
}
