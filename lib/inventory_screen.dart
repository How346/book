import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
class InventoryScreen extends StatelessWidget{const InventoryScreen({super.key});@override Widget build(BuildContext c){final ps=c.watch<AppState>().products;return Scaffold(appBar:AppBar(title:const Text('Inventory')),body:ps.isEmpty?const Center(child:Text('No products yet.')):ListView(children:ps.map((p)=>ListTile(title:Text(p.name),subtitle:Text(p.sku),trailing:Text('${p.stock} ${p.unit}'))).toList()));}}
