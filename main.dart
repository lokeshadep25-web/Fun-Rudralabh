
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const FunRudralabhApp());

const gold = Color(0xFFF0C75E);
const deep = Color(0xFF160506);
const panel = Color(0xFF2A0909);
const green = Color(0xFF2AA66A);

class AppState {
  static String username = 'Guest';
  static int points = 12450;
  static final List<String> history = [];

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    username = p.getString('username') ?? 'Guest';
    points = p.getInt('points') ?? 12450;
  }

  static Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('username', username);
    await p.setInt('points', points);
  }
}

class FunRudralabhApp extends StatelessWidget {
  const FunRudralabhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fun Rudralabh',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deep,
        colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.dark),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF3A1515),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginState();
}
class _LoginState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool hide = true;

  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  Future<void> login() async {
    AppState.username = email.text.trim().isEmpty ? 'Guest' : email.text.trim();
    await AppState.save();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Launcher()));
  }

  @override
  Widget build(BuildContext context) => AuthShell(
    title: 'WELCOME BACK',
    subtitle: 'Login to continue to the Game Launcher',
    fields: [
      TextField(controller: email, decoration: const InputDecoration(
        labelText: 'USERNAME OR EMAIL', prefixIcon: Icon(Icons.person, color: gold))),
      const SizedBox(height: 14),
      TextField(controller: password, obscureText: hide, decoration: InputDecoration(
        labelText: 'PASSWORD', prefixIcon: const Icon(Icons.lock, color: gold),
        suffixIcon: IconButton(onPressed: () => setState(() => hide = !hide),
          icon: Icon(hide ? Icons.visibility : Icons.visibility_off)))),
    ],
    button: 'LOGIN',
    onPressed: login,
    footer: TextButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
      child: const Text("Don't have an account?  Sign Up")),
  );
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override State<SignupScreen> createState() => _SignupState();
}
class _SignupState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override void dispose() { name.dispose(); email.dispose(); password.dispose(); super.dispose(); }

  Future<void> signup() async {
    AppState.username = name.text.trim().isEmpty ? 'Player' : name.text.trim();
    await AppState.save();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Launcher()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => AuthShell(
    title: 'CREATE ACCOUNT',
    subtitle: 'Create your free-to-play player profile',
    fields: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'DISPLAY NAME')),
      const SizedBox(height: 14),
      TextField(controller: email, decoration: const InputDecoration(labelText: 'EMAIL')),
      const SizedBox(height: 14),
      TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'PASSWORD')),
    ],
    button: 'SIGN UP',
    onPressed: signup,
    footer: TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Already have an account? Login')),
  );
}

class AuthShell extends StatelessWidget {
  final String title, subtitle, button;
  final List<Widget> fields;
  final VoidCallback onPressed;
  final Widget footer;
  const AuthShell({super.key, required this.title, required this.subtitle,
    required this.fields, required this.button, required this.onPressed, required this.footer});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Container(
      decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment.topRight, radius: 1.25, colors: [Color(0xFF4A0D0D), deep])),
      child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            color: const Color(0xE5260909),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Color(0xFFB98A35), width: 1.5)),
            child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
              Image.asset('assets/fun_rudralabh_logo.jpg', height: 130),
              Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: gold)),
              const SizedBox(height: 6), Text(subtitle),
              const SizedBox(height: 22), ...fields,
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 54,
                child: ElevatedButton(onPressed: onPressed,
                  style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                  child: Text(button, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)))),
              const SizedBox(height: 10), footer,
              const Text('Free-to-play virtual points only', style: TextStyle(color: Colors.white54)),
            ])),
          ),
        ),
      )),
    )),
  );
}

class Launcher extends StatefulWidget {
  const Launcher({super.key});
  @override State<Launcher> createState() => _LauncherState();
}
class _LauncherState extends State<Launcher> {
  Future<void> refresh() async { await AppState.load(); setState(() {}); }

  @override
  void initState() { super.initState(); AppState.load().then((_) { if (mounted) setState(() {}); }); }

