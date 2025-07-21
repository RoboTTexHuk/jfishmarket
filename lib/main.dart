import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:app_tracking_transparency/app_tracking_transparency.dart' as zax_galaxy;
import 'package:appsflyer_sdk/appsflyer_sdk.dart' as zax_fly;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, SystemChrome, SystemUiOverlayStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:jmarketfish/pushi.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as zax_time;
import 'package:timezone/timezone.dart' as zax_tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:provider/provider.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart' as r;


import 'main.dart';

class YellowFishSwimming extends StatefulWidget {
  const YellowFishSwimming({super.key});

  @override
  State<YellowFishSwimming> createState() => _YellowFishSwimmingState();
}

class _YellowFishSwimmingState extends State<YellowFishSwimming>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _swimRight = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -80, end: 80).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) _swimRight = true;
      if (status == AnimationStatus.reverse) _swimRight = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(_animation.value)
                ..scale(_swimRight ? 1.0 : -1.0, 1.0),
              child: CustomPaint(
                size: const Size(120, 60),
                painter: _FishPainter(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.fill;

    // Тело рыбки (овал)
    final bodyRect = Rect.fromLTWH(size.width * 0.12, size.height * 0.3, size.width * 0.55, size.height * 0.4);
    canvas.drawOval(bodyRect, paint);




  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final yxDI = GetIt.instance;
void yxInit() {
  yxDI.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  yxDI.registerSingleton<Logger>(Logger());
  yxDI.registerSingleton<Connectivity>(Connectivity());
}

// BLoC
enum GopEvent { foo }
enum GopState { bar, baz, qux, quux }

class GopBloc extends Bloc<GopEvent, GopState> {
  GopBloc() : super(GopState.bar) {
    on<GopEvent>((event, emit) async {
      if (event == GopEvent.foo) {
        emit(GopState.qux);
        try {
          await zax_galaxy.AppTrackingTransparency.requestTrackingAuthorization();
          final r = await zax_galaxy.AppTrackingTransparency.trackingAuthorizationStatus;
          emit(r == zax_galaxy.TrackingStatus.authorized ? GopState.baz : GopState.quux);
        } catch (e) {
          emit(GopState.quux);
        }
      }
    });
  }
}

class NetWiggler {
  Future<bool> ping() async {
    var n = await yxDI<Connectivity>().checkConnectivity();
    return n != ConnectivityResult.none;
  }

  Future<void> post(String s, Map<String, dynamic> d) async {
    try {
      await http.post(Uri.parse(s), body: jsonEncode(d));
    } catch (e) {
      yxDI<Logger>().e("Net error: $e");
    }
  }
}

final deviceProvider = r.FutureProvider<BazDevice>((ref) async {
  final d = BazDevice();
  await d.init();
  return d;
});

class FlyAnalytics with ChangeNotifier {
  zax_fly.AppsflyerSdk? _drive;
  String flyID = "";
  String flyData = "";

  void ignite(VoidCallback onChange) {
    final conf = zax_fly.AppsFlyerOptions(
      afDevKey: "qsBLmy7dAXDQhowM8V3ca4",
      appId: "6748606202",
      showDebug: true,
    );
    _drive = zax_fly.AppsflyerSdk(conf);
    _drive?.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    _drive?.startSDK(
      onSuccess: () => yxDI<Logger>().i("Tracking initialized"),
      onError: (int code, String msg) => yxDI<Logger>().e("Tracking error $code: $msg"),
    );
    _drive?.onInstallConversionData((result) {
      flyData = result.toString();
      onChange();
    });
    _drive?.getAppsFlyerUID().then((val) {
      flyID = val.toString();
      onChange();
    });
  }
}

class BazDevice {
  String? fooID;
  String? barToken = "unique-session-mark";
  String? bazSys;
  String? bazBuild;
  String? zapApp;
  String? zapLocale;
  String? zapZone;
  bool zupPush = true;

  Future<void> init() async {
    final d = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final data = await d.androidInfo;
      fooID = data.id;
      bazSys = "android";
      bazBuild = data.version.release;
    } else if (Platform.isIOS) {
      final data = await d.iosInfo;
      fooID = data.identifierForVendor;
      bazSys = "ios";
      bazBuild = data.systemVersion;
    }
    final appInfo = await PackageInfo.fromPlatform();
    zapApp = appInfo.version;
    zapLocale = Platform.localeName.split('_')[0];
    zapZone = zax_tz.local.name;
    barToken = "session-${DateTime.now().millisecondsSinceEpoch}";
  }

  Map<String, dynamic> asMap({String? token}) => {
    "fcm_token": token ?? 'missing_token',
    "device_id": fooID ?? 'missing_id',
    "app_name": "jfishmarket",
    "instance_id": barToken ?? 'missing_session',
    "platform": bazSys ?? 'missing_system',
    "os_version": bazBuild ?? 'missing_build',
    "app_version": zapApp ?? 'missing_app',
    "language": zapLocale ?? 'en',
    "timezone": zapZone ?? 'UTC',
    "push_enabled": zupPush,
  };
}

final flyProvider = ChangeNotifierProvider(create: (_) => FlyAnalytics());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  yxInit();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_shadFcm);
  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  zax_time.initializeTimeZones();
  final p = await SharedPreferences.getInstance();
  final bool q = p.getBool('auth_viewed') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlyAnalytics()),
      ],
      child: ProviderScope(
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => GopBloc(),
            child: q ? const FooOnboard() : const GooConsent(),
          ),
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}

