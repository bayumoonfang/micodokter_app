
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:micodokter_app/helper/link_api.dart';
import 'package:micodokter_app/helper/page_route.dart';
import 'package:micodokter_app/mico_home.dart';
import 'package:micodokter_app/services/mico_chatdetailimage.dart';



class ChatRoom extends StatefulWidget{
  @override
  _ChatRoomState createState() => new _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  List data, data2;
  String getEmail, getPhone = "";
  String getDokterID = "CL/1323-005";
  ScrollController _scrollController;
  final TextEditingController _textController = new TextEditingController();
  FocusNode myFocusNode;
  bool _isVisible = false;
  File galleryFile;
  String Base64;



  String getInvNumber, getNamaPasien = "...";
  String getAppKode = "0";
  _getChatDetail() async {
    final response = await http.get(
        applink+"api_script.php?do=getdata_chatdetaildokternew&id="+getDokterID.toString());
    Map dataq = jsonDecode(response.body);
    setState(() {
      getNamaPasien = dataq["b"].toString();
      getAppKode = dataq["a"].toString();
    });
  }



  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        //bottom
        _isVisible = false;
        _removeread();
      });
    }
    else if (_scrollController.offset == _scrollController.position.minScrollExtent ) {
      setState(() {
        //top
        _isVisible = false;
      });
    } else {
      _isVisible = true;
    }
  }



  loadData() async {
    //await _session();
    await _getChatDetail();
  }

  @override
  void initState() {
    super.initState();
    loadData();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _removeread();
  }





  Future<List> getDataChat2() async {
    final response = await http.get(
        applink+"api_script.php?do=getdata_chatnew&"
            "id="+getAppKode.toString());
    setState((){
      data = json.decode(response.body);
    });
  }


  Future<List> getDataChat3() async {
    final response = await http.get(
        applink+"api_script.php?do=getdata_countchatfixed&"
            "id="+getAppKode);
    setState((){
      data2 = json.decode(response.body);

    });
  }
  void _removeread() async {
    var url = applink+"api_script.php?do=action_removeread";
    http.post(url,
        body: {
          "id": getAppKode,
        });
  }


  _addchat() async {
    if(_textController.text.isEmpty) {
      return;
    } else {
      var url = applink+"api_script.php?do=addata_chatdokternew";
      http.post(url,
          body: {
            "messagetext": _textController.text,
            "idappointment": getAppKode
          });
      setState(() {
        _textController.clear();
        myFocusNode.requestFocus();
        //_isLoading = '0';
      });
    }
  }

  imageSelectorGallery() async {
    galleryFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    String fileName = galleryFile.path.split('/').last;
    Base64 = base64Encode((galleryFile.readAsBytesSync()));
    http.post(applink+"api_script.php?do=addata_chatimage2", body: {
      "image": Base64,
      "name": fileName,
      "id": getAppKode
    });
    print("You selected gallery image : " + Base64);
    setState(() {
      _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent);
    });
  }


  _doDeleteMessage(String IDMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text(),
            content: Text(
                "Apakah anda yakin untuk menghapus pesan ini  ?",
                style: TextStyle(fontFamily: 'VarelaRound', fontSize: 18)),
            actions: [
              new FlatButton(
                  onPressed: () {
                    _dodeletepesan(IDMessage);
                    Navigator.pop(context);
                    myFocusNode.dispose();
                  },
                  child:
                  Text("Iya", style: TextStyle(fontFamily: 'VarelaRound',
                      fontWeight: FontWeight.bold,
                      fontSize: 18))),
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                  Text("Tidak", style: TextStyle(fontFamily: 'VarelaRound',
                      fontWeight: FontWeight.bold,
                      fontSize: 14)))
            ],
          );
        });
  }

  void _dodeletepesan(String valID) {
    var url = applink+"api_script.php?do=action_deletechatuser";
    http.post(url,
        body: {
          "idmessage": valID
        });
  }


  void _dodeletepesanimage(String valID) {
    var url = applink+"api_script.php?do=action_deletechatimageuser";
    http.post(url,
        body: {
          "idmessage": valID
        });
  }


  _doDeleteMessageImage(String IDMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text(),
            content: Text(
                "Apakah anda yakin untuk menghapus pesan ini  ?",
                style: TextStyle(fontFamily: 'VarelaRound', fontSize: 14)),
            actions: [
              new FlatButton(
                  onPressed: () {
                    _dodeletepesanimage(IDMessage);
                    Navigator.pop(context);
                    myFocusNode.dispose();
                  },
                  child:
                  Text("Iya", style: TextStyle(fontFamily: 'VarelaRound',
                      fontWeight: FontWeight.bold,
                      fontSize: 18))),
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                  Text("Tidak", style: TextStyle(fontFamily: 'VarelaRound',
                      fontWeight: FontWeight.bold,
                      fontSize: 18)))
            ],
          );
        });
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(context, EnterPage(page: Home()));
  }



  @override
  Widget build(BuildContext context) {
   return WillPopScope(
     onWillPop: _onWillPop,
     child: Scaffold(
       appBar: new AppBar(
         //backgroundColor: HexColor("#075e55"),
         backgroundColor: HexColor("#602d98"),
         title: new Text(getNamaPasien,
             style: TextStyle(
                 color: Colors.white, fontFamily: 'VarelaRound', fontSize: 16)),
         leading: Builder(
           builder: (context) => IconButton(
             icon: new Icon(Icons.arrow_back),
             color: Colors.white,
             onPressed: () {
               Navigator.pushReplacement(context, EnterPage(page: Home()));
             },
           ),
         ),
       ),
       body: new Container(
     color: HexColor("#efe6dd"),
       child: Stack(
         children: [
           Column(
             children: [
               Padding(
                 padding : const EdgeInsets.only(top:15,bottom: 15),
                 child: Center(
                     child: Container(

                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(10),
                           color : HexColor("#d4eaf5"),
                           boxShadow: [
                             //BoxShadow(color: Colors.white, spreadRadius: 1),
                           ],
                         ),
                         child: Padding(
                           padding: const EdgeInsets.only(left: 10  ,right: 10,top: 6,bottom: 6),
                           child: Text(formatDate(
                             // DateTime.now(), [dd, '-', mm, '-', yy, ' ', HH, ':', nn]),
                               DateTime.now(), [dd, ' ', MM, ' ', yyyy]),
                               style: TextStyle(
                                 fontSize: 12,
                                 color: HexColor("#516067"),
                                 fontFamily: 'VarelaRound',)),
                         )
                     )
                 ),
               ),
               Flexible(
                   child: Container(
                       color: HexColor("#efe6dd"),
                       height: double.infinity,
                       margin: const EdgeInsets.only(bottom: 1.0),
                       child: new FutureBuilder(
                           future: getDataChat2(),
                           builder: (context, snapshot) {
                             return ListView.builder(
                                 controller: _scrollController,
                                 shrinkWrap: true,
                                 padding: new EdgeInsets.only(
                                     left: 15.0, right: 15.0, bottom: 60.0),
                                 reverse: false,
                                 itemCount:
                                 data == null ? 0 : data.length,
                                 itemBuilder: (context, i) {
                                   if (data[i]["d"] == '2') {
                                     return Column(children: [
                                       Padding(
                                         padding: const EdgeInsets.only(top:5),
                                       ),
                                       Align(
                                           alignment: Alignment.bottomLeft,
                                           child: Container(
                                               alignment: Alignment.bottomLeft,
                                               padding: const EdgeInsets.only(
                                                   top: 0, bottom: 0),
                                               child: Wrap(
                                                 children: <Widget>[
                                                   Container(
                                                       decoration: BoxDecoration(
                                                         borderRadius: BorderRadius.circular(10),
                                                         color : HexColor("#ffffff"),
                                                         boxShadow: [
                                                           //BoxShadow(color: Colors.white, spreadRadius: 1),
                                                         ],
                                                       ),
                                                       child :
                                                       data[i]["e"] != 'Message has been deleted..' ?
                                                       Padding(
                                                           padding: const EdgeInsets.all(10.0),
                                                           child:
                                                           data[i]["h"] != '' && data[i]["d"] == '1' ?
                                                           GestureDetector(
                                                             child: Hero(
                                                                 tag: data[i]["h"],
                                                                 child :
                                                                 Image(
                                                                   image: NetworkImage(applink+"media/imgchat/"+ data[i]["h"]),
                                                                   height: 160,
                                                                   width: 160,
                                                                 )),
                                                             onTap: (){
                                                               Navigator.of(context).push(
                                                                   new MaterialPageRoute(
                                                                       builder: (BuildContext context) => DetailChatImage(data[i]["h"].toString())));
                                                             },
                                                             onLongPress: (){
                                                               //_doDeleteMessageImage(data[i]["i"].toString());
                                                             },
                                                           )
                                                               :
                                                           GestureDetector(
                                                             child :
                                                             Text(data[i]["e"],
                                                                 style: TextStyle(
                                                                   fontSize: 14,
                                                                   fontFamily: 'VarelaRound',
                                                                 )),
                                                             onLongPress: (){
                                                               // _doDeleteMessage(data[i]["i"].toString());
                                                             },
                                                           )
                                                       )
                                                           :
                                                       Padding (
                                                           padding: const EdgeInsets.all(10),
                                                           child :
                                                           Text(data[i]["e"],
                                                               style: TextStyle(
                                                                   fontSize: 14,
                                                                   fontFamily: 'VarelaRound',
                                                                   fontStyle: FontStyle.italic
                                                               )))
                                                   ),

                                                 ],
                                               )
                                           )
                                       ),
                                       Align(
                                           alignment: Alignment.bottomLeft,
                                           child: Container(
                                             padding: const EdgeInsets.only(
                                                 left: 3.0, top: 5),
                                             child: Text(
                                                 data[i]["g"],
                                                 style: TextStyle(
                                                   fontSize: 8,
                                                   fontFamily: 'VarelaRound',
                                                 )),
                                           )),
                                       Padding(
                                           padding: const EdgeInsets.only(bottom: 0.0))
                                     ]);
                                   } else {
                                     return
                                       Padding(
                                           padding: const EdgeInsets.only(top:0),
                                           child :
                                           Column(children: [
                                             Align(
                                                 alignment: Alignment.centerRight,
                                                 child: Container(
                                                     padding: const EdgeInsets.only(
                                                         top: 0, bottom: 0),
                                                     child: Wrap(
                                                       children: <Widget>[
                                                         Container(
                                                             decoration: BoxDecoration(
                                                               borderRadius: BorderRadius.circular(10),
                                                               color : HexColor("#e2ffc7"),
                                                               boxShadow: [
                                                                 // BoxShadow(color: Colors.white, spreadRadius: 1),
                                                               ],
                                                             ),
                                                             child :
                                                             data[i]["e"] != 'Message has been deleted..' ?
                                                             Padding(
                                                                 padding: const EdgeInsets.all(10.0),
                                                                 child:
                                                                 data[i]["h"] != '' && data[i]["d"] == '2' ?
                                                                 GestureDetector(
                                                                   child: Hero(
                                                                       tag: data[i]["h"],
                                                                       child :
                                                                       Image(
                                                                         image: NetworkImage(applink+"media/imgchat/"+ data[i]["h"]),
                                                                         height: 160,
                                                                         width: 160,
                                                                       )),
                                                                   onTap: (){
                                                                    Navigator.of(context).push(
                                                                       new MaterialPageRoute(
                                                                           builder: (BuildContext context) => DetailChatImage(data[i]["h"].toString())));
                                                                   },
                                                                   onLongPress: (){
                                                                     _doDeleteMessageImage(data[i]["i"].toString());
                                                                   },
                                                                 )
                                                                     :
                                                                 GestureDetector(
                                                                   child :
                                                                   Text(data[i]["e"],
                                                                       style: TextStyle(
                                                                         fontSize: 14,
                                                                         fontFamily: 'VarelaRound',
                                                                       )),
                                                                   onLongPress: (){
                                                                     _doDeleteMessage(data[i]["i"].toString());
                                                                   },
                                                                 )
                                                             )
                                                                 :
                                                             Padding (
                                                                 padding: const EdgeInsets.all(10),
                                                                 child :
                                                                 Text(data[i]["e"],
                                                                     style: TextStyle(
                                                                         fontSize: 14,
                                                                         fontFamily: 'VarelaRound',
                                                                         fontStyle: FontStyle.italic
                                                                     )))
                                                         ),
                                                       ],
                                                     ))),
                                             Align(
                                                 alignment: Alignment.centerRight,
                                                 child: Container(
                                                   padding: const EdgeInsets.only(
                                                       right: 3.0, top: 5),
                                                   child: Text(
                                                       data[i]["g"],
                                                       style: TextStyle(
                                                         fontSize: 8,
                                                         fontFamily: 'VarelaRound',
                                                       )),
                                                 )),
                                             Padding(
                                                 padding: const EdgeInsets.only(bottom: 10.0))
                                           ]));
                                   }
                                 }

                             );
                           }
                       )
                   )
               ),
               _buildTextComposer()
             ],

           ),


           Positioned(
             bottom: 50,
             right: 5,
             child:
             Visibility(
               visible: _isVisible,
               maintainSize: true,
               maintainAnimation: true,
               maintainState: true,
               child: Align(
                 alignment: Alignment.bottomRight,
                 child : Container(
                     color: Colors.transparent,
                     height: 55,
                     width: 60,
                     child : new FutureBuilder(
                       future: getDataChat3(),
                       builder: (context, snapshot) {
                         return ListView.builder(
                           itemCount: data2 == null ? 0 : data2.length ,
                           itemBuilder: (context, i) {
                             return   Padding(
                               padding: const EdgeInsets.only(right: 15, bottom: 15),
                               child:
                               SizedBox(
                                 width: 40.0,
                                 height: 40.0,
                                 child:

                                 data2[i]["a"] != 0 ?
                                 Badge(
                                   badgeContent: Text(data2[i]["a"].toString(), style: TextStyle(color: Colors.white),),
                                   animationType: null,
                                   toAnimate: false,
                                   child: FloatingActionButton(
                                     elevation: 1,
                                     backgroundColor: HexColor("#f8f7f5"),
                                     child:  Center(
                                       child: FaIcon(FontAwesomeIcons.angleDoubleDown, size: 18,color: HexColor("#727270"),),
                                     ),onPressed: (){
                                     _removeread();
                                     _scrollController
                                         .jumpTo(_scrollController.position.maxScrollExtent);
                                   },
                                   ),
                                 )
                                     :
                                 FloatingActionButton(
                                   elevation: 1,
                                   backgroundColor: HexColor("#f8f7f5"),
                                   child:  Center(
                                     child: FaIcon(FontAwesomeIcons.angleDoubleDown, size: 18,color: HexColor("#727270"),),
                                   ),onPressed: (){
                                   _scrollController
                                       .jumpTo(_scrollController.position.maxScrollExtent);
                                 },
                                 ),
                               )

                               ,
                             );
                           },
                         );
                       },
                     )
                 ),
               ),
             ),
           )
         ],
          )
   ),
     ),
   );

  }


  Widget _buildTextComposer() {
    return new
    GestureDetector(
      child :
      Column(
        children: <Widget>[
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                /*borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),*/
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              //margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: new Row(
                children: <Widget>[

                  Flexible(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 15,bottom: 5,top:5),
                        child: TextField(
                          onTap: () {
                            _scrollController
                                .jumpTo(_scrollController.position.maxScrollExtent);
                          },
                          minLines: 1,
                          maxLines: 5,
                          controller: _textController,
                          focusNode: myFocusNode,
                          //onSubmitted: _handleSubmitted,
                          // onChanged: _handleChanged,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'VarelaRound',
                          ),
                          decoration: new InputDecoration.collapsed(
                            hintText: 'Tulis Pesan..',
                          ),
                        )),
                  ),
                  new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 4.0),
                      child:
                      Row (
                          children: <Widget>[
                            Opacity(
                                opacity: 0.8,
                                child :
                                new IconButton(
                                    icon: new FaIcon(FontAwesomeIcons.image),
                                    onPressed: () {
                                      imageSelectorGallery();
                                    }
                                  // _roomchat();
                                )),
                            Opacity(
                                opacity: 0.8,
                                child :
                                new IconButton(
                                    icon: new Icon(Icons.send),
                                    onPressed: () {
                                     // _isLoading = '1';
                                      _addchat();
                                      _scrollController
                                          .jumpTo(_scrollController.position.maxScrollExtent);
                                    })),
                          ])
                  ),
                ],
              ))
        ],
      ),
      onTap: (){
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent);
      },);
  }

}