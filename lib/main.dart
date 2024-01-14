import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter_no_internet_widget/flutter_no_internet_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Dekho', debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
          future: Future.delayed(Duration(seconds: 3)),
          builder: (ctx, timer) =>
          timer.connectionState == ConnectionState.done
              ? InternetWidget(
              // ignore: avoid_print
              whenOffline: () => print('No Internet'), offline: FullScreenWidget(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title:  Center(child: Text('Errr : No Internet Example')),
              ),
              body:  Center(child: Image.asset("assets/offlinw.jpg", height: MediaQuery.of(context).size.height
                  , fit : BoxFit.cover, width:MediaQuery.of(context).size.width )),
            ),
          ),
              // ignore: avoid_print
              whenOnline: () => MyHomePage(),
              loadingWidget: const Center(child: Text('Loading')),
              online : MyHomePage()) //Screen to navigate to once the splashScreen is done.
              : Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image(
              image: AssetImage('assets/splash.jpg'),
              fit: BoxFit.cover,
            ),
          ),
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
   MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  late final WebViewController controller;
  double progress = 0.0;
  void initState(){
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progres) {
            setState(() {
              progress = progres / 100;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://cycledekhoj.in/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )..loadRequest(Uri.parse('https://cycledekho.in/'));
    setState(() {

    });
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastPressedAt;
  @override
  Widget build(BuildContext context) {
    int backButtonPressCount = 0;
    return  WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {

          // If it's the first press or more than 2 seconds since the last press
          if (await controller.canGoBack()) {
            controller.goBack();
          } else {
            _lastPressedAt = DateTime.now();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return false; // Do not exit the app
        } else {
          return true; // Allow exit the app
        }
      },
      child: Container(
        width : MediaQuery.of(context).size.width,
       height : MediaQuery.of(context).size.height,
        child: Scaffold(
          resizeToAvoidBottomInset: true ,
            key: _scaffoldKey ,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(10.0) , // Set the desired height
              child: AppBar(
                backgroundColor: Colors.black ,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(4.0) , // Set the desired height
                  child: LinearProgressIndicator(
                    value: progress ,
                    backgroundColor: Colors.white ,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat ,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              child : Icon(Icons.refresh),
              onPressed: (){
                _refreshWebView();
              },
            ),
            body: WebViewWidget(controller: controller,
            ),
        ),
      ),
    );
  }

  Future<void> _refreshWebView() async {
    await controller.reload();
  }
}