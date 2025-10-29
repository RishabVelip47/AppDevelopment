import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from "react-native";
import { getAuth, signInWithEmailAndPassword, signInWithPopup, GoogleAuthProvider } from "firebase/auth";
import { useRouter } from "expo-router";
import { app } from "../../constants/firebaseConfig";
import { Ionicons } from "@expo/vector-icons";

const auth = getAuth(app);

export default function LoginScreen() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);

  const handleLogin = async () => {
    try {
      await signInWithEmailAndPassword(auth, email, password);
      router.replace("/profile");
    } catch (err: any) {
      Alert.alert("Login Failed", err.message);
    }
  };

  const handleGoogleLogin = async () => {
    try {
      const provider = new GoogleAuthProvider();
      await signInWithPopup(auth, provider);
      router.replace("/profile");
    } catch (err: any) {
      Alert.alert("Google Login Failed", err.message);
    }
  };

  const handlePhoneLogin = () => {
    router.push("/auth/phone");
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome Back 👋</Text>

      <TextInput
        style={styles.input}
        placeholder="Email"
        keyboardType="email-address"
        onChangeText={setEmail}
        value={email}
      />

      <View style={styles.passwordContainer}>
        <TextInput
          style={[styles.input, { flex: 1 }]}
          placeholder="Password"
          secureTextEntry={!showPassword}
          onChangeText={setPassword}
          value={password}
        />
        <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
          <Ionicons name={showPassword ? "eye-off" : "eye"} size={22} color="#666" />
        </TouchableOpacity>
      </View>

      <TouchableOpacity onPress={() => Alert.alert("Forgot password?", "Password reset link feature coming soon!")}>
        <Text style={styles.forgot}>Forgot Password?</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.button} onPress={handleLogin}>
        <Text style={styles.buttonText}>Login</Text>
      </TouchableOpacity>

      <Text style={styles.or}>or</Text>

      <TouchableOpacity style={styles.googleButton} onPress={handleGoogleLogin}>
        <Ionicons name="logo-google" size={20} color="#fff" />
        <Text style={styles.googleText}>Sign in with Google</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.phoneButton} onPress={handlePhoneLogin}>
        <Ionicons name="call" size={20} color="#fff" />
        <Text style={styles.googleText}>Sign in with Phone</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => router.push("/auth/signup")}>
        <Text style={styles.signup}>Don’t have an account? <Text style={{ color: "#007AFF" }}>Sign Up</Text></Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", padding: 24, backgroundColor: "#f8f9fd" },
  title: { fontSize: 28, fontWeight: "700", marginBottom: 20, textAlign: "center", color: "#333" },
  input: { backgroundColor: "#fff", borderRadius: 10, padding: 14, marginVertical: 8, borderWidth: 1, borderColor: "#ddd" },
  passwordContainer: { flexDirection: "row", alignItems: "center", borderColor: "#ddd", borderWidth: 1, borderRadius: 10, paddingHorizontal: 10, backgroundColor: "#fff" },
  forgot: { textAlign: "right", color: "#007AFF", marginVertical: 10 },
  button: { backgroundColor: "#007AFF", padding: 14, borderRadius: 10, marginVertical: 10 },
  buttonText: { color: "#fff", textAlign: "center", fontWeight: "600" },
  or: { textAlign: "center", color: "#666", marginVertical: 10 },
  googleButton: { backgroundColor: "#DB4437", flexDirection: "row", justifyContent: "center", alignItems: "center", padding: 14, borderRadius: 10, gap: 10 },
  phoneButton: { backgroundColor: "#34A853", flexDirection: "row", justifyContent: "center", alignItems: "center", padding: 14, borderRadius: 10, gap: 10, marginTop: 10 },
  googleText: { color: "#fff", fontWeight: "600" },
  signup: { textAlign: "center", marginTop: 20, color: "#333" },
});
