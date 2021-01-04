


import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:micodokter_app/helper/page_route.dart';
import 'package:micodokter_app/mico_home.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:time/time.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;


class VideoRoom extends StatefulWidget{
  final String channelName, tokenq, appidq;
  final ClientRole role;
  final int uidq;
  const VideoRoom({Key key, this.channelName, this.role, this.uidq, this.tokenq, this.appidq}) : super(key: key);
  @override
  _VideoRoomState createState() => new _VideoRoomState();
}

class _VideoRoomState extends State<VideoRoom> {

  static final _users = <int>[];
  final _infoStrings = <String>[];

  Timer _timer;
  DateTime _currentTime;
  DateTime _afterTime, _timeIntv;
  int _remainingdetik,
      _remainingmenit,
      _detik,
      _menit;

  bool muted = false;
  RtcEngine _engine;
  bool _isVisible = false;


  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }


/*

  String getAppkode = "";
  _getVideoDetail() async {
    final response = await http.get(
        applink+"api_script.php?do=getdata_videoroomdetail&id="+getPhone);
    Map data2 = jsonDecode(response.body);
    setState(() {
      getAppkode = data2["a"].toString();
    });
  }

  String tahun, bulan, hari, jam, menit, getRoom = "0";
  void _setTimerRender() async {
    final response = await http.get(
        applink+"api_script.php?do=getdata_appdetail&id="+getAppkode.toString());
    Map data = jsonDecode(response.body);
    setState(() {
      tahun = data["a"].toString();
      bulan = data["b"].toString();
      hari = data["c"].toString();
      jam = data["d"].toString();
      menit = data["e"].toString();
      jam = data["d"].toString();
      getRoom = data["f"].toString();
      _currentTime = DateTime.now();
      _timeIntv = DateTime(int.parse(tahun), int.parse(bulan), int.parse(hari), int.parse(jam), int.parse(menit), 00);
      _afterTime = _timeIntv + 16.minutes;
      _remainingmenit = _currentTime.difference(_afterTime).inMinutes;
      _menit = _remainingmenit;
    });
  }


  int _detik2 = 60;
  void startTimerDetik() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_detik2 == 0) {
            _detik2 = 60;
          } else {
            _detik2 = _detik2 - 1;
          }
        },
      ),
    );
  }

  void startTimerMenit() {
    const oneMin = const Duration(minutes: 1);
    _timer = new Timer.periodic(
      oneMin,
          (Timer timer) => setState(
            () {
          _menit = _menit + 1;
          if (_menit == -5) {
            Toast.show("Waktu konsultasi tinggal 5 menit", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
          } else if (_menit == -2) {
            Toast.show("Waktu konsultasi tinggal 2 menit", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
          } else if (_menit == 0) {
            _endKonsultasi();
          }
        },
      ),
    );
  }

  Widget _countdown() {
    return Text(_menit.toString() + " : " +_detik2.toString(), style: TextStyle(color: Colors.white,fontSize: 27,
      fontFamily: 'VarelaRound',),);
  }

    _endKonsultasi () async  {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=act_selesaichatdokter&id="+getAppkode);
    Map data = jsonDecode(response.body);
    Navigator.pushReplacement(context, EnterPage(page: Home()));
  }
  */

  Future<bool> _onWillPop() async {
    //Toast.show("Toast plugin app", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    showAlert();
  }

  void showAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text(),
            content: Text(
                "Apakah anda yakin untuk keluar dari video konsultasi ini ?",
                style: TextStyle(fontFamily: 'VarelaRound')),
            actions: [
              new FlatButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, EnterPage(page: Home()));
                    _engine.leaveChannel();
                  },
                  child:
                  Text("Iya", style: TextStyle(fontFamily: 'VarelaRound')))
            ],
          );
        });
  }


  autohidemessage() async {
    var duration = const Duration(seconds: 5);
    return Timer(duration, () {
      setState(() {
        _isVisible = false;
      });
    });
  }


  @override
  void initState() {
    super.initState();
    initialize();
  }


  Future<void> initialize() async {
    if (widget.appidq.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(800, 600);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(widget.tokenq, widget.channelName, null, widget.uidq);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(widget.appidq);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);

  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'Bergabung di channel : $channel';
        //', uid: $uid';
        _infoStrings.add(info);
        _isVisible = true;
        autohidemessage();
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('Keluar dari channel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'Bergabung : $uid';
        _infoStrings.add(info);
        _users.add(uid);
        _isVisible = true;
        autohidemessage();
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
      case 2:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow([views[0]]),
                _expandedVideoRow([views[1]])
              ],
            ));
      case 3:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 3))
              ],
            ));
      case 4:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 4))
              ],
            ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return
      Visibility(
          visible: _isVisible,
          child :
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.5,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: ListView.builder(
                  reverse: true,
                  itemCount: _infoStrings.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_infoStrings.isEmpty) {
                      return null;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                color: HexColor("#602d98"),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                _infoStrings[index],
                                style: TextStyle(color: Colors.white, fontFamily: 'VarelaRound',),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ));
  }

  void _onCallEnd(BuildContext context) {
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
            builder: (BuildContext context) => Home()));
    _engine.leaveChannel();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Stack(
              children: <Widget>[
                _viewRows(),
                //
                _panel(),
                _toolbar(),
              ],
            ),
          ),
        )
    );
  }
}