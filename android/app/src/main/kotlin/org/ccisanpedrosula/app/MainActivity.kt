package org.ccisanpedrosula.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // Con launchMode singleTop, al tocar una notificación FCM Android reusa la Activity
    // y entrega el Intent en onNewIntent. Sin setIntent, el plugin no ve el click.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
