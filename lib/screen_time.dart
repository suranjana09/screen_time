import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'UsageStatsHelper.dart';

class ScreenTime extends StatefulWidget {
  @override
  _ScreenTimeState createState() => _ScreenTimeState();
}

class _ScreenTimeState extends State<ScreenTime> {
  List<UsageStats> _usageStats = [];

  @override
  void initState() {
    super.initState();
    _loadUsageStats();
  }

  Future<void> _loadUsageStats() async {
    bool accessGranted = await UsageStatsHelper.isUsageAccessGranted();
    if (accessGranted) {
      DateTime now = DateTime.now();
      DateTime start = DateTime(now.hour - 12);
      // List<dynamic> data = await UsageStatsHelper.getUsageStats(start, now);
      List<UsageStats> usageStats =
          await UsageStatsHelper.getUsageStats(start, now);
      // List<UsageStats> usageStats =
      //     data.map((json) => UsageStats.fromJson(json)).toList();
      setState(() {
        _usageStats = usageStats;
      });
    } else {
      // Handle access not granted error
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usage Stats Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Usage Stats Demo'),
        ),
        body: ListView.builder(
          itemCount: _usageStats.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_usageStats[index].appName),
              subtitle: Text('Usage Time: ${_usageStats[index].usageTime}'),
              trailing: Text(
                  'Last Used: ${DateTime.fromMillisecondsSinceEpoch(_usageStats[index].lastTimeUsed)}'),
            );
          },
        ),
      ),
    );
  }
}
