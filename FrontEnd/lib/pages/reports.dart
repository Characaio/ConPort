import 'package:flutter/material.dart';


class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String opcaoSelecionada = '2';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Stack(
            children: [
                Positioned(
                    top:20, left:20,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {

                        },
                    ),
                ),
                Positioned(top:22, left: 125,
                    child: Text('Criar Report',
                    style: TextStyle(
                    fontSize:24,
                    ),
                    ),
                ), 
                Positioned(top: 85, left: 125,
                    child:Text('Registre seus reports aqui.',
                    style: TextStyle(
                        fontSize: 20,
                    )
                ),
                ),
                
                Positioned(top: 150, left:125,
                child:DropdownButton<String>(
                    value: opcaoSelecionada,
                    items: [
                     DropdownMenuItem(
                        value: '1',
                        child: Text('Queimada')
                        ),  
                    DropdownMenuItem(
                        value: '2',
                        child: Text('Animal ferido')
                        ), 
                    DropdownMenuItem(
                        value: '3',
                        child: Text('Desmatamento')
                        ), 
                    DropdownMenuItem(
                        value: '4',
                        child: Text('Animal exotico  ')
                        ),   
                    DropdownMenuItem(
                        value: '5',
                        child: Text('poluição')
                        ),              
                    ],
                    onChanged: (valor) {
                         setState(() {
                                opcaoSelecionada = valor!;
                                });
                            },
                        ),
                ),

                
                Positioned(top: 250, left: 125,
                    child:Text('local:',
                    style: TextStyle(
                        fontSize: 20,
                    ),
                    )
                ),
                Positioned(top: 290, left: 125,
                child:SizedBox(width:300, child: TextField(
                    decoration: InputDecoration(
                        filled: true,           
                        border:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),),
                        hintText: 'coloque a localização do ocorrido.'
                    ),
                )
                )
                ),
                Positioned(top: 130, left: 125,
                    child:Text('tipo do ocorrido:',
                    style: TextStyle(
                        fontSize: 16,
                        )
                    )
                ),    
                Positioned(top: 360, left: 125,
                    child:Text('descrição do ocorrido:',
                    style: TextStyle(
                        fontSize: 24,
                        )
                    )
                ),
                Positioned(top: 400, left: 125,
                child: SizedBox(
                    width: 350,
                    height: 150,
                    child: TextField(
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                            hintText: '...',
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                                )
                            )
                        )
                    )
                ),
                Positioned(top: 630, left: 125,
                child: SizedBox(
                    width: 335,
                    height: 160,
                    child:OutlinedButton.icon
                    (onPressed: (){},
                    icon: Icon(Icons.attach_file),
                    label: Text('adicionar anexo'),
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                                )
                            )
                        )
                    )
                ),
                Positioned(top: 600, left: 125,
                    child:Text('anexos',
                    style: TextStyle(
                        fontSize: 20,
                    ),
                    )
                ),
                Positioned(top: 800, left: 125,
                child: SizedBox(width: 400,height: 30,
                child:ElevatedButton(
                    onPressed: (){
                        print('clicou');

                },
                child: Text ('mandar report.')   
                )
                )
                )
        
                
                
            ],
        ),
    );
  }
}
        
