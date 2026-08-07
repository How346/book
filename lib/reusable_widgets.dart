import 'package:flutter/material.dart';
class SectionTitle extends StatelessWidget{final String text;const SectionTitle(this.text,{super.key});@override Widget build(BuildContext c)=>Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text(text,style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)));}
