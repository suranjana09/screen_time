import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class UsageStatsHelper {
  static const MethodChannel _channel =
      const MethodChannel('usage_stats_helper');

  static Future<bool> isUsageAccessGranted() async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('isUsageAccessGranted');
    }
    return false;
  }

  static Future<List<UsageStats>> getUsageStats(
      DateTime start, DateTime end) async {
    if (Platform.isAndroid) {
      // DateTime start = DateTime.now().subtract(Duration(hours: 24));
      DateTime end = DateTime.now();
      DateTime start = DateTime(end.year, end.month, end.day, 00);

      // print(start.millisecondsSinceEpoch);

      // print(start);
      // print(end);
      List<dynamic> result = await _channel.invokeMethod('getUsageStats', {
        "start": start.millisecondsSinceEpoch,
        "end": end.millisecondsSinceEpoch
      });
      print(result);
      List<UsageStats> usageStats = [];

      for (dynamic data in result) {
        // print('11111111111111111');
        usageStats.add(UsageStats.fromJson(Map<String, dynamic>.from(data)));
      }
      // print(await usageStats);
      return usageStats;
    }
    return [];
  }
}

class UsageStats {
  String packageName;
  String appName;
  String usageTime; // in milliseconds
  int lastTimeUsed; // in milliseconds

  UsageStats({
    required this.packageName,
    required this.appName,
    required this.usageTime,
    required this.lastTimeUsed,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    // print('122712777');
    // print(json['packageName']);
    // print(json['appName']);
    // print(json['usageTime']);
    // print(json['lastTimeUsed']);
    // print(2055555555555555555);

    print(json['total_time_in_foreground']);

    return UsageStats(
      packageName: json['package_name'] ?? '',
      appName: json['app_name'] ?? '',
      usageTime: json['total_time_in_foreground'] ?? '',
      lastTimeUsed: json['lastTimeUsed'] ?? 0,
    );
  }
}
