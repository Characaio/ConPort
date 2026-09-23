import 'package:flutter/material.dart';

class Usuario{
    final int id;
    final String nome;
    final DateTime datanascimento;
    final String email;
    final String senha;
    final bool confiavel;
    final int xp;
    final int level;
    final int moedas;
    final int? reportsEnviados;
    final int? reportsResolvidos;
    final int? reportsRejeitados;
    final int? reportsPendentes;
    final int? missoesConcluidas

    const Usuario({
    required this.id,
    required this.nome,
    required this.datanascimento,
    required this.email,
    required this.senha,
    required this.confiavel,
    required this.xp,
    required this.level,
    required this.moedas, 
    this.reportsEnviados,
    this.reportsResolvidos,
    this.reportsRejeitados,
    this.reportsPendentes,
    this.missoesConcluidas
    });

    factory Usuario.fromJson(Map<String,dynamic> json){
      return Usuario(
          id: json['Id'] ?? json['id'] ?? 0,

          nome: json['Nome'] ?? json['nome'] ?? 'Nome', 

          datanascimento: json['DataNascimento'] ?? json['dataNascimento'] ?? 'Data Nascimento',

          email: json['Email'] ?? json['email'] ?? 'Email',

          senha: json['Senha'] ?? json['senha'] ?? 'Senha',

          confiavel: json['Confiavel'] ?? json['confiavel'] ?? 'Confiavel',

          xp: json['Xp'] ?? json['xp'] ?? 'Xp',

          level: json['Level'] ?? json['level'] ?? 'Level',

          moedas: json['Moedas'] ?? json['moedas'] ?? 'Moedas',
          
          reportsEnviados: json['ReportsEnviados'] ?? json["reportsEnviados"] ?? 0,
          
          reportsResolvidos: json['ReportsResolvidos'] ?? json["reportsResolvidos"] ?? 0,

          reportsRejeitados: json['ReportsRejeitados'] ?? json["reportsRejeitados"] ?? 0,

          reportsPendentes: json['ReportsPendentes'] ?? json["reportsPendentes"] ?? 0,

          missoesConcluidas: json["MissoesConcluidas"] ?? json["missoesConcluidas"] ?? 0
      );

    }

}
