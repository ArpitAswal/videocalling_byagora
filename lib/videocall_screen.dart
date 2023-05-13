import 'package:agora_uikit/agora_uikit.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

String channelName = "VideoCall";
String token = '007eJxTYLi4WpyV64RrYIhGsIHizKUzD1dHHrqimuFSVm4/v7956VEFBsOkVIO0RAOTNEszYxMTC2OLlERj09RUg+Qkc0uLFDPjZzlxKQ2BjAyet18zMTJAIIjPyRCWmZKa75yYk8PAAAB74SCN';
const String appId = "1be0fa04f96344838da35ee0cb798d63";

int uid = 0; // uid of the local user Indicates if the local user has joined the channel
List remoteIds=[]; // uid of the remote user
bool _isJoined = false; // Indicates if the local user has joined the channel
late RtcEngine agoraEngine; // Agora engine instance

bool muted = false;
bool moreoption=false;
bool offcamera = false;

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {

  bool loading= false;

  void initState(){
    super.initState();
    initializeAgora();
  }
  void dispose() async {
    super.dispose();
    await agoraEngine.leaveChannel();
    agoraEngine.release();
  }

  snackbar(String message) {
    var snackBar = SnackBar(
      content: Text(message),
    );
    return snackBar;
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    agoraEngine.muteLocalAudioStream(muted);
  }

  void _onToggleOption() {
    setState(() {
      moreoption= !moreoption;
      _onToggleMute();
      _offCamera();
    });
  }
  void _onCallEnd(BuildContext context) {
    setState(() {
      _isJoined = false;
      remoteIds.clear();
    });
    agoraEngine.leaveChannel();
    Navigator.pop(context);
  }

  void _onSwitchCamera() {
    agoraEngine.switchCamera();
  }

  void _offCamera() {
    setState(() {
      offcamera = !offcamera;
     _isJoined=!_isJoined;
    });

  }
  Future<void> initializeAgora() async{
    await [Permission.microphone, Permission.camera].request();

    setState((){
      loading=true;
    });
    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: appId,));
    await agoraEngine.enableVideo();
    await agoraEngine.setChannelProfile(ChannelProfileType.channelProfileCommunication);

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          ScaffoldMessenger.of(context).showSnackBar(snackbar(
              "Local user uid:${connection.localUid} joined the channel"));
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          ScaffoldMessenger.of(context).showSnackBar(
              snackbar("Remote user uid:$remoteUid joined the channel"));
          setState(() {
            remoteIds.add(remoteUid);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          ScaffoldMessenger.of(context).showSnackBar(
              snackbar("Remote user uid:$remoteUid left the channel"));
          setState(() {
            remoteIds.remove(remoteUid);
          });
        },
      ),
    );
    Future.delayed(const Duration(seconds: 2));
    await agoraEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:(!loading)? CircularProgressIndicator(): Stack(
        children: [
          Column(
            mainAxisAlignment: (remoteIds.isEmpty) ? MainAxisAlignment.center : MainAxisAlignment.start,
            children:[
              (remoteIds.isEmpty) ? Container() : Padding(
                padding: const EdgeInsets.only(top: 35,bottom: 10),
                child: Container(
                  alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width,
                  height: 110,
                  child: _remoteVideo(),
              )),
              (remoteIds.isEmpty) ? Container() : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: RawMaterialButton(
                    onPressed: (){
                      _onToggleOption();
                    },
                    shape: const CircleBorder(),
                    elevation: 5.0,
                    fillColor: moreoption ? Colors.blueAccent : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child:  Icon(
                      Icons.more_horiz,
                      color: moreoption ? Colors.white : Colors.blueAccent,
                      size: 25.0,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: RawMaterialButton(
                    onPressed: _onToggleMute,
                    shape: const CircleBorder(),
                    elevation: 5.0,
                    fillColor: muted ? Colors.blueAccent : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      muted ? Icons.mic_off : Icons.mic,
                      color: muted ? Colors.white : Colors.blueAccent,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  height: MediaQuery.of(context).size.height/2+70,
                  width:MediaQuery.of(context).size.width,
                  child: Center(child: _localPreview()),
                ),
              ),
          ]),
            _toolbar()
        ],
      )
    );
  }
  Widget _toolbar() {
    return Positioned(
      bottom: 20,
      left: 65,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: _offCamera,
              shape: const CircleBorder(),
              elevation: 5.0,
              fillColor: offcamera ? Colors.blueAccent : Colors.white,
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                Icons.camera_alt,
                color: offcamera ? Colors.white : Colors.blueAccent,
                size: 20.0,
              ),
            ),
            RawMaterialButton(
              onPressed: () => _onCallEnd(context),
              shape: const CircleBorder(),
              elevation: 5.0,
              fillColor: Colors.redAccent,
              padding: const EdgeInsets.all(15.0),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 35.0,
              ),
            ),
            RawMaterialButton(
              onPressed: _onSwitchCamera,
              shape: const CircleBorder(),
              elevation: 5.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
              child: const Icon(
                Icons.switch_camera,
                color: Colors.blueAccent,
                size: 20.0,
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _localPreview() {
    if (_isJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Container(
            height: 450,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(72), color: Colors.lightBlue),
            child: Center(
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 340,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _remoteVideo() {
    if(remoteIds.isNotEmpty) {
        return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: remoteIds.length,
            itemBuilder: (BuildContext context, index){
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue,width: 2),
              ),
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: agoraEngine,
                  canvas: VideoCanvas(uid:remoteIds[index]),
                  connection: RtcConnection(channelId: channelName),
                ),
              ),
            ),
          );
        });
    }
    else{
      return Icon(Icons.person_off,color: Colors.black,size: 50,);
    }
  }
}
