import 'dart:convert';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart' show AppTrackingTransparency, TrackingStatus;
import 'package:appsflyer_sdk/appsflyer_sdk.dart' show AppsFlyerOptions, AppsflyerSdk;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;
import 'package:http/http.dart' as http;


import 'main.dart' show MainClass, WebViewPage, QuantumPortalView, BazPortalView;

// FCM Background Handler
@pragma('vm:entry-point')
Future<void> bongoBackgroundRumble(RemoteMessage spling) async {
  print("Message ID: ${spling.messageId}");
  print("Message Data: ${spling.data}");
}

class WeirdBanana extends StatefulWidget with WidgetsBindingObserver {
  String wowzaUrl;
  WeirdBanana(this.wowzaUrl, {super.key});
  @override
  State<WeirdBanana> createState() => _WeirdBananaState(wowzaUrl);
}

class _WeirdBananaState extends State<WeirdBanana> with WidgetsBindingObserver {
  _WeirdBananaState(this.funkyString);

  late InAppWebViewController bongoWebber;
  String? fooToken;
  String? oddPlat;
  String? wowVersion;
  String? megaAppVer;
  String? pingLang;
  String? whizZone;
  bool zoopNotify = true;
  bool fizzLoading = false;
  var splatShow = true;
  final List<ContentBlocker> whackBlockers = [];
  String funkyString;
  DateTime? wibblePause;
  final List<String> lolAdList = [
    ".*.doubleclick.net/.*",
    ".*.ads.pubmatic.com/.*",
    ".*.googlesyndication.com/.*",
    ".*.google-analytics.com/.*",
    ".*.adservice.google.*/.*",
    ".*.adbrite.com/.*",
    ".*.exponential.com/.*",
    ".*.quantserve.com/.*",
    ".*.scorecardresearch.com/.*",
    ".*.zedo.com/.*",
    ".*.adsafeprotected.com/.*",
    ".*.teads.tv/.*",
    ".*.outbrain.com/.*",
  ];

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState boopState) {
    if (boopState == AppLifecycleState.paused) {
      wibblePause = DateTime.now();
    }
    if (boopState == AppLifecycleState.resumed) {
      if (Platform.isIOS && wibblePause != null) {
        final splongNow = DateTime.now();
        final splongDiff = splongNow.difference(wibblePause!);
        if (splongDiff > const Duration(minutes: 25)) {
          _unicornRebuild();
        }
      }
      wibblePause = null;
    }
  }

  void _unicornRebuild() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>BazPortalView( signal: '',),
        ),
            (route) => false,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    for (final splat in lolAdList) {
      whackBlockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: splat),
        action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
      ));
    }
    whackBlockers.add(ContentBlocker(
      trigger: ContentBlockerTrigger(urlFilter: ".cookie", resourceType: [
        ContentBlockerTriggerResourceType.RAW
      ]),
      action: ContentBlockerAction(
          type: ContentBlockerActionType.BLOCK, selector: ".notification"),
    ));

    whackBlockers.add(ContentBlocker(
      trigger: ContentBlockerTrigger(urlFilter: ".cookie", resourceType: [
        ContentBlockerTriggerResourceType.RAW
      ]),
      action: ContentBlockerAction(
          type: ContentBlockerActionType.CSS_DISPLAY_NONE,
          selector: ".privacy-info"),
    ));

    whackBlockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
        ),
        action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            selector: ".banner, .banners, .ads, .ad, .advert")));

    FirebaseMessaging.onBackgroundMessage(bongoBackgroundRumble);
    _galacticTracking();
    _blingAppsFlyer();
    _fizzFirebase();
    _sporkDevice();
    _zapFcmListeners();

    Future.delayed(const Duration(seconds: 2), () {
      _galacticTracking();
    });
    Future.delayed(const Duration(seconds: 6), () {
      _spoonFeedWebView();
    });
  }

  void _zapFcmListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage pongMsg) {
      if (pongMsg.data['uri'] != null) {
        _wobbleLoad(pongMsg.data['uri'].toString());
      } else {
        _reloadFizzWeb();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage pongMsg) {
      if (pongMsg.data['uri'] != null) {
        _wobbleLoad(pongMsg.data['uri'].toString());
      } else {
        _reloadFizzWeb();
      }
    });
  }

  void _wobbleLoad(String zipper) async {
    if (bongoWebber != null) {
      await bongoWebber.loadUrl(
        urlRequest: URLRequest(url: WebUri(zipper)),
      );
    }
  }

  void _reloadFizzWeb() async {
    Future.delayed(const Duration(seconds: 3), () {
      if (bongoWebber != null) {
        bongoWebber.loadUrl(
          urlRequest: URLRequest(url: WebUri(funkyString)),
        );
      }
    });
  }

  Future<void> _fizzFirebase() async {
    FirebaseMessaging wildFire = FirebaseMessaging.instance;
    NotificationSettings bonkSettings = await wildFire.requestPermission(alert: true, badge: true, sound: true);
    fooToken = await wildFire.getToken();
  }

  Future<void> _galacticTracking() async {
    final TrackingStatus fizzStat = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (fizzStat == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 1000));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    final flapUuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $flapUuid");
  }

  AppsflyerSdk? bouncyFlyer;
  String bouncyData = "";
  String bouncyId = "";

  void _blingAppsFlyer() {
    final AppsFlyerOptions bongoOpt = AppsFlyerOptions(
      afDevKey: "qsBLmy7dAXDQhowM8V3ca4",
      appId: "6748606202",
      showDebug: true,
    );
    bouncyFlyer = AppsflyerSdk(bongoOpt);
    bouncyFlyer?.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    bouncyFlyer?.startSDK(
      onSuccess: () => print("AppsFlyer OK"),
      onError: (int code, String message) => print("AppsFlyer Error: $code $message"),
    );
    bouncyFlyer?.onInstallConversionData((flimsy) {
      setState(() {
        bouncyData = flimsy.toString();
        bouncyId = flimsy['payload']['af_status'].toString();
      });
    });
    bouncyFlyer?.getAppsFlyerUID().then((id) {
      setState(() {
        bouncyId = id.toString();
      });
    });
  }

  Future<void> _spoonFeedWebView() async {
    print("Conversion Data: $bouncyData");
    final Map<String, dynamic> wonkyStuff = {
      "content": {
        "af_data": "$bouncyData",
        "af_id": "$bouncyId",
        "fb_app_name": "jfishmarket",
        "app_name": "jfishmarket",
        "deep": null,
        "bundle_identifier": "com.jmarketfish.jmarket.jmarketfish",
        "app_version": "1.0.0",
        "apple_id": "6748606202",
        "device_id": oddPlat ?? "default_device_id",
        "instance_id": wowVersion ?? "default_instance_id",
        "platform": megaAppVer ?? "unknown_platform",
        "os_version": pingLang ?? "default_os_version",
        "app_version": whizZone ?? "default_app_version",
        "language": pingLang ?? "en",
        "timezone": whizZone ?? "UTC",
        "push_enabled": zoopNotify,
        "useruid": "$bouncyId",
      },
    };

    final zipZap = jsonEncode(wonkyStuff);
    print("My JSON Data: $zipZap");
    await bongoWebber.evaluateJavascript(
      source: "sendRawData(${jsonEncode(zipZap)});",
    );
  }

  Future<void> _sporkDevice() async {
    try {
      final gargle = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidBork = await gargle.androidInfo;
        oddPlat = androidBork.id;
        megaAppVer = "android";
        wowVersion = androidBork.version.release;
      } else if (Platform.isIOS) {
        final iosBork = await gargle.iosInfo;
        oddPlat = iosBork.identifierForVendor;
        megaAppVer = "ios";
        wowVersion = iosBork.systemVersion;
      }
      final splatPack = await PackageInfo.fromPlatform();
      pingLang = Platform.localeName.split('_')[0];
      whizZone = timezone.local.name;
    } catch (e) {
      debugPrint("Device Info Error: $e");
    }
  }
  void _spiderMonkey() {
    MethodChannel('com.example.fcm/notification').setMethodCallHandler((call) async {
      if (call.method == "onNotificationTap") {
        final Map<String, dynamic> mush = Map<String, dynamic>.from(call.arguments);
        if (mush["uri"] != null && !mush["uri"].contains("Нет URI")) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WeirdBanana(mush["uri"])),
                (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _spiderMonkey();
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              disableDefaultErrorPage: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              allowsPictureInPictureMediaPlayback: true,
              useOnDownloadStart: true,
              //contentBlockers: whackBlockers,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            initialUrlRequest: URLRequest(url: WebUri(funkyString)),
            onWebViewCreated: (controller) {
              bongoWebber = controller;
              bongoWebber.addJavaScriptHandler(
                  handlerName: 'onServerResponse',
                  callback: (args) {
                    print("JS Args: $args");
                    return args.reduce((value, element) => value + element);
                  });
            },
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(
                source: "console.log('Hello from JS!');",
              );
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (fizzLoading)
            Visibility(
              visible: !fizzLoading,
              child: SizedBox.expand(
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                      strokeWidth: 8,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}