class Usuario{
    final Int id;
    final String nome;
    final Date datanascimento;
    final String email;
    final String senha;
    final bool confiavel;
    final int xp;
    final int level;
    final int moedas;

    const Usuario({
    required this.id;
    required this.nome;
    required this.datanascimento;
    required this.email;
    required this.senha;
    required this.confiavel;
    required this.xp;
    required this.level;
    required this.moedas;  

    })

     factory Unidade.fromJson(Map<String,dynamic> json){
    
    
    return Usuario(
        id: json['Id'] ?? json['id'] ?? 0,

        nome: json['Nome'] ?? json['nome'] ?? 'Nome', 

        datanascimento: json['DataNascimento'] ?? json['dataNascimento'] ?? 'Data Nascimento',

        email: json['Email'] ?? json['email'] ?? 'Email',

        senha: json['Senha'] ?? json['senha'] ?? 'Senha',

        confiavel: json['Confiavel'] ?? json['confiavel'] ?? 'Confiavel',

        xp: json['Xp'] ?? json['xp'] ?? 'Xp',

        level: json['Level'] ?? json['level'] ?? 'Level',

        moedas: json['Moedas'] ?? json['moedas'] ?? 'Moedas'
        
    )

     }

}