  @override
  Widget build(BuildContext context) {
    final games = [
      ['Kuber Chakra', 'Wheel + virtual points', Icons.casino, const KuberGame()],
      ['Butterfly', 'Catch & virtual points', Icons.flutter_dash, const ButterflyGame()],
      ['Joker 11', 'Card challenge', Icons.style, const JokerGame()],
      ['Lucky Card', 'Virtual card reveal', Icons.cards, const LuckyCardGame()],
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: panel,
        title: const Text('PREMIUM GAME LAUNCHER', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: Text('${AppState.points} PTS',
              style: const TextStyle(color: gold, fontWeight: FontWeight.bold)))),
          IconButton(onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProfileScreen())).then((_) => refresh()),
            icon: const Icon(Icons.person)),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: RadialGradient(
          center: Alignment.topCenter, radius: 1.2, colors: [Color(0xFF4A0D0D), deep])),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text('Welcome, ${AppState.username}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: gold)),
          const SizedBox(height: 3),
          const Text('Select a game • Free-to-play'),
          const SizedBox(height: 18),
          ...games.map((g) => Card(
            color: const Color(0xE62A0909),
            margin: const EdgeInsets.only(bottom: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFF8D642A)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(width: 62, height: 62,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(colors: [Color(0xFF174A35), Color(0xFF5A250D)])),
                child: Icon(g[2] as IconData, color: gold, size: 34)),
              title: Text(g[0] as String, style: const TextStyle(fontWeight: FontWeight.w900, color: gold)),
              subtitle: Text(g[1] as String),
              trailing: const Icon(Icons.play_circle_fill, color: green, size: 40),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => g[3] as Widget))
                .then((_) => refresh()),
            ),
          )),
          const SizedBox(height: 6),
          const Text('Virtual points have no cash value.', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54)),
        ]),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('PROFILE'), backgroundColor: panel),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      const CircleAvatar(radius: 46, backgroundColor: gold, child: Icon(Icons.person, size: 52, color: Colors.black)),
      const SizedBox(height: 15),
      Center(child: Text(AppState.username, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: gold))),
      const SizedBox(height: 20),
      Card(color: panel, child: ListTile(
        leading: const Icon(Icons.stars, color: gold), title: const Text('Virtual Points'),
        trailing: Text('${AppState.points}', style: const TextStyle(color: gold, fontWeight: FontWeight.bold)))),
      Card(color: panel, child: const ListTile(
        leading: Icon(Icons.history, color: gold), title: Text('Game History'))),
      const SizedBox(height: 20),
      const Text('Account settings and secure cloud authentication can be connected here next.',
        textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
    ]),
  );
}

class GameShell extends StatelessWidget {
  final String title; final Widget child;
  const GameShell({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), backgroundColor: panel),
    body: Container(
      decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment.topCenter, radius: 1.15, colors: [Color(0xFF4A0D0D), deep])),
      child: SafeArea(child: child),
    ),
  );
}

void addPoints(BuildContext context, int amount, String game) {
  AppState.points += amount;
  AppState.history.insert(0, '$game  +$amount points');
  AppState.save();
  showDialog(context: context, builder: (_) => AlertDialog(
    title: Text('$game Result', style: const TextStyle(color: gold)),
    content: Text('You earned $amount virtual points!'),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
  ));
}

class KuberGame extends StatefulWidget {
  const KuberGame({super.key});
  @override State<KuberGame> createState() => _KuberState();
}
class _KuberState extends State<KuberGame> with SingleTickerProviderStateMixin {
  late AnimationController c; double rotation = 0; bool spinning = false;
  final values = [50,100,150,250,500,750,1000,1500];
  @override void initState() { super.initState(); c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600)); }
  @override void dispose() { c.dispose(); super.dispose(); }
  Future<void> spin() async {
    if (spinning) return;
    setState(() => spinning = true);
    rotation += 5.8;
    await c.forward(from: 0);
    if (!mounted) return;
    setState(() => spinning = false);
    addPoints(context, values[DateTime.now().millisecond % values.length], 'Kuber Chakra');
  }
  @override
  Widget build(BuildContext context) => GameShell(title: 'KUBER CHAKRA',
    child: Column(children: [
      const SizedBox(height: 15),
      Text('${AppState.points} VIRTUAL POINTS', style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
      Expanded(child: AnimatedBuilder(animation: c, builder: (_, __) =>
        Center(child: Transform.rotate(angle: rotation * c.value, child: const _Wheel())))),
      Padding(padding: const EdgeInsets.all(18), child: SizedBox(width: double.infinity, height: 54,
        child: ElevatedButton(onPressed: spinning ? null : spin,
          style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
          child: Text(spinning ? 'SPINNING…' : 'SPIN FOR POINTS',
            style: const TextStyle(fontWeight: FontWeight.w900))))),
    ]));
}

