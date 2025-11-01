import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import { useDatabase } from '../../hooks/useDatabase';
import { TaskCard } from '../../components/TaskCard';

export default function CompletedTasks() {
  const { getTasks, toggleTask, deleteTask } = useDatabase();
  const [tasks, setTasks] = useState<any[]>([]);

  const loadTasks = async () => setTasks(await getTasks(1));

  useEffect(() => {
    loadTasks();
  }, []);

  const handleToggle = async (task: any) => {
    await toggleTask(task.id, task.done);
    loadTasks();
  };

  const handleDelete = async (id: number) => {
    await deleteTask(id);
    loadTasks();
  };

  return (
    <View style={styles.container}>
      <Text style={styles.header}>✅ Completed Tasks</Text>
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
        ListEmptyComponent={<Text style={styles.emptyText}>No completed tasks yet!</Text>}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F9FAFB', padding: 20 },
  header: { fontSize: 26, fontWeight: '700', marginBottom: 15, color: '#222' },
  emptyText: { textAlign: 'center', marginTop: 40, color: '#999' },
});
