


import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:micodokter_app/helper/connection_tes.dart';
import 'package:micodokter_app/helper/link_api.dart';
import 'package:micodokter_app/helper/page_route.dart';
import 'package:micodokter_app/services/mico_videoroom.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
class CekRoomVideo extends StatefulWidget {
  @override
  _CekRoomVideoState createState() => new _CekRoomVideoState();
}

class _CekRoomVideoState extends State<CekRoomVideo> {
  ClientRole _role = ClientRole.Broadcaster;
  String getDokterID = "CL/1323-005";
  Future<bool> _onWillPop() async {
    //Toast.show("Toast plugin app", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
  }
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }



  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  _connect() async {
    Checkconnection().check().then((internet){
      if (internet != null && internet) {
        // Internet Present Case
      } else {
        showToast("Koneksi terputus..", gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      }
    });
  }


  int uidq = 0;
  int max = 999999;
  int min = 9999;
  Random rnd = new Random();

  String getAppkode, resultq = "";
  _getVideoDetail() async {
    final response = await http.get(
        applink+"api_script.php?do=getdata_videoroomdetaildokter&id="+getDokterID);
    Map data2 = jsonDecode(response.body);
    setState(() {
      getAppkode = "APP-1120-0020=";
      uidq = min + rnd.nextInt(max - min);
    });
  }


  String tokenagora, getAPPid = "0";
  _getTokenMira() async {
    final response = await http.get(
        applink+"api_script.php?do=get_agoratoken&channel="+getAppkode.toString()+"&uid="+uidq.toString());
    Map data2 = jsonDecode(response.body);
    setState(() {
      tokenagora = data2["a"].toString();
      getAPPid = data2["b"].toString();
    });
  }


  startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      Navigator.pushReplacement(context, ExitPage(page: VideoRoom(
          channelName: getAppkode.toString(),
          role: _role,
          uidq : uidq,
          tokenq : tokenagora,
          appidq : getAPPid)));
    });
  }


  _prepare() async {
    //await _session();
    await _connect();
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    await _getVideoDetail();
    await _getTokenMira();
    await startSplashScreen();
  }



  @override
  void initState() {
    super.initState();
    _prepare();
  }


  @override
  Widget build(BuildContext context) {
   return WillPopScope(
     onWillPop: _onWillPop,
     child: Scaffold(
       body: Container(
         height: double.infinity,
         width: double.infinity,
         color: Colors.white,
         child:             Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             SizedBox(
                 width: 50, height: 50, child: CircularProgressIndicator()),
             Padding(padding: const EdgeInsets.all(25.0)),
             Text(
               "Menyiapkan room konsultasi anda...",
               style: TextStyle(fontFamily: 'VarelaRound', fontSize: 13),
             ),
             Padding(
               padding: const EdgeInsets.only(top:2),
               child:
               Text(
                 "Mohon menunggu sebentar",
                 style: TextStyle(fontFamily: 'VarelaRound', fontSize: 13),
               ),
             )
           ],
         ),
       ),
     ),
   );

  }
}