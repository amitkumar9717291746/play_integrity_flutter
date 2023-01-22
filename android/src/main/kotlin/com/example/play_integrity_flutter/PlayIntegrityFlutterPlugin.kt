package com.example.play_integrity_flutter

import android.app.Activity
import android.util.Base64
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener
import com.google.android.gms.tasks.Task
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.android.play.core.integrity.IntegrityTokenResponse
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.jose4j.jwe.JsonWebEncryption
import org.jose4j.jws.JsonWebSignature
import org.jose4j.jwx.JsonWebStructure
import org.jose4j.lang.JoseException
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.security.KeyFactory
import java.security.NoSuchAlgorithmException
import java.security.PublicKey
import java.security.SecureRandom
import java.security.spec.InvalidKeySpecException
import java.security.spec.X509EncodedKeySpec
import javax.crypto.SecretKey
import javax.crypto.spec.SecretKeySpec


private const val TAG = "PlayIntegrityFlutterPlu"

/** PlayIntegrityFlutterPlugin */
class PlayIntegrityFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var activity: Activity? = null
    private lateinit var channel: MethodChannel


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "play_integrity_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "checkGooglePlayServicesAvailability" -> checkGooglePlayServicesAvailability(result)
            "requestPlayIntegrity" -> requestPlayIntegrity(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {}


    private fun checkGooglePlayServicesAvailability(result: Result) {
        when (GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(activity!!)) {
            ConnectionResult.SUCCESS -> result.success("success")
            ConnectionResult.SERVICE_MISSING -> result.success("serviceMissing")
            ConnectionResult.SERVICE_UPDATING -> result.success("serviceUpdating")
            ConnectionResult.SERVICE_VERSION_UPDATE_REQUIRED -> result.success("serviceVersionUpdateRequired")
            ConnectionResult.SERVICE_DISABLED -> result.success("serviceDisabled")
            ConnectionResult.SERVICE_INVALID -> result.success("serviceInvalid")
            else -> result.error("Error", "Unknown error code", null)
        }
    }

    private fun getNonceFrom(call: MethodCall): ByteArray? {
        return when {
            call.hasArgument("nonce_bytes") -> {
                call.argument("nonce_bytes")
            }
            call.hasArgument("nonce_string") -> {
                getRequestNonce(call.argument("nonce_string") as? String ?: "")
            }
            else -> {
                null
            }
        }
    }

    private fun getRequestNonce(data: String): ByteArray? {
        val byteStream = ByteArrayOutputStream()
        val bytes = ByteArray(24)
        SecureRandom().nextBytes(bytes)
        try {
            byteStream.write(bytes)
            byteStream.write(data.toByteArray())
        } catch (e: IOException) {
            return null
        }
        return byteStream.toByteArray()
    }


    private fun requestPlayIntegrity(call: MethodCall, result: Result) {
        if (GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(activity!!)
            != ConnectionResult.SUCCESS
        ) {
            result.error(
                "Error",
                "Google Play Services are not available, please call the checkGooglePlayServicesAvailability() method to understand why",
                null
            )
            return
        } else if (!call.hasArgument("nonce_bytes") && !call.hasArgument("nonce_string")) {
            result.error("Error", "Please include the nonce in the request", null)
            return
        } else if (!call.hasArgument("decryption_key")) {
            result.error("Error", "Please include the \"Decryption Key\" in the request", null)
            return
        } else if (!call.hasArgument("verification_key")) {
            result.error("Error", "Please include the \"Verification Key\" in the request", null)
            return
        }

        // Check nonce
        val nonce: ByteArray? = getNonceFrom(call)
        if (nonce == null || nonce.size < 16) {
            result.error("Error", "The nonce should be larger than the 16 bytes", null)
            return
        }

        // DECRYPTION KEY
        val decryptionKey = call.argument<String>("decryption_key")

        // VERIFICATION KEY
        val verificationKey = call.argument<String>("verification_key")

        val integrityManager =
            IntegrityManagerFactory.create(activity)


        val integrityTokenResponse: Task<IntegrityTokenResponse> = integrityManager
            .requestIntegrityToken(
                IntegrityTokenRequest.builder()
                    .setNonce(nonce.toString())
                    .build()
            )
            .addOnSuccessListener(
                (OnSuccessListener { response: IntegrityTokenResponse ->
                    val integrityToken = response.token()
                    Log.d(TAG, integrityToken)
                    val decryptionKeyBytes: ByteArray =
                        Base64.decode(decryptionKey, Base64.DEFAULT)

                    // SecretKey
                    val decryptionKey: SecretKey = SecretKeySpec(
                        decryptionKeyBytes,
                        0,
                        decryptionKeyBytes.size,
                        "AES"
                    )
                    val encodedVerificationKey: ByteArray =
                        Base64.decode(verificationKey, Base64.DEFAULT)

                    // PublicKey
                    var verificationKey: PublicKey? = null
                    try {
                        verificationKey = KeyFactory.getInstance("EC")
                            .generatePublic(X509EncodedKeySpec(encodedVerificationKey))
                    } catch (e: InvalidKeySpecException) {
                        Log.d(TAG, e.message!!)
                    } catch (e: NoSuchAlgorithmException) {
                        Log.d(TAG, e.message!!)
                    }

                    // some error occurred so return
                    if (null == verificationKey) {
                        return@OnSuccessListener
                    }

                    // JsonWebEncryption
                    var jwe: JsonWebEncryption? = null
                    try {
                        jwe = JsonWebStructure
                            .fromCompactSerialization(integrityToken) as JsonWebEncryption
                    } catch (e: JoseException) {
                        e.printStackTrace()
                    }

                    // some error occurred so return
                    if (null == jwe) {
                        return@OnSuccessListener
                    }
                    jwe.key = decryptionKey
                    var compactJws: String? = null
                    try {
                        compactJws = jwe.payload
                    } catch (e: JoseException) {
                        Log.d(TAG, e.message!!)
                    }

                    // JsonWebSignature
                    var jws: JsonWebSignature? = null
                    try {
                        jws = JsonWebStructure
                            .fromCompactSerialization(compactJws) as JsonWebSignature
                    } catch (e: JoseException) {
                        Log.d(TAG, e.message!!)
                    }

                    // some error occurred so return
                    if (null == jws) {
                        return@OnSuccessListener
                    }
                    jws.key = verificationKey

                    // get the json human readable string
                    var jsonPlainVerdict: String? = ""
                    jsonPlainVerdict = try {
                        jws.payload
                    } catch (e: JoseException) {
                        Log.d(TAG, e.message!!)
                        return@OnSuccessListener
                    }

                    // payload is available in json format
                    // plain text, can be processed as per needs
                    Log.d(TAG, jsonPlainVerdict!!)
                    result.success(jsonPlainVerdict)
                } as OnSuccessListener<IntegrityTokenResponse>)
            )
            .addOnFailureListener((OnFailureListener {
                it.printStackTrace()
                if (it is ApiException) {
                    result.error(
                        "Error",
                        CommonStatusCodes.getStatusCodeString(it.statusCode) + " : " +
                                it.message, null
                    )
                } else {
                    result.error("Error", it.message, null)
                }
            } as OnFailureListener))

    }


}