class _Wheel extends StatelessWidget {
  const _Wheel();
  @override Widget build(BuildContext context) => CustomPaint(size: const Size(300,300), painter: _WheelPainter());
}
class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero), r = size.width/2-8, p = Paint();
    final vals = [50,100,150,250,500,750,1000,1500];
    for (var i=0;i<8;i++) {
      p.color = i.isEven ? const Color(0xFF6B3BA8) : const Color(0xFF9A5B1C);
      canvas.drawArc(Rect.fromCircle(center:center,radius:r), -1.5708+i*0.7854, 0.7854, true, p);
    }
    p.color = gold; p.style = PaintingStyle.stroke; p.strokeWidth=7; canvas.drawCircle(center,r,p);
    p.style=PaintingStyle.fill;
    for (var i=0;i<8;i++) {
      final a=-1.5708+(i+.5)*0.7854;
      final tp=TextPainter(text:TextSpan(text:'${vals[i]}',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:13)),textDirection:TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(center.dx+cos(a)*r*.62-tp.width/2, center.dy+sin(a)*r*.62-tp.height/2));
    }
    p.color=gold; canvas.drawCircle(center, 38, p);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}

class ButterflyGame extends StatefulWidget {
  const ButterflyGame({super.key});
  @override State<ButterflyGame> createState()=>_ButterflyState();
}
class _ButterflyState extends State<ButterflyGame> {
  Offset pos=const Offset(.5,.45);
  void catchIt(){
    setState(() => pos=Offset(.15+(DateTime.now().millisecond%700)/1000, .2+(DateTime.now().microsecond%600)/1000));
    addPoints(context, 100, 'Butterfly');
  }
  @override Widget build(BuildContext context)=>GameShell(title:'BUTTERFLY',
    child: LayoutBuilder(builder:(_,b)=>Stack(children:[
      const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(colors:[Color(0xFF9BE8FF),Color(0xFF278EC2)],begin:Alignment.topCenter,end:Alignment.bottomCenter)))),
      Positioned(left:pos.dx*(b.maxWidth-80),top:pos.dy*(b.maxHeight-90),
        child: GestureDetector(onTap:catchIt,child:const Text('🦋',style:TextStyle(fontSize:74)))),
      const Positioned(bottom:20,left:0,right:0,child:Text('Tap the butterfly to earn virtual points',
        textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontSize:18))),
    ]));
}

class JokerGame extends StatefulWidget {
  const JokerGame({super.key});
  @override State<JokerGame> createState()=>_JokerState();
}
class _JokerState extends State<JokerGame> {
  int? selected; final cards=['A','K','Q','J','10','9'];
  void pick(int i){if(selected!=null)return;setState(()=>selected=i);addPoints(context,100,'Joker 11');}
  @override Widget build(BuildContext context)=>GameShell(title:'JOKER 11',child:Column(children:[
    const SizedBox(height:18),const Text('CARD CHALLENGE',style:TextStyle(color:gold,fontSize:22,fontWeight:FontWeight.w900)),
    Expanded(child:GridView.builder(padding:const EdgeInsets.all(18),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount:3,crossAxisSpacing:12,mainAxisSpacing:12),itemCount:cards.length,
      itemBuilder:(_,i)=>GestureDetector(onTap:()=>pick(i),child:Card(color:selected==i?green:const Color(0xFF6B1B20),
        shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14),side:const BorderSide(color:gold)),
        child:Center(child:Text(selected==i?cards[i]:'?',style:const TextStyle(fontSize:34,fontWeight:FontWeight.w900))))))),
    ElevatedButton(onPressed:()=>setState(()=>selected=null),child:const Text('NEW ROUND')),const SizedBox(height:15)
  ]));
}

class LuckyCardGame extends StatefulWidget {
  const LuckyCardGame({super.key});
  @override State<LuckyCardGame> createState()=>_LuckyState();
}
class _LuckyState extends State<LuckyCardGame>{
  String result='?';
  void reveal(){setState(()=>result=['A♠','K♥','Q♦','J♣','10♠','9♥'][DateTime.now().millisecond%6]);addPoints(context,75,'Lucky Card');}
  @override Widget build(BuildContext context)=>GameShell(title:'LUCKY CARD',child:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Text('VIRTUAL CARD REVEAL',style:TextStyle(color:gold,fontSize:22,fontWeight:FontWeight.w900)),
    const SizedBox(height:25),
    Container(width:180,height:250,decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),
      gradient:const LinearGradient(colors:[Color(0xFF7A45B5),Color(0xFF2B0E4A)]),border:Border.all(color:gold,width:3)),
      child:Center(child:Text(result,style:const TextStyle(fontSize:55,fontWeight:FontWeight.w900)))),
    const SizedBox(height:28),
    ElevatedButton(onPressed:reveal,style:ElevatedButton.styleFrom(backgroundColor:gold,foregroundColor:Colors.black),
      child:const Text('REVEAL CARD',style:TextStyle(fontWeight:FontWeight.w900))),
  ])));
}
