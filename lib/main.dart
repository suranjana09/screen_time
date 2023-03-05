import 'package:final_screen/screen_time.dart';
import 'package:final_screen/screen_time1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'UsageStatsHelper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MethodChannel channel = const MethodChannel('usage_stats_helper');

  Future<bool> _isUsageAccessGranted() async {
    return await channel.invokeMethod('isUsageAccessGranted');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Usage Stats Demo', home: UsageStatsPage()

        //  Scaffold(
        //   appBar: AppBar(
        //     title: Text('Usage Stats Demo'),
        //   ),
        //   body: Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         ElevatedButton(
        //           child: Text('Check Usage Access'),
        //           onPressed: () async {
        // bool accessGranted = await _isUsageAccessGranted();
        // debugPrint('Access granted: $accessGranted');

        // String message =
        //     accessGranted ? 'Access granted!' : 'Access denied.';
        // ScaffoldMessenger.of(context)
        // .showSnackBar(SnackBar(content: Text(message)));
        //               Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        //                 return UsageStatsPage();
        //               }));
        //             },
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        );
  }
}
