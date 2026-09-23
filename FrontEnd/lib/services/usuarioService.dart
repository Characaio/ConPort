import 'dart:convert';
import 'package:conport/models/usuario.dart';
import 'package:http/http.dart' as http;


class UsuarioService{
    const UsuarioService();

    final String UrlBase = "http://localhost:8080";


    Future<Usuario> pegarDados(int id) async{
      final url = Uri.parse(
        "$UrlBase/usuarios/$id"
      );

      final response = await http.get(url);

      if (response.statusCode == 200){
        final json = jsonDecode(response.body);

        return Usuario.fromJson(json);
      }

      if (response.statusCode == 404){
        throw Exception("Usuario não encontrado");
      }
      throw Exception("Erro ao buscar Usuario: ${response.statusCode}");

    }

}

