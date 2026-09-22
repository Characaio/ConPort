import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class Dtrepo extends StatelessWidget {
  const Dtrepo ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body:Stack(
            children: [
                Positioned(top: 20, right: 100,
                    child:
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Symbols.account_circle, size: 32, weight: 1000.0, fill: 1,),
                      
                      
                      
                      ),         
                    ),
                    Positioned(top:22, left: 105,
                    child: Text('Detalhes do report',
                    style: TextStyle(
                    fontSize:24,
                    ),
                    ),
                ), 
                Positioned(
                    top:20, left:20,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () { 

                        },
                    ),
                ),
                Positioned(top:100, left: 125,
                  child: 
                  Container(
                    width: 300,height:555,
                    decoration: BoxDecoration( 
                      color: Colors.white.withValues(alpha: 1.5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child:Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                            children:[              
                          Text(
                            'Animal ferido' ,
                            style: TextStyle(color: Colors.black,fontSize:20),
                          ),
                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Symbols.explore,
                              size: 24,
                              weight: 500,
                              fill: 1,
                            ), 
                          SizedBox(width:5),  
                          Expanded(
                            child:                                         
                              Text(                           
                            'Jardim Europa R. Escócia, 491-191 - Pinheiros',                           
                            style: TextStyle(color: Colors.black,
                            
                            fontSize:16),
                          ),
                          ),                        
                          ]
                          ),

                      
                          Row(                       
                            children: [
                              Icon(
                                Symbols.calendar_month,
                                size:24,
                                weight: 500,
                                fill: 1,
                              ),                              
                              Text(
                                'relatado: 08/08/2026 14:30',
                                style:TextStyle(color: Colors.black,
                                fontSize:16
                                ),
                              ),                                                     
                            ],
                          ),
                          Row(                       
                            children: [
                              Icon(
                                Symbols.calendar_month,
                                size:24,
                                weight: 500,
                                fill: 1,
                              ),                              
                              Text(
                                'resolvido: 08/08/2026 18:30',
                                style:TextStyle(color: Colors.green,
                                fontSize:16
                                ),
                              ),                                                     
                            ],
                          ),
                          Row(                       
                            children: [
                              Icon(
                                Symbols.info,
                                size:24,
                                weight: 500,
                                fill: 1,
                              ),                              
                              Text(
                                'status: Incidente resolvido',
                                style:TextStyle(color: Colors.green,
                                fontSize:16
                                ),
                              ),                                                     
                            ],
                          ),
                           Text('descrição',
                          style: TextStyle(color: Colors.black,fontSize: 16),
                          ),
                          SizedBox(height:5),

                          Container(
                            width: double.infinity,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                             borderRadius: BorderRadius.circular(8)
                          ),                      
                          child:Text('regastei um cachorro com sinais de mal-tratos em frente a minha casa.',
                          style: TextStyle(color: Colors.black,fontSize: 16,
                          ),
                        ),
                        ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Symbols.edit_note,
                                size: 24,
                                weight: 500,
                                fill: 1,
                              ),

                              SizedBox(width: 5),

                              Text(
                                'Autor da análise:',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),

                              SizedBox(width: 5),

                              Expanded(
                                child: Text(
                                  'Augusto Henrique Batista rosa',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    

                      SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(
                            Symbols.attach_file,
                            size: 22,
                            weight: 500,
                            fill: 1,
                          ),

                          SizedBox(width: 5),
                          
                          Text(
                            'Anexos',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      Row(
                        children: [
                          Container(
                            width: 120,
                            height: 65,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Symbols.image,
                                  size: 28,
                                  fill: 1,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Anexo 1',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 10),

                          Container(
                            width: 120,
                            height: 65,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Symbols.image,
                                  size: 28,
                                  fill: 1,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Anexo 2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom
                        (fixedSize: Size(120,45),
                        backgroundColor: Color(0xFF795548),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        ),           
                        child: Text(
                          'Voltar',
                          style: TextStyle(
                            color:Colors.white,
                            fontSize: 16,
                     
                     ),
                    ),
                  ),
                ]
              )     
            ),
          )
        ]
      )  
    );       
  }
}
