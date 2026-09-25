import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/save_service.dart';

class ChocolateGame extends FlameGame with TapCallbacks {
  final SaveService save = SaveService();
  final List<VoidCallback> listeners = [];

  int coins = 1200, gems = 25, xp = 0, level = 1;
  int carried = 0, cocoaMass = 0, packaged = 0;
  int machineLevel = 1, beltLevel = 1, warehouseLevel = 1;
  int day = 1;
  double timeOfDay = 0.15;
  bool paused = false;
  String notice = 'ابدأ بالتقاط الكاكاو من المخزن';

  late Player player;
  late FactoryWorld factory;
  late Station raw, grinder, mixer, heater, temperer, mold, cooler, packer, warehouse, orders;
  late Conveyor conveyor;

  void changed() { for (final f in List<VoidCallback>.from(listeners)) f(); }
  void listen(VoidCallback f) => listeners.add(f);
  void unlisten(VoidCallback f) => listeners.remove(f);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    factory = FactoryWorld();
    world.add(factory);

    raw = Station('🫘 مخزن الكاكاو', StationKind.rawStorage, Vector2(140,220), Vector2(190,145));
    grinder = Station('⚙️ المطحنة', StationKind.grinder, Vector2(390,220), Vector2(175,145));
    mixer = Station('🌀 الخلاط', StationKind.mixer, Vector2(610,220), Vector2(175,145));
    heater = Station('🔥 التسخين', StationKind.heater, Vector2(830,220), Vector2(175,145));
    temperer = Station('❄️ Tempering', StationKind.temperer, Vector2(1050,220), Vector2(175,145));
    mold = Station('🍫 القوالب', StationKind.mold, Vector2(390,455), Vector2(175,135));
    cooler = Station('🧊 التبريد', StationKind.cooler, Vector2(610,455), Vector2(175,135));
    packer = Station('📦 التغليف', StationKind.packaging, Vector2(830,455), Vector2(175,135));
    warehouse = Station('🏪 المخزن', StationKind.warehouse, Vector2(1050,455), Vector2(175,135));
    orders = Station('🚚 الطلبات', StationKind.orderDesk, Vector2(1135,625), Vector2(190,95));

    conveyor = Conveyor(Vector2(170,370), 900);
    player = Player(this, Vector2(245,590));

    world.addAll([
      raw, grinder, mixer, heater, temperer, mold, cooler, packer,
      warehouse, orders, conveyor, player,
    ]);

