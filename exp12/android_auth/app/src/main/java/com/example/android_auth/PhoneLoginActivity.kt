package com.example.android_auth

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.android_auth.databinding.ActivityPhoneLoginBinding

class PhoneLoginActivity : AppCompatActivity() {

    private lateinit var binding: ActivityPhoneLoginBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPhoneLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initially hide verification section
        binding.layoutVerificationCode.visibility = View.GONE
        binding.btnVerifyCode.visibility = View.GONE
        binding.btnResendCode.visibility = View.GONE

        // Send Code button click
        binding.btnSendCode.setOnClickListener {
            val phone = binding.inputPhoneNumber.text.toString().trim()
            if (phone.isEmpty()) {
                Toast.makeText(this, "Please enter your phone number", Toast.LENGTH_SHORT).show()
            } else {
                showVerificationUI()
                binding.txtStatus.text = "Code sent! (UI demo only)"
            }
        }

        // Verify Code button click
        binding.btnVerifyCode.setOnClickListener {
            val code = binding.inputVerificationCode.text.toString().trim()
            if (code.isEmpty()) {
                Toast.makeText(this, "Please enter verification code", Toast.LENGTH_SHORT).show()
            } else {
                binding.txtStatus.text = "Verifying... (UI demo)"
                Toast.makeText(this, "Code verified successfully (UI only)", Toast.LENGTH_SHORT).show()
            }
        }

        // Resend Code button click
        binding.btnResendCode.setOnClickListener {
            Toast.makeText(this, "Resending code... (UI only)", Toast.LENGTH_SHORT).show()
            binding.txtStatus.text = "Code resent! Check your SMS"
        }
    }

    // Show the verification code UI
    private fun showVerificationUI() {
        binding.layoutVerificationCode.visibility = View.VISIBLE
        binding.btnVerifyCode.visibility = View.VISIBLE
        binding.btnResendCode.visibility = View.VISIBLE
        binding.btnSendCode.visibility = View.GONE
    }
}
