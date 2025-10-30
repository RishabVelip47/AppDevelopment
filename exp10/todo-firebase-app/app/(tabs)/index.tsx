import React, { useEffect, useState } from "react";
import { View, FlatList, TextInput, StyleSheet, Alert, ScrollView } from "react-native";
import { Card, Text, IconButton, Checkbox } from "react-native-paper";
import { db } from "./firebaseConfig";
import {
  collection,
  addDoc,
  updateDoc,
  deleteDoc,
  doc,
  onSnapshot,
  QueryDocumentSnapshot,
  DocumentData,
} from "firebase/firestore";

interface Task {
  id: string;
  name: string;
  completed: boolean;
}

export default function App() {
  const [task, setTask] = useState<string>("");
  const [tasks, setTasks] = useState<Task[]>([]);
  const [history, setHistory] = useState<Task[]>([]);
  const todoRef = collection(db, "todos");

  // 🔄 Real-time listener
  useEffect(() => {
    const unsubscribe = onSnapshot(todoRef, (snapshot) => {
      const allTasks: Task[] = snapshot.docs.map(
        (doc: QueryDocumentSnapshot<DocumentData>) => ({
          id: doc.id,
          name: doc.data().name,
          completed: doc.data().completed ?? false,
        })
      );
      setTasks(allTasks.filter((t) => !t.completed));
      setHistory(allTasks.filter((t) => t.completed));
    });

    return unsubscribe;
  }, []);

  // ➕ Add new task
  const addTask = async () => {
    if (task.trim() === "") return Alert.alert("Enter a task!");
    try {
      await addDoc(todoRef, { name: task, completed: false });
      setTask("");
    } catch (error) {
      Alert.alert("Error adding task", String(error));
    }
  };

  // ✅ Mark task as completed
  const completeTask = async (id: string) => {
    try {
      const taskDoc = doc(db, "todos", id);
      await updateDoc(taskDoc, { completed: true });
    } catch (error) {
      Alert.alert("Error completing task", String(error));
    }
  };

  // 🗑 Delete completed task
  const deleteTask = async (id: string) => {
    try {
      const taskDoc = doc(db, "todos", id);
      await deleteDoc(taskDoc);
    } catch (error) {
      Alert.alert("Error deleting task", String(error));
    }
  };

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.header}>📝 My To-Do List</Text>

      {/* Input Section */}
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Add a new task..."
          value={task}
          onChangeText={setTask}
        />
        <IconButton icon="plus" size={28} onPress={addTask} style={{ backgroundColor: "#4caf50" }} />
      </View>

      {/* Active Tasks */}
      <Text style={styles.tableHeader}>Active Tasks</Text>
      {tasks.length === 0 ? (
        <Text style={styles.noTask}>🎉 No active tasks!</Text>
      ) : (
        <FlatList
          data={tasks}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <Card style={styles.card}>
              <Card.Content style={[styles.taskRow, { backgroundColor: "#fffde7", borderRadius: 10 }]}>
                <Text style={styles.taskText}>{item.name}</Text>
                <Checkbox
                  status={item.completed ? "checked" : "unchecked"}
                  onPress={() => completeTask(item.id)}
                  color="#4caf50"
                />
              </Card.Content>
            </Card>
          )}
        />
      )}

      {/* Completed Tasks */}
      <Text style={styles.tableHeader}>Completed Tasks</Text>
      {history.length === 0 ? (
        <Text style={styles.noTask}>No completed tasks yet</Text>
      ) : (
        <FlatList
          data={history}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <Card style={styles.card}>
              <Card.Content style={[styles.taskRow, { backgroundColor: "#e0f7fa", borderRadius: 10 }]}>
                <Text style={[styles.taskText, { textDecorationLine: "line-through", color: "#0097a7" }]}>
                  {item.name}
                </Text>
                <IconButton
                  icon="delete"
                  size={26}
                  onPress={() => deleteTask(item.id)}
                />
              </Card.Content>
            </Card>
          )}
        />
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, backgroundColor: "#f3f3f3" },
  header: { fontSize: 28, fontWeight: "bold", marginBottom: 20, textAlign: "center" },
  inputContainer: { flexDirection: "row", marginBottom: 20, alignItems: "center" },
  input: {
    borderWidth: 1,
    borderColor: "#ccc",
    padding: 10,
    flex: 1,
    marginRight: 10,
    borderRadius: 8,
    backgroundColor: "#fff",
  },
  tableHeader: { fontSize: 22, fontWeight: "600", marginTop: 20, marginBottom: 10, color: "#333" },
  noTask: { fontStyle: "italic", color: "#888", marginBottom: 10 },
  card: { marginVertical: 5, borderRadius: 10 },
  taskRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  taskText: { fontSize: 16 },
});
