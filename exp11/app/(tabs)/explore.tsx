import React, { useState } from 'react';
import { View, TextInput, FlatList, Image, TouchableOpacity, StyleSheet, Text, ActivityIndicator } from 'react-native';
import axios from 'axios';
import { useRouter } from 'expo-router';

const API_KEY = 'e118e33f'; // Replace with your key

export default function ExploreScreen() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const searchMovies = async () => {
    if (!query.trim()) return;
    setLoading(true);
    try {
      const res = await axios.get(`https://www.omdbapi.com/?apikey=${API_KEY}&s=${query}`);
      setResults(res.data.Search || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const renderMovie = ({ item }: { item: any }) => (
    <TouchableOpacity style={styles.card} onPress={() => router.push(`/modal?imdbID=${item.imdbID}`)}>
      <Image
        source={{ uri: item.Poster !== 'N/A' ? item.Poster : 'https://via.placeholder.com/100' }}
        style={styles.poster}
      />
      <View style={{ flex: 1 }}>
        <Text style={styles.title}>{item.Title}</Text>
        <Text style={styles.year}>{item.Year}</Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <TextInput
        placeholder="Search movies..."
        placeholderTextColor="#888"
        value={query}
        onChangeText={setQuery}
        onSubmitEditing={searchMovies}
        style={styles.input}
      />
      {loading ? (
        <ActivityIndicator size="large" color="#f39c12" style={{ marginTop: 20 }} />
      ) : (
        <FlatList
          data={results}
          renderItem={renderMovie}
          keyExtractor={(item) => item.imdbID}
          contentContainerStyle={{ paddingBottom: 100 }}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#121212', padding: 10 },
  input: {
    backgroundColor: '#1f1f1f',
    color: '#fff',
    paddingHorizontal: 15,
    borderRadius: 8,
    height: 45,
    marginBottom: 10,
  },
  card: {
    flexDirection: 'row',
    backgroundColor: '#1e1e1e',
    marginVertical: 6,
    borderRadius: 8,
    padding: 10,
    alignItems: 'center',
  },
  poster: { width: 60, height: 90, borderRadius: 6, marginRight: 10 },
  title: { color: '#fff', fontSize: 16, fontWeight: '600' },
  year: { color: '#aaa' },
});
