import React from "react";
import { View, Text, TouchableOpacity, StyleSheet } from "react-native";
import { getAuth, signOut } from "firebase/auth";
import { useRouter } from "expo-router";
import { app } from "../../constants/firebaseConfig";

const auth = getAuth(app);

export default function ProfileScreen() {
  const router = useRouter();

  const handleLogout = async () => {
    await signOut(auth);
    router.replace("/auth/login");
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome 🎉</Text>
      <Text style={styles.subtitle}>{auth.currentUser?.email || auth.currentUser?.phoneNumber}</Text>

      <TouchableOpacity style={styles.button} onPress={handleLogout}>
        <Text style={styles.buttonText}>Logout</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "#f8f9fd" },
  title: { fontSize: 26, fontWeight: "700", color: "#333" },
  subtitle: { fontSize: 16, marginVertical: 10, color: "#666" },
  button: { backgroundColor: "#FF3B30", padding: 14, borderRadius: 10, marginTop: 20 },
  buttonText: { color: "#fff", fontWeight: "600" },
});
