import 'dart:convert';
import 'package:conport/models/report.dart';
import 'package:http/http.dart' as http;

import '../models/mission.dart';
import '../models/unidade.dart';

class missaoService{

    final String UrlBase = "http://localhost:8080";

    Future<Mission> buscarMissao(int missaoId) async{

        final url = Uri.parse(
            '${UrlBase}/missoes/$missaoId'
        );

        final response = await http.get(url);

        if (response.statusCode == 200){
            final json = jsonDecode(response.body);

            return Mission.fromJson(json);
        }

        if (response.statusCode == 404){
            throw Exception("Report não encontrada");
        }
        throw Exception("Erro ao buscar Report: ${response.statusCode}");
    }

    Future<Mission> progredirMissao(int progresso) async{

    }

    
   
}