

class Supervisor{
    final int id;
    final int usuarioId;
    final int unidadeId;

    Supervisor({
        required this.id,
        required this.usuarioId,
        required this.unidadeId
    });

    factory Supervisor.fromJson(Map<String,dynamic> json){

        return Supervisor(

            id: json['Id'] ?? json['id'] ?? 0,
            usuarioId: json["UsuarioId"] ?? json["usuarioId"] ?? 0,
            unidadeId: json["UnidadeId"] ?? json["unidadeId"] ?? 0
        );
    }
}