// Экран согласия ATT
class GooConsent extends StatefulWidget {
  const GooConsent({super.key});
  @override
  State<GooConsent> createState() => _GooConsentState();
}

class _GooConsentState extends State<GooConsent> {
  bool _lolo = false;

  Future<void> _mark() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('auth_viewed', true);
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GopBloc, GopState>(
      listener: (context, state) async {
        if (state == GopState.baz || state == GopState.quux) {
          setState(() => _lolo = true);
          await Future.delayed(const Duration(milliseconds: 1600));
          await _mark();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const FooOnboard()),
          );
        }
      },
      builder: (context, state) {
        if (_lolo || state == GopState.qux) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: YellowFishSwimming(),
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Color(0xFFFFD700),
                  width: 2.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.privacy_tip_outlined, size: 56, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Personalized Experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Your preferences help us provide you with more relevant offers, bonuses, and notifications. We never sell or misuse your personal information — your privacy is our top priority.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() => _lolo = true);
                        context.read<GopBloc>().add(GopEvent.foo);
                      },
                      child: const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You can change your choice in your device settings anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.amber),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Экран инициализации уведомлений
class FooOnboard extends StatefulWidget {
  const FooOnboard({Key? key}) : super(key: key);
  @override
  State<FooOnboard> createState() => _FooOnboardState();
}

class _FooOnboardState extends State<FooOnboard> {
  final Xyzz _xyz = Xyzz();
  bool _abc = false;
  Timer? _timer;
  bool _show = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    _xyz.listen((sig) {
      _go(sig);
    });
    _timer = Timer(const Duration(seconds: 8), () {
      _go('');
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _show = false);
    });
  }

  void _go(String sig) {
    if (_abc) return;
    _abc = true;
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BazPortalView(signal: sig),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_show)
            const YellowFishSwimming(),
          if (!_show)
            const Center(
              child: SizedBox(
                child: Center(child:YellowFishSwimming()),
              ),
            ),
        ],
      ),
    );
  }
}

class Xyzz extends ChangeNotifier {
  String? _pulse;
  void listen(Function(String signal) onSignal) {
    const MethodChannel('com.example.fcm/token')
        .setMethodCallHandler((call) async {
      if (call.method == 'setToken') {
        final String signal = call.arguments as String;
        onSignal(signal);
      }
    });
  }
}

class BazPortalView extends StatefulWidget {
  final String? signal;
  const BazPortalView({super.key, required this.signal});
  @override
  State<BazPortalView> createState() => _BazPortalViewState();
}

