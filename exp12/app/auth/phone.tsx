import React, { useState, useRef } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
} from "react-native";
import { useRouter } from "expo-router";
import { RecaptchaVerifier, signInWithPhoneNumber } from "firebase/auth";
import { auth } from "../../constants/firebaseConfig";

const PhoneAuthScreen = () => {
  const router = useRouter();
  const [phone, setPhone] = useState("");
  const [otp, setOtp] = useState("");
  const [confirm, setConfirm] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const recaptchaVerifier = useRef<any>(null);

  // ✅ Send OTP
  const sendOTP = async () => {
    if (!phone) return Alert.alert("Please enter a phone number!");
    setLoading(true);
    try {
      recaptchaVerifier.current = new RecaptchaVerifier(
        auth,
        "recaptcha-container",
        {
          size: "invisible",
          callback: () => console.log("reCAPTCHA verified"),
        }
      );

      const confirmation = await signInWithPhoneNumber(auth, phone, recaptchaVerifier.current);
      setConfirm(confirmation);
      Alert.alert("OTP sent!", "Check your phone for the code.");
    } catch (err: any) {
      console.log(err);
      Alert.alert("Error", err.message);
    } finally {
      setLoading(false);
    }
  };

  // ✅ Verify OTP
  const verifyOTP = async () => {
    if (!otp) return Alert.alert("Enter the OTP!");
    setLoading(true);
    try {
      await confirm.confirm(otp);
      Alert.alert("Login Successful 🎉");
      router.replace("../tabs/profile");
    } catch (err: any) {
      Alert.alert("Invalid OTP", err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>📱 Phone Verification</Text>

      <View id="recaptcha-container" />

      {!confirm ? (
        <>
          <Text style={styles.label}>Enter your phone number</Text>
          <TextInput
            style={styles.input}
            placeholder="+91 9876543210"
            keyboardType="phone-pad"
            value={phone}
            onChangeText={setPhone}
          />
          <TouchableOpacity style={styles.button} onPress={sendOTP} disabled={loading}>
            {loading ? <ActivityIndicator color="#fff" /> : <Text style={styles.buttonText}>Send OTP</Text>}
          </TouchableOpacity>
        </>
      ) : (
        <>
          <Text style={styles.label}>Enter the OTP</Text>
          <TextInput
            style={styles.input}
            placeholder="123456"
            keyboardType="number-pad"
            value={otp}
            onChangeText={setOtp}
          />
          <TouchableOpacity style={styles.button} onPress={verifyOTP} disabled={loading}>
            {loading ? <ActivityIndicator color="#fff" /> : <Text style={styles.buttonText}>Verify OTP</Text>}
          </TouchableOpacity>
        </>
      )}
    </View>
  );
};

export default PhoneAuthScreen;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#0f172a",
    padding: 25,
    justifyContent: "center",
  },
  title: {
    fontSize: 28,
    color: "#fff",
    fontWeight: "700",
    marginBottom: 30,
    textAlign: "center",
  },
  label: {
    color: "#94a3b8",
    fontSize: 16,
    marginBottom: 10,
  },
  input: {
    backgroundColor: "#1e293b",
    borderRadius: 10,
    padding: 15,
    fontSize: 16,
    color: "#fff",
    marginBottom: 20,
  },
  button: {
    backgroundColor: "#2563eb",
    padding: 15,
    borderRadius: 10,
    alignItems: "center",
  },
  buttonText: {
    color: "#fff",
    fontWeight: "600",
    fontSize: 16,
  },
});
