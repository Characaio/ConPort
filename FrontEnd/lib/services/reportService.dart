import 'dart:convert';
import 'package:conport/models/report.dart';
import 'package:http/http.dart' as http;


class ReportService{
    final String UrlBase = "http://localhost:8080";

    Future<Report> buscarReportCompleto(int id) async{

        final url = Uri.parse(
            '$UrlBase/reports/$id/completo'
        );

        final response = await http.get(url);
        if (response.statusCode == 200) {
            final json = jsonDecode(response.body);

            return Report.fromJson(json);
        }

        if (response.statusCode == 404) {
            throw Exception('Report não encontrado');
        }
        throw Exception('Erro ao Buscar Report: ${response.statusCode}');
    }

    Future<Report> buscarReportResumido(int id) async{

        final url = Uri.parse(
            '$UrlBase/reports/$id/resumido'
        );

        final response = await http.get(url);
        if (response.statusCode == 200) {
            final json = jsonDecode(response.body);

            return Report.fromJson(json);
        }

        if (response.statusCode == 404) {
            throw Exception('Report não encontrado');
        }
        throw Exception('Erro ao Buscar Report: ${response.statusCode}');
    }

    Future<Report> postarReport(int unidadeId, Report report) async{

        final url = Uri.parse(
            '$UrlBase/unidade/$unidadeId/criarReport'
        );

        final request = http.MultipartRequest("Post", url);

        request.fields["Tipo"] = report.tipoDeIncidente.toString();
        request.fields["Descricao"] = report.descricao;
        request.fields["DataDoOcorrido"] = report.dataDoOcorrido.toIso8601String();
        request.fields["UsuarioId"] = report.usuarioId.toString();
        request.fields["UnidadeId"] = report.unidadeId.toString();
        request.fields["StatusReport"] = report.statusReport.toString();
        
        final streamedResponse = await request.send();

        final response  = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
            return Report.fromJson(jsonDecode(response.body));
        }
        throw Exception('Erro ao postar Report: ${response.statusCode}');
    }

    //Fazer a rota de analise depois, não utilizada para a demo

}

