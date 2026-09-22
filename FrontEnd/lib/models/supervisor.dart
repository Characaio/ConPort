class Supervisor{
    final int id;
    final int usuarioId;
    final int unidadeId;

const Supervisor({
    required this.id;
    required this.usuarioId;
    required this.unidadeId;
})

    factory Unidade.fromJson(Map<String,dynamic> json){
    return Supervisor(

    id: json['Id'] ?? json['id'] ?? 0,
)



 }


    
}