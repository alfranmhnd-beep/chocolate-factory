import 'package:flutter/material.dart';
import '../game/chocolate_game.dart';

class GameHud extends StatefulWidget {
  final ChocolateGame game;
  const GameHud({super.key, required this.game});
  @override State<GameHud> createState()=>_GameHudState();
}
class _GameHudState extends State<GameHud>{
  @override void initState(){super.initState();widget.game.listen(refresh);}
  void refresh(){if(mounted)setState((){});}
  @override void dispose(){widget.game.unlisten(refresh);super.dispose();}
  @override Widget build(BuildContext context){
    final g=widget.game;
    return Stack(children:[
      Positioned(left:10,right:10,top:8,child:Row(children:[
        pill('💰 ${g.coins}'),const SizedBox(width:6),pill('💎 ${g.gems}'),
        const SizedBox(width:6),pill('⭐ Lv.${g.level}  XP ${g.xp}'),
        const SizedBox(width:6),pill('📦 ${g.packaged}'),
        const Spacer(),pill('اليوم ${g.day}'),const SizedBox(width:6),
        IconButton(onPressed:(){setState((){g.paused=!g.paused;});},icon:Icon(g.paused?Icons.play_arrow:Icons.pause))
      ])),
      Positioned(left:16,bottom:18,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Container(padding:const EdgeInsets.all(10),decoration:box(),child:Text(g.notice)),
        const SizedBox(height:8),
        Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),decoration:box(),child:Text('الحمل: ${g.carried}    •    المطحنة: Lv.${g.machineLevel}    •    السير: Lv.${g.beltLevel}')),
      ])),
      Positioned(right:14,bottom:14,child:Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
        button('ترقية الآلات',g.upgradeMachine),
        const SizedBox(height:6),button('ترقية السير',g.upgradeBelt),
        const SizedBox(height:6),button('ترقية المخزن',g.upgradeWarehouse),
      ])),
      const Positioned(right:240,bottom:18,child:Text('🕹️ اضغط على الأرض للتحرك • اقترب من المحطة واضغط للتفاعل',style:TextStyle(fontWeight:FontWeight.bold)))
    ]);
  }
  BoxDecoration box()=>BoxDecoration(color:Colors.black.withOpacity(.72),borderRadius:BorderRadius.circular(14));
  Widget pill(String t)=>Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:7),decoration:box(),child:Text(t,style:const TextStyle(fontWeight:FontWeight.bold)));
  Widget button(String t,VoidCallback f)=>ElevatedButton(onPressed:f,style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF7A451F),foregroundColor:Colors.white),child:Text(t));
}
