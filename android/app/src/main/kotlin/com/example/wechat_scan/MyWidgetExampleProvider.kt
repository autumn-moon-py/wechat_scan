package com.example.wechat_scan

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class ScanAppWidget(private val WeChatScanPage: Unit) : AppWidgetProvider() {
    override fun onUpdate(
        context: Context?,
        appWidgetManager: AppWidgetManager?,
        appWidgetIds: IntArray?
    ) {
        appWidgetIds?.forEach { appWidgetId ->
            val pendingIntent = Intent(context, WeChatScanPage::class.java).let { intent ->
                PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)
            }
            val views = RemoteViews(context?.packageName, 0)
            views.setOnClickPendingIntent(0, pendingIntent)
            appWidgetManager?.updateAppWidget(appWidgetId, views)
        }
    }
}