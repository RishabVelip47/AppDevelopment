import React, { useEffect, useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, FlatList, StyleSheet, KeyboardAvoidingView, Platform } from 'react-native';
import { useDatabase } from '../../hooks/useDatabase';
import { TaskCard } from '../../components/TaskCard';

export default function ActiveTasks() {
  const { getTasks, addTask, toggleTask, deleteTask } = useDatabase();
  const [tasks, setTasks] = useState<any[]>([]);
  const [title, setTitle] = useState('');

  const loadTasks = async () => setTasks(await getTasks(0));

  useEffect(() => {
    loadTasks();
  }, []);

  const handleAdd = async () => {
    if (!title.trim()) return;
    await addTask(title);
    setTitle('');
    loadTasks();
  };

  const handleToggle = async (task: any) => {
    await toggleTask(task.id, task.done);
    loadTasks();
  };

  const handleDelete = async (id: number) => {
    await deleteTask(id);
    loadTasks();
  };

  return (
    <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Text style={styles.header}>🟩 Active Tasks</Text>

      <View style={styles.inputContainer}>
        <TextInput
          placeholder="Add a new task..."
          value={title}
          onChangeText={setTitle}
          style={styles.input}
          placeholderTextColor="#999"
        />
        <TouchableOpacity style={styles.addBtn} onPress={handleAdd}>
          <Text style={styles.addText}>+</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={tasks}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <TaskCard
            title={item.title}
            done={item.done}
            onToggle={() => handleToggle(item)}
            onDelete={() => handleDelete(item.id)}
          />
        )}
        ListEmptyComponent={<Text style={styles.emptyText}>No active tasks 🎉</Text>}
      />
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F9FAFB', padding: 20 },
  header: { fontSize: 26, fontWeight: '700', marginBottom: 15, color: '#222' },
  inputContainer: { flexDirection: 'row', marginBottom: 15 },
  input: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 12,
    paddingHorizontal: 15,
    fontSize: 16,
    height: 50,
    borderWidth: 1,
    borderColor: '#eee',
  },
  addBtn: {
    width: 50,
    height: 50,
    backgroundColor: '#4CAF50',
    borderRadius: 12,
    marginLeft: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  addText: { fontSize: 28, color: '#fff', marginBottom: 4 },
  emptyText: { textAlign: 'center', marginTop: 40, color: '#999' },
});
