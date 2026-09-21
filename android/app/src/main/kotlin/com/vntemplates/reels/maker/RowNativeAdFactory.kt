package com.vntemplates.reels.maker

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.libraries.ads.mobile.sdk.nativead.MediaView
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

class RowNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: Map<String, Any>?): NativeAdView {
        val inflater = LayoutInflater.from(context)
        val adView = inflater.inflate(R.layout.native_row_ad, null) as NativeAdView

        // Bind ALL views
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        val headline = adView.findViewById<TextView>(R.id.ad_headline)
        val body = adView.findViewById<TextView>(R.id.ad_body)
        val store = adView.findViewById<TextView>(R.id.ad_store)
        val icon = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val stars = adView.findViewById<RatingBar>(R.id.ad_stars)
        val ctaButton = adView.findViewById<Button>(R.id.ad_call_to_action)

        adView.headlineView = headline
        adView.bodyView = body
        adView.storeView = store
        adView.iconView = icon
        adView.starRatingView = stars
        adView.callToActionView = ctaButton

        // MediaView
        mediaView?.visibility = View.VISIBLE
        if (mediaView != null && nativeAd.mediaContent != null) {
            mediaView.mediaContent = nativeAd.mediaContent
        }

        // Always try icon (safe fallback)
        nativeAd.icon?.let { iconData ->
            val iconView = adView.iconView as? ImageView
            iconView?.setImageDrawable(iconData.drawable)
            iconView?.visibility = View.VISIBLE
        } ?: run { adView.iconView?.visibility = View.GONE }

        // Stars
        if (nativeAd.starRating == null) {
            stars?.visibility = View.GONE
        } else {
            stars?.rating = nativeAd.starRating!!.toFloat()
            stars?.visibility = View.VISIBLE
        }

        // Text content
        headline?.text = nativeAd.headline
        body?.text = nativeAd.body ?: ""
        store?.text = nativeAd.store ?: ""
        ctaButton?.text = nativeAd.callToAction ?: "Install"

        // 🔥 BUTTON: Blue + 12dp radius + white text
        ctaButton?.setTextColor(Color.parseColor("#FFFFFF"))
        val buttonBg = GradientDrawable()
        buttonBg.setColor(Color.parseColor("#2E5BFF"))
        buttonBg.cornerRadius = 12f
        ctaButton?.background = buttonBg
        ctaButton?.elevation = 2f
        ctaButton?.textSize = 14f

        adView.registerNativeAd(nativeAd, mediaView)
        return adView
    }
}
