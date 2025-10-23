import { Stack, useLocalSearchParams, useRouter } from 'expo-router';
import { View, Text, Image, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator } from 'react-native';
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Ionicons } from '@expo/vector-icons';

const API_KEY = 'e118e33f';

export default function MovieDetails() {
  const { imdbID } = useLocalSearchParams();
  const [movie, setMovie] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const fetchDetails = async () => {
      try {
        const res = await axios.get(`https://www.omdbapi.com/?apikey=${API_KEY}&i=${imdbID}&plot=full`);
        setMovie(res.data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchDetails();
  }, [imdbID]);

  if (loading) return <ActivityIndicator size="large" color="#f39c12" style={{ marginTop: 50 }} />;

  return (
    <ScrollView style={styles.container}>
      <Stack.Screen options={{ headerShown: false }} />
      <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
        <Ionicons name="arrow-back" size={24} color="#fff" />
      </TouchableOpacity>
      <Image
        source={{ uri: movie.Poster !== 'N/A' ? movie.Poster : 'https://via.placeholder.com/300' }}
        style={styles.poster}
      />
      <Text style={styles.title}>{movie.Title}</Text>
      <Text style={styles.info}>
        {movie.Year} • {movie.Genre} • ⭐ {movie.imdbRating}
      </Text>
      <Text style={styles.plot}>{movie.Plot}</Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#121212', padding: 15 },
  backButton: { marginBottom: 10 },
  poster: { width: '100%', height: 400, borderRadius: 12, marginBottom: 15 },
  title: { color: '#fff', fontSize: 24, fontWeight: 'bold' },
  info: { color: '#f39c12', marginVertical: 5 },
  plot: { color: '#ddd', lineHeight: 22, marginTop: 10 },
});
