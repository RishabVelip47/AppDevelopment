package com.example.android_auth

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task

class GoogleLoginActivity : AppCompatActivity() {

    private lateinit var googleSignInClient: GoogleSignInClient
    private val authService = AuthService()
    private val RC_SIGN_IN = 100

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_google_login)

        // Configure Google Sign-In
        try {
            val webClientId = getString(R.string.default_web_client_id)
            
            // Check if web client ID is configured
            if (webClientId == "163515142779-jssn11r7e32kbs9258blmqina3o3oge8.apps.googleusercontent.com" || webClientId.isEmpty()) {
                Toast.makeText(
                    this, 
                    "Google Sign-In not configured. Please add web client ID in strings.xml", 
                    Toast.LENGTH_LONG
                ).show()
                findViewById<android.widget.Button>(R.id.btnGoogleSignIn).isEnabled = false
                return
            }

            val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken(webClientId)
                .requestEmail()
                .build()

            googleSignInClient = GoogleSignIn.getClient(this, gso)

            findViewById<android.widget.Button>(R.id.btnGoogleSignIn).setOnClickListener {
                signIn()
            }
        } catch (e: Exception) {
            Toast.makeText(
                this, 
                "Error configuring Google Sign-In: ${e.message}", 
                Toast.LENGTH_LONG
            ).show()
            findViewById<android.widget.Button>(R.id.btnGoogleSignIn).isEnabled = false
        }
    }

    private fun signIn() {
        val signInIntent = googleSignInClient.signInIntent
        startActivityForResult(signInIntent, RC_SIGN_IN)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == RC_SIGN_IN) {
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            handleSignInResult(task)
        }
    }

    private fun handleSignInResult(completedTask: Task<GoogleSignInAccount>) {
        try {
            val account = completedTask.getResult(ApiException::class.java)
            // Signed in successfully, authenticate with Firebase
            val idToken = account?.idToken
            if (idToken != null) {
                authService.signInWithGoogle(idToken) { success, message ->
                    if (success) {
                        Toast.makeText(this, "Google Sign-In successful!", Toast.LENGTH_SHORT).show()
                        startActivity(Intent(this, MainActivity::class.java))
                        finish()
                    } else {
                        Toast.makeText(this, message ?: "Google Sign-In failed", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        } catch (e: ApiException) {
            Toast.makeText(this, "Google Sign-In failed: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
}
