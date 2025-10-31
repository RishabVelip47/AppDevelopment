import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from "react-native";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { useRouter } from "expo-router";
import { app } from "../../constants/firebaseConfig";

const auth = getAuth(app);

export default function SignupScreen() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");

  const handleSignup = async () => {
    if (password !== confirm) {
      Alert.alert("Passwords don’t match!");
      return;
    }

    try {
      await createUserWithEmailAndPassword(auth, email, password);
      router.replace("/profile");
    } catch (err: any) {
      Alert.alert("Signup Failed", err.message);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Create Account ✨</Text>

      <TextInput
        style={styles.input}
        placeholder="Email"
        keyboardType="email-address"
        onChangeText={setEmail}
        value={email}
      />

      <TextInput
        style={styles.input}
        placeholder="Password"
        secureTextEntry
        onChangeText={setPassword}
        value={password}
      />

      <TextInput
        style={styles.input}
        placeholder="Confirm Password"
        secureTextEntry
        onChangeText={setConfirm}
        value={confirm}
      />

      <TouchableOpacity style={styles.button} onPress={handleSignup}>
        <Text style={styles.buttonText}>Sign Up</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => router.push("/auth/login")}>
        <Text style={styles.login}>Already have an account? <Text style={{ color: "#007AFF" }}>Login</Text></Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", padding: 24, backgroundColor: "#f8f9fd" },
  title: { fontSize: 28, fontWeight: "700", marginBottom: 20, textAlign: "center", color: "#333" },
  input: { backgroundColor: "#fff", borderRadius: 10, padding: 14, marginVertical: 8, borderWidth: 1, borderColor: "#ddd" },
  button: { backgroundColor: "#007AFF", padding: 14, borderRadius: 10, marginVertical: 10 },
  buttonText: { color: "#fff", textAlign: "center", fontWeight: "600" },
  login: { textAlign: "center", marginTop: 20, color: "#333" },
});
