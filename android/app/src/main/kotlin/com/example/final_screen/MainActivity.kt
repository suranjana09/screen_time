package com.example.final_screen
import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import com.example.final_screen.UsageStatsHelper
import android.provider.Settings
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.app.usage.UsageEvents



import java.util.*

class MainActivity: FlutterActivity() {
    
    private val CHANNEL = "usage_stats_helper"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "isUsageAccessGranted") {
                result.success(isUsageAccessGranted())
            } else if (call.method == "getUsageStats") {
                val start = call.argument<Long>("start")!!
                val end = call.argument<Long>("end")!!
                result.success(UsageStatsHelper.getUsageStats(this, start, end))
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isUsageAccessGranted(): Boolean {
        return if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP_MR1) {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName) == AppOpsManager.MODE_ALLOWED
        } else {
            Settings.Secure.getInt(contentResolver, "app_ops_settings_activity", -1) == 1
        }
    }
    override fun onResume() {
    super.onResume()
    if (!isUsageAccessGranted()) {
        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
    }
}
}

class UsageStatsHelper {
    companion object {
        fun getUsageStats(context: Context, start: Long, end: Long): List<Map<String, String>> {

            val calendar = Calendar.getInstance()
            calendar.set(Calendar.HOUR_OF_DAY, 0)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            val start_of_day = calendar.timeInMillis // midnight of the current day

            val end_time = System.currentTimeMillis() // current time

            val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            
             val queryUsageStats = usageStatsManager.queryUsageStats(
                    UsageStatsManager.INTERVAL_DAILY, start_of_day, end_time
            )
            
            // val queryUsageStats = usageStatsManager.queryUsageStats(
            //     UsageStatsManager.INTERVAL_BEST, start, end
            // )

            
            val stats: MutableList<Map<String, String>> = ArrayList()
            var sortedStats: List<Map<String, String>> = emptyList()
             val uniquePackages: MutableSet<String> = HashSet()

            for (usageStats in queryUsageStats) {

                  val packageName = usageStats.packageName
        if (uniquePackages.contains(packageName)) {
            continue // skip if we've already added stats for this package
        }
                val map: MutableMap<String, String> = HashMap()
                map["package_name"] = usageStats.packageName
                map["last_time_used"] = usageStats.lastTimeUsed.toString()


                val events = usageStatsManager.queryEvents(start_of_day, System.currentTimeMillis())
                var lastAppEvent: UsageEvents.Event? = null
                var timeUsedInMillis = 0L

                while (events.hasNextEvent()) {
                    val event = UsageEvents.Event()
                    events.getNextEvent(event)

                    if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED && event.packageName == usageStats.packageName) {
                        lastAppEvent = event
                    } else if (event.eventType == UsageEvents.Event.ACTIVITY_PAUSED && lastAppEvent != null) {
                        if (lastAppEvent.packageName == usageStats.packageName) {
                            val diff = event.timeStamp - lastAppEvent.timeStamp
                            timeUsedInMillis += diff
                        }
                        lastAppEvent = null
                    }
                }

                map["total_time_in_foreground"] = timeUsedInMillis.toString()


                stats.add(map)
                uniquePackages.add(packageName)
                sortedStats = stats.sortedByDescending { it["total_time_in_foreground"]?.toLongOrNull() ?: 0L }

            }
            return sortedStats
        }
    }

    
}



