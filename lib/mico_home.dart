

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:micodokter_app/helper/page_route.dart';
import 'package:micodokter_app/services/mico_cekroomchat.dart';
import 'package:micodokter_app/services/mico_cekroomvideo.dart';
import 'package:micodokter_app/services/mico_chatroom.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => new _HomeState();
}


class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child:
                      RaisedButton(
                        child: Text("Chat"),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              new MaterialPageRoute(
                                  builder: (BuildContext context) => ChatRoom()));
                        },
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child:
                RaisedButton(
                  child: Text("Video"),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                        new MaterialPageRoute(
                            builder: (BuildContext context) => CekRoomVideo()));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );

  }
}