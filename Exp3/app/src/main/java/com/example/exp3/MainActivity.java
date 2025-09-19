package com.example.exp3;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private int counter = 0;
    private TextView textCounter;
    private Button btnIncrement, btnReset;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        textCounter = findViewById(R.id.textCounter);
        btnIncrement = findViewById(R.id.btnIncrement);
        btnReset = findViewById(R.id.btnReset);

        // Increment button
        btnIncrement.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                counter++;
                textCounter.setText(String.valueOf(counter));
            }
        });

        // Reset button
        btnReset.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                counter = 0;
                textCounter.setText(String.valueOf(counter));
            }
        });
    }
}
