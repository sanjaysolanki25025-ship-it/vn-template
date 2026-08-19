package com.vntemplates.reels.maker

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {

    private val rowFactoryId = "row_native_ad"
    private val mediumFactoryId = "medium_native_ad"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Small / Row Native Ad
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            rowFactoryId,
            RowNativeAdFactory(this)
        )

        // Medium Native Ad
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            mediumFactoryId,
            MediumNativeAdFactory(this)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, rowFactoryId)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, mediumFactoryId)
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
