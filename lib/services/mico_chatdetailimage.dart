

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:micodokter_app/helper/link_api.dart';
import 'package:photo_view/photo_view.dart';

class DetailChatImage extends StatefulWidget {
  final String ImgFile;
  const DetailChatImage(this.ImgFile);
  @override
  _DetailChatImageState createState() => new _DetailChatImageState(
      getImgFile: this.ImgFile);
}



class _DetailChatImageState extends State<DetailChatImage> {
  String getImgFile;
  _DetailChatImageState({this.getImgFile});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
              tag: 'imagehero',
              child:
              PhotoView(
                imageProvider: NetworkImage(applink+"media/imgchat/"+widget.ImgFile),
              )
            /* Image (
                    image: NetworkImage("https://duakata-dev.com/miracle/media/imgchat/"+widget.ImgFile),
                  )*/
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}