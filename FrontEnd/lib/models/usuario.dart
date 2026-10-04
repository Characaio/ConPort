import 'package:flutter/material.dart';
import 'package:conport/config/app_config.dart';

/// Quem pode abrir "quem sigo" e "Quem me segue".
///
/// Os nomes seguem o enum do backend (`VisibilidadeSeguidores`); o que
/// aparece na tela é [rotulo].
enum VisibilidadeSeguidores {
  publico,
  soAmigos,
  privado;

  /// Nome no backend.
  String get nome => switch (this) {
    VisibilidadeSeguidores.publico => 'PUBLICO',
    VisibilidadeSeguidores.soAmigos => 'SO_AMIGOS',
    VisibilidadeSeguidores.privado => 'PRIVADO',
  };

  String get rotulo => switch (this) {
    VisibilidadeSeguidores.publico => 'Público',
    VisibilidadeSeguidores.soAmigos => 'Só amigos',
    VisibilidadeSeguidores.privado => 'Privado',
  };

  String get descricao => switch (this) {
    VisibilidadeSeguidores.publico => 'Qualquer pessoa vê suas listas.',
    VisibilidadeSeguidores.soAmigos =>
      'Só os seus amigos veem. Você sempre vê.',
    VisibilidadeSeguidores.privado => 'Ninguém além de você vê.',
  };

  /// Valor desconhecido (app desatualizado) vira o mais permissivo, que é o
  /// que toda conta tinha antes de existir essa opção.
  static VisibilidadeSeguidores porNome(dynamic valor) {
    final nome = valor?.toString().toUpperCase();

    for (final v in VisibilidadeSeguidores.values) {
      if (v.nome == nome) return v;
    }

    return VisibilidadeSeguidores.publico;
  }
}

class Usuario {
  final int id;
  final String nome;
  final DateTime datanasc;
  final String estado;
  final String cidade;
  final String email;
  final String? senha;
  final bool confiavel;
  final int xp;
  final int level;
  final int moedas;
  final String? username;
  final String? avatar;

  /// Quem pode abrir as listas de seguidores/seguindo.
  final VisibilidadeSeguidores visibilidade;

  /// Estado do relacionamento em relação a quem está olhando o perfil. Vem
  /// falso quando o perfil foi aberto sem `visorId` (ex.: depois do login).
  final bool amigo;
  final bool euSigo;
  final bool segueMe;
  final DateTime? datacadastro;
  final int? seguidores;
  final int? seguindo;
  final int? reportsEnviados;
  final int? reportsResolvidos;
  final int? reportsRejeitados;
  final int? reportsPendentes;
  final int? missoesConcluidas;

  const Usuario({
    required this.id,
    required this.nome,
    required this.datanasc,
    required this.estado,
    required this.cidade,
    required this.email,
    this.senha,
    required this.confiavel,
    required this.xp,
    required this.level,
    required this.moedas,
    this.username,
    this.avatar,
    this.visibilidade = VisibilidadeSeguidores.publico,
    this.amigo = false,
    this.euSigo = false,
    this.segueMe = false,
    this.datacadastro,
    this.seguidores,
    this.seguindo,
    this.reportsEnviados,
    this.reportsResolvidos,
    this.reportsRejeitados,
    this.reportsPendentes,
    this.missoesConcluidas,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) {
        throw FormatException('Data não informada');
      }

      final data = DateTime.tryParse(value.toString());

      if (data == null) {
        throw FormatException('Data inválida: $value');
      }

      return data;
    }

    DateTime? parseDateOpcional(dynamic value) {
      if (value == null) return null;
      final data = DateTime.tryParse(value.toString());
      return data;
    }

    return Usuario(
      id: json['Id'] ?? json['id'] ?? 0,

      nome: json['Nome'] ?? json['nome'] ?? 'Nome',

      datanasc: parseDate(json['DataNasc'] ?? json['dataNasc']),

      estado: json["Estado"] ?? json["estado"] ?? "Narnia",

      cidade: json["Cidade"] ?? json["cidade"] ?? "Atlantica",

      email: json['Email'] ?? json['email'] ?? 'Email',

      // O UsuarioDTO não devolve a senha (e não deveria). Antes caía num
      // placeholder que parecia uma senha de verdade na sessão; ausente é
      // ausente.
      senha: json['Senha'] ?? json['senha'],

      confiavel: json['Confiavel'] ?? json['confiavel'] ?? false,

      xp: json['Xp'] ?? json['xp'] ?? json['XP'] ?? 0,

      level: json['Level'] ?? json['level'] ?? 0,

      moedas: json['Moedas'] ?? json['moedas'] ?? 0,

      username: json['Username'] ?? json['username'],

      avatar: json['Avatar'] ?? json['avatar'],

      visibilidade: VisibilidadeSeguidores.porNome(
        json['Visibilidade'] ?? json['visibilidade'],
      ),

      amigo: json['Amigo'] ?? json['amigo'] ?? false,

      euSigo: json['EuSigo'] ?? json['euSigo'] ?? false,

      segueMe: json['SegueMe'] ?? json['segueMe'] ?? false,

      datacadastro: parseDateOpcional(
        json['DataCadastro'] ?? json['dataCadastro'],
      ),

      seguidores: json['Seguidores'] ?? json['seguidores'] ?? 0,

      seguindo: json['Seguindo'] ?? json['seguindo'] ?? 0,

      reportsEnviados: json['ReportsEnviados'] ?? json["reportsEnviados"] ?? 0,

      reportsResolvidos:
          json['ReportsResolvidos'] ?? json["reportsResolvidos"] ?? 0,

      reportsRejeitados:
          json['ReportsRejeitados'] ?? json["reportsRejeitados"] ?? 0,

      reportsPendentes:
          json['ReportsPendentes'] ?? json["reportsPendentes"] ?? 0,

      missoesConcluidas:
          json["MissoesConcluidas"] ?? json["missoesConcluidas"] ?? 0,
    );
  }
  String? get avatarUrl {
    final a = avatar;
    if (a == null || a.isEmpty) return null;
    return '${AppConfig.apiUrl}/imagens/$a';
  }

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) {
      return partes.first.characters.first.toUpperCase();
    }
    return (partes.first.characters.first + partes.last.characters.first)
        .toUpperCase();
  }
}
