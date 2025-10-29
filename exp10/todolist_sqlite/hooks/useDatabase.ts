import * as SQLite from 'expo-sqlite';
import { useEffect } from 'react';

const db = SQLite.openDatabaseSync('tasks.db');

export function useDatabase() {
  useEffect(() => {
    db.execAsync(`
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        done INT DEFAULT 0
      );
    `);
  }, []);

  const getTasks = async (done = 0) => {
    return await db.getAllAsync('SELECT * FROM tasks WHERE done = ? ORDER BY id DESC', [done]);
  };

  const addTask = async (title: string) => {
    await db.runAsync('INSERT INTO tasks (title, done) VALUES (?, ?)', [title, 0]);
  };

  const toggleTask = async (id: number, done: number) => {
    await db.runAsync('UPDATE tasks SET done = ? WHERE id = ?', [done ? 0 : 1, id]);
  };

  const deleteTask = async (id: number) => {
    await db.runAsync('DELETE FROM tasks WHERE id = ?', [id]);
  };

  return { getTasks, addTask, toggleTask, deleteTask };
}