    for (int i = 0; i < 4; i++) {
      world.add(Worker(Vector2(300 + i * 230, 590 - (i % 2) * 40), i));
    }
    await _load();
  }

  Future<void> _load() async {
    final d = await save.load();
    if (d == null) return;
    coins = (d['coins'] ?? coins) as int;
    gems = (d['gems'] ?? gems) as int;
    xp = (d['xp'] ?? xp) as int;
    level = (d['level'] ?? level) as int;
    packaged = (d['packaged'] ?? packaged) as int;
    day = (d['day'] ?? day) as int;
  }

  Future<void> persist() => save.save({
    'coins': coins, 'gems': gems, 'xp': xp, 'level': level,
    'packaged': packaged, 'day': day,
  });

  @override
  void update(double dt) {
    if (!paused) {
      timeOfDay += dt / 180;
      if (timeOfDay >= 1) { timeOfDay = 0; day++; }
    }
    super.update(dt);
    changed();
  }

  void tapAt(Vector2 p) {
    if (player.position.distanceTo(p) < 60) {
      interact();
    } else {
      player.target = p;
    }
  }

  void interact() {
    final p = player.position;
    if (p.distanceTo(raw.position) < 120 && carried == 0) {
      carried = 4;
      notice = 'حملت 4 كاكاو';
    } else if (p.distanceTo(grinder.position) < 115 && carried > 0) {
      grinder.input += carried; carried = 0;
      notice = 'تم إدخال الكاكاو إلى المطحنة';
    } else if (p.distanceTo(mixer.position) < 115 && grinder.output > 0) {
      mixer.input += grinder.output; grinder.output = 0;
      notice = 'الخلاط استلم Cocoa Mass';
    } else if (p.distanceTo(heater.position) < 115 && mixer.output > 0) {
      heater.input += mixer.output; mixer.output = 0;
      notice = 'التسخين بدأ';
    } else if (p.distanceTo(temperer.position) < 115 && heater.output > 0) {
      temperer.input += heater.output; heater.output = 0;
      notice = 'Temperering لتحسين الجودة';
    } else if (p.distanceTo(mold.position) < 115 && temperer.output > 0) {
      mold.input += temperer.output; temperer.output = 0;
      notice = 'تشكيل ألواح الشوكولاتة';
    } else if (p.distanceTo(cooler.position) < 115 && mold.output > 0) {
      cooler.input += mold.output; mold.output = 0;
      notice = 'تبريد المنتج';
    } else if (p.distanceTo(packer.position) < 115 && cooler.output > 0) {
      packer.input += cooler.output; cooler.output = 0;
      notice = 'التغليف يعمل';
    } else if (p.distanceTo(warehouse.position) < 115 && packer.output > 0) {
      packaged += packer.output; packer.output = 0;
      notice = 'تم تخزين المنتج المغلف';
    } else if (p.distanceTo(orders.position) < 125 && packaged > 0) {
      final n = math.min(3, packaged);
      packaged -= n; coins += n * 70; xp += n * 10;
      if (xp >= level * 100) { xp -= level * 100; level++; }
      notice = 'تم تسليم $n منتجات للطلب';
    }
    persist();
  }

  void upgradeMachine() {
    final cost = machineLevel * 400;
    if (coins >= cost) { coins -= cost; machineLevel++; notice = 'ترقية الآلات إلى Lv.$machineLevel'; persist(); }
  }

  void upgradeBelt() {
    final cost = beltLevel * 300;
    if (coins >= cost) { coins -= cost; beltLevel++; conveyor.speed += 35; notice = 'السير أسرع الآن'; persist(); }
  }

  void upgradeWarehouse() {
    final cost = warehouseLevel * 500;
    if (coins >= cost) { coins -= cost; warehouseLevel++; notice = 'سعة المخزن ارتفعت'; persist(); }
  }
}

class FactoryWorld extends Component {
  @override
  void render(Canvas c) {
    c.drawRect(const Rect.fromLTWH(0,0,1280,720), Paint()..color = const Color(0xFF17100D));
    c.drawRect(const Rect.fromLTWH(28,85,1224,610), Paint()..color = const Color(0xFF4B3426));
    final grid = Paint()..color = const Color(0xFF624636)..strokeWidth = 2;
    for (double x=28;x<1250;x+=70) c.drawLine(Offset(x,85),Offset(x,695),grid);
    for (double y=85;y<695;y+=70) c.drawLine(Offset(28,y),Offset(1250,y),grid);
    c.drawRect(const Rect.fromLTWH(28,85,1224,55),Paint()..color=const Color(0xFF2B1B15));
    _txt(c,'CHOCOLATE FACTORY',52,100,25,const Color(0xFFFFD18A));
  }
}

class Player extends PositionComponent {
  final ChocolateGame game;
  Vector2? target;
  int anim = 0;
  Player(this.game, Vector2 p):super(position:p,size:Vector2.all(52),anchor:Anchor.center);
  @override void update(double dt) {
    super.update(dt);
    final t=target;
    if(t!=null){
      final d = t - position;
      if(d.length>5){position+=d.normalized()*240*dt;anim++;}
      else target=null;
    }
    position.x=position.x.clamp(55,1225);
    position.y=position.y.clamp(145,680);
  }
  @override void render(Canvas c){
    c.drawOval(const Rect.fromLTWH(4,39,44,10),Paint()..color=Colors.black38);
    c.drawCircle(const Offset(26,13),11,Paint()..color=const Color(0xFFF2C49C));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(11,24,30,23),const Radius.circular(8)),Paint()..color=const Color(0xFFD89A4F));
    c.drawRect(const Rect.fromLTWH(15,0,23,6),Paint()..color=const Color(0xFF5A2B18));
    if(game.carried>0){
      c.drawCircle(const Offset(26,2),9,Paint()..color=const Color(0xFF6B321D));
    }
  }
}

