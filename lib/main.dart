import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_calling/videocall_screen.dart';

const String appId = "1be0fa04f96344838da35ee0cb798d63";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, home:
  MyApp()
  ));
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
         body: Stack(
           alignment: Alignment.bottomCenter,
           children: [
             Container(
                 height:MediaQuery.of(context).size.height,
                 width:MediaQuery.of(context).size.width,
                 //color:const Color(0xff023bf6)
             color:Colors.white
             ),
             Positioned(
               bottom: 300,
               child: SizedBox(
                 height: 380,
                 width: 380,
                 child:Image.asset('assets/images.jpg',fit: BoxFit.contain,)
               ),
             ),
             Container(
               height:MediaQuery.of(context).size.height/4,
               width:MediaQuery.of(context).size.width,
               decoration: const BoxDecoration(
                 borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                 color: Colors.white
               ),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                 const Text('WELCOME',style:TextStyle(color:Colors.black,fontWeight: FontWeight.bold,fontSize: 28)),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children:[  ElevatedButton(
                     onPressed: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoCallScreen()));
                     },
                   style: ButtonStyle(
                       minimumSize: MaterialStateProperty.all(const Size(110, 50)),
                     backgroundColor: MaterialStateProperty.all(const Color(0xff023bf6)),
                     shadowColor: MaterialStateProperty.all(Colors.tealAccent),
                     elevation:  MaterialStateProperty.all(6),
                     shape:  MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)))
                   ),
                     child: const Center(child: Text('JOIN',style: TextStyle(color:Colors.white,fontSize: 26,fontWeight: FontWeight.w500),)),
                   ),
                   ElevatedButton(
                     onPressed: (){
                       SystemNavigator.pop();
                     },
                     style: ButtonStyle(
                       minimumSize: MaterialStateProperty.all(const Size(110, 50)),
                         backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                         shadowColor: MaterialStateProperty.all(Colors.tealAccent),
                         elevation:  MaterialStateProperty.all(6),
                         shape:  MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)))),
                     child: const Center(child: Text('EXIT',style: TextStyle(color:Colors.white,fontWeight: FontWeight.w500,fontSize: 26),)),
                   )
                 ]
                 ),

                 ],
               ),
               ),

           ],
         ),
    );
  }
}

