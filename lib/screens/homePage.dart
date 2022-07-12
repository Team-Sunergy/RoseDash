// @dart=2.9
import 'package:flutter/material.dart';

// Custom Widgets
import '../widgets/CenterIndicators.dart';
import '../widgets/Warnings.dart';
import './FullScreenNav.dart';
import '../widgets/Nav.dart';
import '../widgets/Speedometer.dart';
import '../widgets/VoltMeter.dart';
import '../widgets/TroubleCodes.dart';
import '../widgets/TargetSpeedForm.dart';

class HomePage extends StatefulWidget {
  // This is for the IndexedStack
  static int leftIndex = 0;
  static int rightIndex = 0;
  @override
  State<StatefulWidget> createState() => HomePageState();
}
class UnderHood {
  int cellId;
  double instV;
  bool isShunting;
  double intRes;
  double openV;
}

class HomePageState extends State<HomePage> {
  Nav navInstance;

  @override
  void initState() {
    // Calling superclass initState
    super.initState();
    navInstance = new Nav();
  }

  void changeToTCPage() {
    if (this.mounted) {
      setState(() {
        HomePage.leftIndex = 2;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        body: Column(children: [
          Container(height: 150,),
          Row(
            children: [
              VerticalDivider(width: 50),
              Column (
                children: [
              Container(
                  height: 450,
                  width: 450,
                  child:
                  IndexedStack(
                    index: HomePage.leftIndex,
                    children: [Container(margin: EdgeInsets.symmetric(
                        vertical: 0, horizontal: 0),
                        child: Speedometer(timeOn: true)),
                      TargetSpeedForm(),
                      Center(child: TroubleCodes())

                    ],
                  )),
                  Row(
                      children: [
                        VerticalDivider(width: 15),
                        if (HomePage.leftIndex > 0) ElevatedButton(onPressed: () {
                          setState(() {
                            --HomePage.leftIndex;
                          });
                        },
                          child: Icon(
                            Icons.arrow_back_ios_new, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a).withOpacity(0),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (HomePage.leftIndex == 0) VerticalDivider(width: 65),
                        VerticalDivider(width: 150),
                        if (HomePage.leftIndex < 2 ) ElevatedButton(onPressed: () {
                          setState(() {
                            ++HomePage.leftIndex;
                          });
                        },
                          child: Icon(Icons.arrow_forward_ios, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a).withOpacity(0),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (HomePage.leftIndex == 2) VerticalDivider(width: 65),
                      ]
                  ),
                ],
              ),
              VerticalDivider(width: 50),
              Column( children: [
                Container( height: 450, child:
                CenterIndicators(),), Container(
                margin: EdgeInsets.only(right: 20),
                child:
                Warnings(callback: () => setState(() => HomePage.leftIndex = 2),),)
              ]),
              VerticalDivider(width: 50),
              Column(
                children: [
                  Container(height: 10,),
                  Container(
                      height: 450,
                      width: 450,
                      child:
                      IndexedStack(
                        index: HomePage.rightIndex,
                        children: [
                          Container(margin: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 30),
                              child: VoltMeter()),
                          Center(child: ClipRRect(borderRadius: BorderRadius
                              .horizontal(left: Radius.elliptical(150, 150),
                              right: Radius.elliptical(150, 150)),
                              child: Container(
                                  height: 500, width: 500, child: navInstance))),
                          Center(child: VoltMeter())
                        ],
                      )),
                  Container(height: 10,),
                  Row(
                      children: [
                        VerticalDivider(width: 15),
                        if (HomePage.rightIndex > 0) ElevatedButton(onPressed: () {
                          setState(() {
                            --HomePage.rightIndex;
                          });
                        },
                          child: Icon(
                            Icons.arrow_back_ios_new, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a).withOpacity(0),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (HomePage.rightIndex == 0) VerticalDivider(width: 65),
                        if (HomePage.rightIndex != 1)
                          VerticalDivider(width: 150),
                        if (HomePage.rightIndex == 1)
                          VerticalDivider(width: 44,),
                        if (HomePage.rightIndex == 1)
                           ElevatedButton(onPressed: () {
                            setState(() {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenNav(nav: navInstance,)),);
                            });
                          },
                            child: Icon(Icons.fullscreen, color: Color(
                                0xffedd711), size: 40,),
                            style: ElevatedButton.styleFrom(primary: Color(
                                0xff03050a).withOpacity(0),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(11),),),
                        if (HomePage.rightIndex == 1)
                          VerticalDivider(width: 44),
                        if (HomePage.rightIndex < 2 ) ElevatedButton(onPressed: () {
                          setState(() {
                            ++HomePage.rightIndex;
                          });
                        },
                          child: Icon(Icons.arrow_forward_ios, color: Color(
                              0xffedd711),),
                          style: ElevatedButton.styleFrom(primary: Color(
                              0xff03050a).withOpacity(0),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),),),
                        if (HomePage.rightIndex == 2) VerticalDivider(width: 65),
                      ]
                  ),
                  Container(height: 10,),
                ],
              )
            ],
          ),
        ])
    );
  }
}