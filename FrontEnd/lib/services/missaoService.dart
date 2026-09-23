import 'dart:convert';
import 'package:conport/models/report.dart';
import 'package:http/http.dart' as http;

import '../models/mission.dart';
import '../models/unidade.dart';

class MissaoService{

    final String UrlBase = "http://localhost:8080";

    Future<Mission> buscarMissao(int missaoId) async{

        final url = Uri.parse(
            '$UrlBase/missoes/$missaoId'
        );

        final response = await http.get(url);

        if (response.statusCode == 200){
            final json = jsonDecode(response.body);

            return Mission.fromJson(json);
        }

        if (response.statusCode == 404){
            throw Exception("Missao não encontrada");
        }
        throw Exception("Erro ao buscar Missao: ${response.statusCode}");
    }

    Future<List<Mission>> buscarMissoesDeUsuario(List<int> idMissoes) async{
        List<Mission> missoes = [];

        for (final id in idMissoes) {
            missoes.add(await buscarMissao(id));
        }

        return missoes;
    }

    Future<Mission> progredirMissao(int missaoId,int progresso) async {
        final url = Uri.parse(
            '$UrlBase/missoes/$missaoId/progresso'
        );

        final response = await http.post(url, body: {
            'progresso': progresso,
        });

        if (response.statusCode == 200) {
            return Mission.fromJson(jsonDecode(response.body));
        }

        if (response.statusCode == 404) {
            throw Exception('Missão não encontrada');
        }
        throw Exception('Erro ao progredir missão: ${response.statusCode}');
    }
}
    
   
