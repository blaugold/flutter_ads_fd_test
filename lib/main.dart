// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Demo ad unit IDs.
// https://developers.google.com/admob/android/test-ads#demo_ad_units
const addUnits = {
  'Interstitial': 'ca-app-pub-3940256099942544/1033173712',
  'Interstitial Video': 'ca-app-pub-3940256099942544/8691691433',
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  MobileAds.instance;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: Home(),
      );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int? fdCount;

  String addUnit = addUnits['Interstitial']!;
  int adLoadBatchSize = 5;
  final List<InterstitialAd> _interstitialAds = [];

  @override
  void initState() {
    super.initState();

    _updateFdCount();

    Timer.periodic(const Duration(seconds: 1), (_) => _updateFdCount());
  }

  Future<void> _updateFdCount() async {
    final fdCount = await getFdCount();
    setState(() {
      this.fdCount = fdCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final header = Theme.of(context).textTheme.caption;
    const spacer = SizedBox(height: 32);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FD Count', style: header),
            Text(fdCount.toString()),
            spacer,
            Text('Add unit', style: header),
            DropdownButton<String>(
              value: addUnit,
              isDense: true,
              items: [
                for (final addUnit in addUnits.entries)
                  DropdownMenuItem<String>(
                    value: addUnit.value,
                    child: Text(addUnit.key),
                  ),
              ],
              onChanged: (value) async {
                setState(() {
                  addUnit = value!;
                });
              },
            ),
            spacer,
            Text('Load batch size', style: header),
            DropdownButton<int>(
              value: adLoadBatchSize,
              isDense: true,
              items: [
                for (var i = 1; i <= 10; i++)
                  DropdownMenuItem<int>(
                    value: i,
                    child: Text(i.toString()),
                  ),
              ],
              onChanged: (value) async {
                setState(() {
                  adLoadBatchSize = value!;
                });
              },
            ),
            spacer,
            ElevatedButton(
              onPressed: _loadAds,
              child: const Text('Load ads'),
            ),
            spacer,
            Text('Ads loaded', style: header),
            Text(_interstitialAds.length.toString()),
            spacer,
            ElevatedButton(
              onPressed: _disposeAds,
              child: const Text('Dispose ads'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadAds() {
    for (var i = 0; i < adLoadBatchSize; i++) {
      InterstitialAd.load(
        adUnitId: addUnit,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('Ad loaded');
            setState(() {
              _interstitialAds.add(ad);
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('Ad failed to load: $error');
          },
        ),
      );
    }
  }

  void _disposeAds() {
    setState(() {
      for (final ad in _interstitialAds) {
        ad.dispose().then(
              (value) => print('Disposed ad'),
              onError: (error) => print('Failed to dispose ad: $error'),
            );
      }
      _interstitialAds.clear();
    });
  }
}

final lib = DynamicLibrary.process();

late final pid =
    lib.lookupFunction<Int32 Function(), int Function()>('getpid')();

Future<int> getFdCount() => Directory('/proc/$pid/fd').list().length;
