import 'package:flutter/material.dart';
class SearchScreen extends StatelessWidget{const SearchScreen({super.key});@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Global Search')),body:const Padding(padding:EdgeInsets.all(20),child:TextField(decoration:InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Customers, suppliers, transactions, products...')));}
