package com.example.battery_alarm_app

import android.os.Bundle
import android.util.Log
import com.polidea.rxandroidble2.exceptions.BleException
import io.flutter.embedding.android.FlutterActivity
import io.reactivex.exceptions.UndeliverableException
import io.reactivex.plugins.RxJavaPlugins

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        RxJavaPlugins.setErrorHandler {
            if (it is UndeliverableException && it.cause is BleException) {
                Log.v("Battalarm", "Suppressed UndeliverableException: $it")
            } else {
                throw RuntimeException("Unexpected Throwable in RxJavaPlugins error handler", it)
            }
        }
    }
}
