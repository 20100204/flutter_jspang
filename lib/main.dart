 import 'package:flutter/material.dart';
 
 import './pages/index_page.dart';
 void main()=>runApp(MyApp());
 class MyApp extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
     return Container(
         child: MaterialApp(
           navigatorObservers:[],
           title: "百姓生活+",
           debugShowCheckedModeBanner: false,
           theme: ThemeData( //皮肤颜色
             primaryColor: Colors.pink
           ),
           home:IndexPage()
         ),
     );
   }
 } 


  