class _BazPortalViewState extends State<BazPortalView> with WidgetsBindingObserver {
  late InAppWebViewController _ctrl;
  bool _fetching = false;
  final String _url = "https://fishshopapp.blog/";
  final BazDevice _dev = BazDevice();
  final FlyAnalytics _fly = FlyAnalytics();
  int _id = 0;
  DateTime? _paused;
  bool _showWeb = false;
  double _prog = 0.0;
  late Timer _progT;
  final int _wait = 6;
  bool _loader = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _loader = false);
    });
    Future.delayed(const Duration(seconds: 9), () {
      setState(() {
        _showWeb = true;
      });
    });
    _initAll();
  }

  void _initAll() {
    _progPulse();
    _setupPush();
    _setupATT();
    _fly.ignite(() => setState(() {}));
    _setupNotif();
    _devInit();
    Future.delayed(const Duration(seconds: 2), _setupATT);
    Future.delayed(const Duration(seconds: 6), () {
      _sendDev();
      _sendFly();
    });
  }
  void _setupPush() {
    FirebaseMessaging.onMessage.listen((msg) {
      final link = msg.data['uri'];
      if (link != null) {
        _toLink(link.toString());
      } else {
        _refresh();
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      final link = msg.data['uri'];
      if (link != null) {
        _toLink(link.toString());
      } else {
        _refresh();
      }
    });
  }
  void _setupNotif() {
    MethodChannel('com.example.fcm/notification').setMethodCallHandler((call) async {
      if (call.method == "onNotificationTap") {
        final Map<String, dynamic> payload = Map<String, dynamic>.from(call.arguments);
        final targetUrl = payload["uri"];
        if (targetUrl != null && !targetUrl.contains("No URI")) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WeirdBanana(targetUrl)),
                (route) => false,
          );
        }
      }
    });
  }
  Future<void> _devInit() async {
    try {
      await _dev.init();
      await _push();
      if (_ctrl != null) {
        _sendDev();
      }
    } catch (e) {
      yxDI<Logger>().e("Gadget initialization failed: $e");
    }
  }
  Future<void> _push() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
  }
  Future<void> _setupATT() async {
    final status = await zax_galaxy.AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == zax_galaxy.TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 1000));
      await zax_galaxy.AppTrackingTransparency.requestTrackingAuthorization();
    }
    final uuid = await zax_galaxy.AppTrackingTransparency.getAdvertisingIdentifier();
    yxDI<Logger>().i("ATT AdvertisingIdentifier: $uuid");
  }

  void _toLink(String link) async {
    if (_ctrl != null) {
      await _ctrl.loadUrl(urlRequest: URLRequest(url: WebUri(link)));
    }
  }
  void _refresh() async {
    Future.delayed(const Duration(seconds: 3), () {
      if (_ctrl != null) {
        _ctrl.loadUrl(urlRequest: URLRequest(url: WebUri(_url)));
      }
    });
  }
  Future<void> _sendDev() async {
    print("load TOKEN "+widget.signal.toString());
    setState(() => _fetching = true);
    try {
      final data = _dev.asMap(token: widget.signal);
      await _ctrl.evaluateJavascript(source: '''
      localStorage.setItem('app_data', JSON.stringify(${jsonEncode(data)}));
      ''');
    } finally {
      setState(() => _fetching = false);
    }
  }
  Future<void> _sendFly() async {
    final data = {
      "content": {
        "af_data": _fly.flyData,
        "af_id": _fly.flyID,
        "fb_app_name": "jfishmarket",
        "app_name": "jfishmarket",
        "deep": null,
        "bundle_identifier": "com.jmarketfish.jmarket.jmarketfish",
        "app_version": "1.0.0",
        "apple_id": "6748606202",
        "fcm_token": widget.signal ?? "no_token",
        "device_id": _dev.fooID ?? "no_device",
        "instance_id": _dev.barToken ?? "no_instance",
        "platform": _dev.bazSys ?? "no_type",
        "os_version": _dev.bazBuild ?? "no_os",
        "app_version": _dev.zapApp ?? "no_app",
        "language": _dev.zapLocale ?? "en",
        "timezone": _dev.zapZone ?? "UTC",
        "push_enabled": _dev.zupPush,
        "useruid": _fly.flyID,
      },
    };
    final jsonString = jsonEncode(data);
    yxDI<Logger>().i("SendRawData: $jsonString");
    await _ctrl.evaluateJavascript(
      source: "sendRawData(${jsonEncode(jsonString)});",
    );
  }
  void _progPulse() {
    int count = 0;
    _prog = 0.0;
    _progT = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        count++;
        _prog = count / (_wait * 10);
        if (_prog >= 1.0) {
          _prog = 1.0;
          _progT.cancel();
        }
      });
    });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _paused = DateTime.now();
    }
    if (state == AppLifecycleState.resumed) {
      if (Platform.isIOS && _paused != null) {
        final now = DateTime.now();
        final duration = now.difference(_paused!);
        if (duration > const Duration(minutes: 25)) {
          _rebuild();
        }
      }
      _paused = null;
    }
  }
  void _rebuild() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => BazPortalView(signal: widget.signal),
        ),
            (route) => false,
      );
    });
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progT.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setupNotif();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_loader)
            const YellowFishSwimming(),
          if (!_loader)
            Container(
              color: Colors.black,
              child: Stack(
                children: [
                  InAppWebView(
                    key: ValueKey(_id),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      disableDefaultErrorPage: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      allowsPictureInPictureMediaPlayback: true,
                      useOnDownloadStart: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                    ),
                    initialUrlRequest: URLRequest(url: WebUri(_url)),
                    onWebViewCreated: (controller) {
                      _ctrl = controller;
                      _ctrl.addJavaScriptHandler(
                          handlerName: 'onServerResponse',
                          callback: (args) {
                            print("JS args: $args");
                            print("From the JavaScript side:");
                            print("ResRes" + args[0]['savedata'].toString());
                            if (args[0]['savedata'].toString() == "false") {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HelpScreen(),
                                ),
                                    (route) => false,
                              );
                            }
                            return args.reduce((curr, next) => curr + next);
                          });
                    },
                    onLoadStart: (controller, url) {
                      setState(() => _fetching = true);
                    },
                    onLoadStop: (controller, url) async {
                      await controller.evaluateJavascript(
                        source: "console.log('Portal loaded!');",
                      );

                      print("Load my data "+url.toString());
                      await _sendDev();



                        _sendFly();

                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      return NavigationActionPolicy.ALLOW;
                    },
                  ),
                  Visibility(
                    visible: !_showWeb,
                    child: const YellowFishSwimming(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _shadFcm(RemoteMessage message) async {
  yxDI<Logger>().i("Background alert: ${message.messageId}");
  yxDI<Logger>().i("Background payload: ${message.data}");
}
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  InAppWebViewController? _webViewController;
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            InAppWebView(
              initialFile: 'assets/index.html',
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                supportZoom: false, // Отключает pinch-to-zoom и double-tap zoom
                disableHorizontalScroll: false,
                disableVerticalScroll: false,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _loading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _loading = false;
                });
              },
              onLoadError: (controller, url, code, message) {
                setState(() {
                  _loading = false;
                });
              },
            ),
            if (_loading)
              const YellowFishSwimming(),
          ],
        ),
      ),
    );
  }
}