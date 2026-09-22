import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class Myrepo extends StatelessWidget {
  const Myrepo ({super.key});

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
                Positioned(top:22, left: 110,
                    child: Text('Meus Reports',
                    style: TextStyle(
                    fontSize:24,
                    ),
                    ),
                ), 
                Positioned(top:100, left: 125,
                  child: 
                  Container(
                    width: 300,height:150,
                    decoration: BoxDecoration( 
                      color: Colors.white.withValues(alpha: 1.5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                          Padding(
                            padding: EdgeInsets.only(left:8),                            
                          child:
                          Text(
                            'Animal ferido' ,
                            style: TextStyle(color: Colors.black,fontSize:20),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Symbols.explore,
                              size: 24,
                              weight: 500,
                              fill: 1,
                            ), 
                          SizedBox(width:5),                                              
                          Text(                           
                            'Jardim Europa',                           
                            style: TextStyle(color: Colors.black,
                            fontSize:20),
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
                                '08/08/2026 14:30',
                                style:TextStyle(color: Colors.black,
                                fontSize:16
                                ),
                              ),                                                     
                            ],
                          ),
                SizedBox(height:10),
                Row(
                  children: [
                    Icon(
                      Symbols.check,
                        size: 22,
                        weight: 500,
                        fill: 1,
                        ),

                        SizedBox(width: 5),
                            Text(
                            'Incidente resolvido',
                                style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      Icon(
                        Symbols.image,
                        size: 22,
                        weight:500,
                        fill:1,
                      ),
                      SizedBox(width:5),
                      Text('Imagem anexada',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
                Positioned(top:280, left: 125,
                  child: 
                  Container(
                    width: 300,height:150,
                    decoration: BoxDecoration( 
                      color: Colors.white.withValues(alpha: 1.5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                          Padding(
                            padding: EdgeInsets.only(left:8),                            
                          child:
                          Text(
                            'poluição' ,
                            style: TextStyle(color: Colors.black,fontSize:20),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Symbols.explore,
                              size: 24,
                              weight: 500,
                              fill: 1,
                            ), 
                          SizedBox(width:5),                                              
                          Text(                           
                            'avenida são paulo',                           
                            style: TextStyle(color: Colors.black,
                            fontSize:20),
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
                                '16/02/2025 22:15',
                                style:TextStyle(color: Colors.black,
                                fontSize:16
                                ),
                              ),                                                     
                            ],
                          ),
                SizedBox(height:10),
                Row(
                  children: [
                    Icon(
                      Symbols.pending,
                        size: 22,
                        weight: 500,
                        fill: 1,
                        ),

                        SizedBox(width: 5),
                            Text(
                            'Incidente pendente',
                                style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      Icon(
                        Symbols.image,
                        size: 22,
                        weight:500,
                        fill:1,
                      ),
                      SizedBox(width:5),
                      Text('Imagem anexada',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ],
                ),   
              ),
            ),
              Positioned(top:460, left: 125,
                  child: 
                  Container(
                    width: 300,height:150,
                    decoration: BoxDecoration( 
                      color: Colors.white.withValues(alpha: 1.5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                          Padding(
                            padding: EdgeInsets.only(left:8),                            
                          child:
                          Text(
                            '...' ,
                            style: TextStyle(color: Colors.black,fontSize:20),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Symbols.explore,
                              size: 24,
                              weight: 500,
                              fill: 1,
                            ), 
                          SizedBox(width:5),                                              
                          Text(                           
                            '...',                           
                            style: TextStyle(color: Colors.black,
                            fontSize:20),
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
                                '../../.... ..:..',
                                style:TextStyle(color: Colors.black,
                                fontSize:16
                                ),
                              ),                                                     
                            ],
                          ),
                SizedBox(height:10),
                Row(
                  children: [
                    Icon(
                      Symbols.pending,
                        size: 22,
                        weight: 500,
                        fill: 1,
                        ),

                        SizedBox(width: 5),
                            Text(
                            '...',
                                style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      Icon(
                        Symbols.image,
                        size: 22,
                        weight:500,
                        fill:1,
                      ),
                      SizedBox(width:5),
                      Text('...',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ],
                ),   
              ),                                                  
            ),
                
                Positioned(top: 20, right: 100,
                child:
                 IconButton(
          onPressed: () {},
          icon: Icon(Symbols.account_circle, size: 32, weight: 1000.0, fill: 1,),
                ),         
              ),
            ],         
          )
        );
      }
}