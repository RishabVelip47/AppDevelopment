package com.example.android_auth

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.tabs.TabLayoutMediator
import android.widget.Button
import androidx.viewpager2.widget.ViewPager2

class MainActivity : AppCompatActivity() {

    private val authService = AuthService()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val viewPager: ViewPager2 = findViewById(R.id.viewPager)
        val tabLayout = findViewById<com.google.android.material.tabs.TabLayout>(R.id.tabLayout)
        viewPager.adapter = DashboardPagerAdapter(this)

        TabLayoutMediator(tabLayout, viewPager) { tab, position ->
            tab.text = if (position == 0) "Home" else "Profile"
        }.attach()

        findViewById<Button>(R.id.btnLogout).setOnClickListener {
            authService.logout()
            startActivity(Intent(this, LoginActivity::class.java))
            finish()
        }
    }
}
