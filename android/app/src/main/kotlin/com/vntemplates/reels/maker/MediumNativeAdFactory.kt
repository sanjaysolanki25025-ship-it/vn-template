
package com.vntemplates.reels.maker
import android.content.Context
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import android.widget.RatingBar

import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.NativeAdFactory

class MediumNativeAdFactory(private val context: Context) : NativeAdFactory {

    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {

        val inflater = LayoutInflater.from(context)
        val adView = inflater.inflate(R.layout.native_medium_ad, null) as NativeAdView

        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        val headline = adView.findViewById<TextView>(R.id.ad_headline)
        val body = adView.findViewById<TextView>(R.id.ad_body)
        val icon = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val store = adView.findViewById<TextView>(R.id.ad_store)
        val stars = adView.findViewById<RatingBar>(R.id.ad_stars)
        val price = adView.findViewById<TextView>(R.id.ad_price)
        val cta = adView.findViewById<Button>(R.id.ad_call_to_action)

        adView.mediaView = mediaView
        adView.headlineView = headline
        adView.bodyView = body
        adView.iconView = icon
        adView.storeView = store
        adView.starRatingView = stars
        adView.priceView = price
        adView.callToActionView = cta

        // headline
        headline.text = nativeAd.headline

        // body
        if (nativeAd.body == null) {
            body.visibility = View.GONE
        } else {
            body.text = nativeAd.body
            body.visibility = View.VISIBLE
        }

        // store
        if (nativeAd.store == null) {
            store.visibility = View.GONE
        } else {
            store.text = nativeAd.store
            store.visibility = View.VISIBLE
        }

        // stars
        if (nativeAd.starRating == null) {
            stars.visibility = View.GONE
        } else {
            stars.rating = nativeAd.starRating!!.toFloat()
            stars.visibility = View.VISIBLE
        }

        // price
        if (nativeAd.price == null) {
            price.visibility = View.GONE
        } else {
            price.text = nativeAd.price
            price.visibility = View.VISIBLE
        }

        // icon
        if (nativeAd.icon != null) {
            icon.setImageDrawable(nativeAd.icon!!.drawable)
            icon.visibility = View.VISIBLE
        } else {
            icon.visibility = View.GONE
        }

        // CTA
        cta.text = nativeAd.callToAction ?: "Install"
        adView.setNativeAd(nativeAd)

        // rounded button
        val radius = 8f * context.resources.displayMetrics.density
        val drawable = android.graphics.drawable.GradientDrawable()
        drawable.setColor(Color.parseColor("#2E5BFF"))
        drawable.cornerRadius = radius
        cta.background = drawable

        return adView
    }
}