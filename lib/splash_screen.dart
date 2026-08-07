import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'onboarding_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState()=>_SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController c;
  @override void initState(){super.initState(); c=AnimationController(vsync:this,duration:const Duration(milliseconds:900))..forward();}
  @override void dispose(){c.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final ready=context.watch<AppState>().loaded;
    if(ready){Future.microtask(()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const OnboardingGate())));}
    return Scaffold(body:Center(child:ScaleTransition(scale:CurvedAnimation(parent:c,curve:Curves.easeOutBack),child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(width:92,height:92,decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary,borderRadius:BorderRadius.circular(28)),child:const Icon(Icons.account_balance_wallet_rounded,color:Colors.white,size:52)),
      const SizedBox(height:20),Text('Digital Khata',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Your business. Your records. Offline.')
    ])));
  }
}
class OnboardingGate extends StatelessWidget {const OnboardingGate({super.key}); @override Widget build(BuildContext c){final s=c.read<AppState>(); final seen=s.db.get('onboarded')==true; return seen?const DashboardScreen():const OnboardingScreen();}}