class Station extends PositionComponent {
  final String title; final StationKind kind;
  int input=0, output=0; double progress=0;
  Station(this.title,this.kind,Vector2 p,Vector2 s):super(position:p,size:s,anchor:Anchor.center);
  @override void update(double dt){
    super.update(dt);
    if(input>0){
      progress += dt;
      if(progress >= 2.5){
        final n = math.min(input, 2);
        input-=n; output+=n; progress=0;
      }
    }
  }
  @override void render(Canvas c){
    final base = kind==StationKind.rawStorage ? const Color(0xFF6C482E) :
      kind==StationKind.packaging ? const Color(0xFF6C4B82) :
      kind==StationKind.warehouse ? const Color(0xFF40594C) :
      kind==StationKind.orderDesk ? const Color(0xFF3E566B) :
      const Color(0xFF765039);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0,0,size.x,size.y),const Radius.circular(18)),Paint()..color=base);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10,10,size.x-20,42),const Radius.circular(10)),Paint()..color=Colors.black26);
    _txt(c,title,12,20,15,Colors.white);
    _txt(c,'IN $input   OUT $output',15,size.y-32,12,const Color(0xFFFFD39B));
    if(input>0){
      final w=(size.x-30)*(progress/2.5).clamp(0,1);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(15,size.y-18,w,7),const Radius.circular(4)),Paint()..color=Colors.amber);
    }
    if(kind==StationKind.grinder || kind==StationKind.mixer || kind==StationKind.heater){
      c.drawCircle(Offset(size.x/2,83),27,Paint()..color=const Color(0xFF241612));
      c.drawCircle(Offset(size.x/2,83),16,Paint()..color=const Color(0xFFB66E34));
    }
  }
}

class Conveyor extends PositionComponent {
  double speed=60,offset=0;
  Conveyor(Vector2 p,double width):super(position:p,size:Vector2(width,58),anchor:Anchor.center);
  @override void update(double dt){super.update(dt);offset=(offset+speed*dt)%62;}
  @override void render(Canvas c){
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0,0,size.x,size.y),const Radius.circular(13)),Paint()..color=const Color(0xFF151515));
    for(double x=-62+offset;x<size.x+20;x+=62){
      c.drawRect(Rect.fromLTWH(x,8,38,42),Paint()..color=const Color(0xFFB9773B));
      c.drawCircle(Offset(x+19,29),7,Paint()..color=const Color(0xFF5E2A18));
    }
  }
}

class Worker extends PositionComponent {
  final int id; double t=0; late Vector2 base;
  Worker(Vector2 p,this.id):super(position:p,size:Vector2.all(42),anchor:Anchor.center){base=p.clone();}
  @override void update(double dt){super.update(dt);t+=dt;position.x=base.x+math.sin(t*.55+id)*55;position.y=base.y+math.cos(t*.8+id)*20;}
  @override void render(Canvas c){
    c.drawCircle(const Offset(21,10),8,Paint()..color=const Color(0xFFF0C29A));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(8,17,26,19),const Radius.circular(7)),Paint()..color=Color.lerp(const Color(0xFF4D79A6),const Color(0xFFB26732),id/4)!);
  }
}

void _txt(Canvas c,String s,double x,double y,double size,Color color){
  final p=TextPainter(text:TextSpan(text:s,style:TextStyle(color:color,fontSize:size,fontWeight:FontWeight.bold)),textDirection:TextDirection.ltr)..layout();
  p.paint(c,Offset(x,y));
}
