import 'dart:convert';
import 'package:conport/models/report.dart';
import 'package:http/http.dart' as http;

import '../models/unidade.dart';

class unidadeService{

    final String UrlBase = "http://localhost:8080";

    Future<Unidade> buscarStatusPrincipal(int id) async{
        final url = Uri.parse(
            '${UrlBase}/unidade/$id/statusPrincipal'
        );

        final response = await http.get(url);
        if (response.statusCode == 200){
            final json = jsonDecode(response.body);
            
            return Unidade.fromJson(json);
        }

        if (response.statusCode == 404){
            throw Exception("Unidade não encontrada");
        }
        throw Exception("Erro ao buscar unidade: ${response.statusCode}");
    }

    Future<Unidade> buscarStatusGeral(int id) async{
        final url = Uri.parse(
            "${UrlBase}/unidade/$id/statusGeral"
        );

        final response = await http.get(url);

        if (response.statusCode == 200){
            final json = jsonDecode(response.body);
            return Unidade.fromJson(json);
        }

        if (response.statusCode == 404){
            throw Exception("Unidade não encontrada");
        }

        throw Exception("Erro ao buscar geral: ${response.statusCode}");
    }

    Future<List<Report>> buscarReports(int unidadeId) async {

        final url = Uri.parse(
            "${UrlBase}/unidade/$unidadeId/reports"
        );

        final response = await http.get(url);

        if (response.statusCode == 200){
            final List<dynamic> json = jsonDecode(response.body);

            return json
            .map((item) => Report.fromJson(item))
            .toList();
        }

        if (response.statusCode == 404){
            throw Exception("Unidade não encontrada");
        }

        throw Exception("Erro ao buscar reports: ${response.statusCode}")

    }

    
}