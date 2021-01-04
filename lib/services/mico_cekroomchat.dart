




import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:micodokter_app/helper/link_api.dart';
import 'package:micodokter_app/helper/page_route.dart';
import 'package:micodokter_app/services/mico_chatroom.dart';

class CekRoomChat extends StatefulWidget {
  @override
  _CekRoomChatState createState() => new _CekRoomChatState();
}


class _CekRoomChatState extends State<CekRoomChat> {

  void loadData() async {
    setState(() {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
              builder: (BuildContext context) => ChatRoom()));
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }
}