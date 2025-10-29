import React from "react";
import { TouchableOpacity, Text, StyleSheet, Image, View, Platform } from "react-native";
import * as WebBrowser from "expo-web-browser";
import * as Google from "expo-auth-session/providers/google";
import { GoogleAuthProvider, signInWithCredential } from "firebase/auth";
import { auth } from "../constants/firebaseConfig";
import { useRouter } from "expo-router";
import Constants from "expo-constants";

WebBrowser.maybeCompleteAuthSession();

export default function GoogleButton() {
  const router = useRouter();

  const [request, response, promptAsync] = Google.useAuthRequest({
    expoClientId: Constants.expoConfig?.extra?.googleClientId,
    webClientId: "514154718737-1e8c6074r4j3bnq2ibeos9p0u3212u48.apps.googleusercontent.com",
  });

  React.useEffect(() => {
    if (response?.type === "success") {
      const { id_token } = response.params;
      const credential = GoogleAuthProvider.credential(id_token);
      signInWithCredential(auth, credential)
        .then(() => router.replace("/(tabs)/profile"))
        .catch((err) => alert(err.message));
    }
  }, [response]);

  return (
    <TouchableOpacity style={styles.button} onPress={() => promptAsync()}>
      <View style={styles.inner}>
        <Image
          source={{
            uri: "https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg",
          }}
          style={styles.icon}
        />
        <Text style={styles.text}>Continue with Google</Text>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    backgroundColor: "#fff",
    borderColor: "#ccc",
    borderWidth: 1,
    borderRadius: 30,
    paddingVertical: 12,
    paddingHorizontal: 20,
    width: "85%",
    alignSelf: "center",
    marginTop: 10,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  inner: { flexDirection: "row", alignItems: "center", justifyContent: "center" },
  icon: { width: 20, height: 20, marginRight: 10 },
  text: { color: "#444", fontWeight: "600", fontSize: 15 },
});
