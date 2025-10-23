import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  FlatList,
  Image,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  TextInput,
} from 'react-native';
import axios from 'axios';
import { useRouter } from 'expo-router';

const API_KEY = 'e118e33f'; // 🔑 Replace this with your OMDb API key

export default function HomeScreen() {
  const [movies, setMovies] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState('');
  const [isSearching, setIsSearching] = useState(false);
  const router = useRouter();

  // Load some default movies (Marvel)
  useEffect(() => {
    fetchMovies('marvel');
  }, []);

  const fetchMovies = async (search: string) => {
    setLoading(true);
    try {
      const res = await axios.get(`https://www.omdbapi.com/?apikey=${API_KEY}&s=${search}`);
      setMovies(res.data.Search || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async () => {
    if (!query.trim()) {
      setIsSearching(false);
      fetchMovies('marvel'); // fallback
      return;
    }
    setIsSearching(true);
    fetchMovies(query);
  };

  const renderMovie = ({ item }: { item: any }) => (
    <TouchableOpacity
      style={styles.card}
      onPress={() => router.push(`/modal?imdbID=${item.imdbID}`)}
    >
      <Image
        source={{
          uri: item.Poster !== 'N/A' ? item.Poster : 'https://via.placeholder.com/150',
        }}
        style={styles.poster}
      />
      <Text numberOfLines={2} style={styles.title}>
        {item.Title}
      </Text>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.header}>🎬 Movie Explorer</Text>

      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <TextInput
          placeholder="Search for movies..."
          placeholderTextColor="#999"
          value={query}
          onChangeText={setQuery}
          onSubmitEditing={handleSearch}
          style={styles.input}
        />
        <TouchableOpacity style={styles.searchButton} onPress={handleSearch}>
          <Text style={styles.searchText}>Search</Text>
        </TouchableOpacity>
      </View>

      {loading ? (
        <ActivityIndicator size="large" color="#f39c12" style={{ marginTop: 20 }} />
      ) : movies.length > 0 ? (
        <FlatList
          data={movies}
          renderItem={renderMovie}
          numColumns={2}
          keyExtractor={(item) => item.imdbID}
          contentContainerStyle={{ paddingBottom: 100 }}
        />
      ) : (
        <Text style={styles.noResults}>
          {isSearching ? 'No movies found 😢' : 'Start searching for movies 🔍'}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#121212', padding: 10 },
  header: {
    color: '#fff',
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginVertical: 10,
  },
  searchContainer: {
    flexDirection: 'row',
    marginBottom: 15,
  },
  input: {
    flex: 1,
    backgroundColor: '#1f1f1f',
    color: '#fff',
    paddingHorizontal: 15,
    borderRadius: 8,
    height: 45,
  },
  searchButton: {
    backgroundColor: '#f39c12',
    marginLeft: 8,
    borderRadius: 8,
    justifyContent: 'center',
    paddingHorizontal: 15,
  },
  searchText: { color: '#fff', fontWeight: '600' },
  card: {
    flex: 1,
    margin: 8,
    backgroundColor: '#1e1e1e',
    borderRadius: 10,
    overflow: 'hidden',
    alignItems: 'center',
  },
  poster: { width: '100%', height: 200 },
  title: { color: '#fff', fontSize: 14, textAlign: 'center', padding: 8 },
  noResults: {
    color: '#aaa',
    fontSize: 16,
    textAlign: 'center',
    marginTop: 50,
  },
});
