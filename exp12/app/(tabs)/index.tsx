// app/(tabs)/index.tsx
import React from "react";
import { View, Text, Button, StyleSheet, Image } from "react-native";
import { signOut } from "firebase/auth";
import { auth } from "../../constants/firebaseConfig";
import { useRouter } from "expo-router";

export default function Home() {
  const router = useRouter();

  const handleSignOut = async () => {
    try {
      await signOut(auth);
      router.replace("/auth/login");
    } catch (error) {
      alert("Error signing out: " + error.message);
    }
  };

  return (
    <View style={styles.container}>
      <Image
        source={{ uri: "https://cdn-icons-png.flaticon.com/512/1077/1077012.png" }}
        style={styles.avatar}
      />
      <Text style={styles.welcome}>Welcome 👋</Text>
      <Text style={styles.subtext}>
        You are logged in successfully!
      </Text>

      <View style={styles.buttonContainer}>
        <Button title="Sign Out" onPress={handleSignOut} color="#1e90ff" />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#0b0b0b",
    alignItems: "center",
    justifyContent: "center",
    padding: 20,
  },
  avatar: {
    width: 120,
    height: 120,
    borderRadius: 60,
    marginBottom: 20,
  },
  welcome: {
    fontSize: 26,
    fontWeight: "bold",
    color: "#ffffff",
    marginBottom: 8,
  },
  subtext: {
    fontSize: 16,
    color: "#cccccc",
    marginBottom: 24,
    textAlign: "center",
  },
  buttonContainer: {
    width: "60%",
    borderRadius: 10,
    overflow: "hidden",
  },
});
