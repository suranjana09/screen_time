import 'dart:math';

import 'package:flutter/material.dart';

import 'UsageStatsHelper.dart';
import 'package:intl/intl.dart';

class UsageStatsPage extends StatefulWidget {
  @override
  _UsageStatsPageState createState() => _UsageStatsPageState();
}

class _UsageStatsPageState extends State<UsageStatsPage> {
  List<UsageStats> _usageStats = [];

  @override
  void initState() {
    super.initState();
    _loadUsageStats();
    print('22222222222222222222222');
  }

  Future<void> _loadUsageStats() async {
    bool granted = await UsageStatsHelper.isUsageAccessGranted();
    if (granted) {
      // DateTime start = DateTime.now().subtract(Duration(hours: 24));
      DateTime end = DateTime.now().toUtc();
      DateTime start = DateTime(2023, 02, 12, 23, 59);
      print(start);
      print(end);
      List<UsageStats> stats = await UsageStatsHelper.getUsageStats(start, end);
      setState(() {
        _usageStats = stats;
      });
      print('000000000');
      print(_usageStats);
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Usage Access Permission Required'),
            content: const Text(
                'Please grant usage access permission in the device settings to view usage stats.'),
            actions: [
              TextButton(
                onPressed: () async {
                  bool granted = await UsageStatsHelper.isUsageAccessGranted();
                  debugPrint('Access granted: $granted');
                },

                //  => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usage Stats'),
      ),
      body: ListView.builder(
        itemCount: _usageStats.length,
        itemBuilder: (BuildContext context, int index) {
          UsageStats stats = _usageStats[index];
          print('-----------------------');
          // print(stats.appName);
          print(stats.usageTime);
          print(stats);

          // if (stats.packageName.contains('home')) {
          return ListTile(
            title: Text('12345'),
            subtitle: Text(stats.appName),
            trailing: Text(
                '${int.parse((stats.usageTime) as String) ~/ (1000 * 60)} minutes'),
          );
          // }
        },
      ),
    );
  }
}
