import 'package:flutter/material.dart';

class Usuario{
    final int id;
    final String nome;
    final DateTime datanasc;
    final String estado;
    final String cidade;
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
    final int? missoesConcluidas;

    const Usuario({
    required this.id,
    required this.nome,
    required this.datanasc,
    required this.estado,
    required this.cidade,
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
      return Usuario(
          id: json['Id'] ?? json['id'] ?? 0,

          nome: json['Nome'] ?? json['nome'] ?? 'Nome', 

          datanasc: parseDate(json['DataNasc'] ?? json['dataNasc']),

          estado: json["Estado"] ?? json["estado"] ?? "Narnia",

          cidade: json["Cidade"] ?? json["cidade"] ?? "Atlantica",

          email: json['Email'] ?? json['email'] ?? 'Email',

          senha: json['Senha'] ?? json['senha'] ?? 'Senha',

          confiavel: json['Confiavel'] ?? json['confiavel'] ?? false,

          xp: json['Xp'] ?? json['xp'] ?? 0,

          level: json['Level'] ?? json['level'] ?? 0,

          moedas: json['Moedas'] ?? json['moedas'] ?? 0,
          
          reportsEnviados: json['ReportsEnviados'] ?? json["reportsEnviados"] ?? 0,
          
          reportsResolvidos: json['ReportsResolvidos'] ?? json["reportsResolvidos"] ?? 0,

          reportsRejeitados: json['ReportsRejeitados'] ?? json["reportsRejeitados"] ?? 0,

          reportsPendentes: json['ReportsPendentes'] ?? json["reportsPendentes"] ?? 0,

          missoesConcluidas: json["MissoesConcluidas"] ?? json["missoesConcluidas"] ?? 0
      );

    }

}
