import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

type Props = {
  title: string;
  done: number;
  onToggle: () => void;
  onDelete: () => void;
};

export const TaskCard = ({ title, done, onToggle, onDelete }: Props) => {
  const isDone = done === 1;

  return (
    <View style={[styles.card, isDone && styles.doneCard]}>
      <TouchableOpacity onPress={onToggle} style={styles.leftSection}>
        <Ionicons
          name={isDone ? 'checkmark-circle' : 'ellipse-outline'}
          size={24}
          color={isDone ? '#4CAF50' : '#bbb'}
        />
        <Text style={[styles.title, isDone && styles.doneText]}>{title}</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={onDelete}>
        <Ionicons name="trash-outline" size={22} color="#E74C3C" />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#fff',
    padding: 14,
    borderRadius: 14,
    marginVertical: 6,
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  doneCard: { opacity: 0.7 },
  leftSection: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  title: { fontSize: 16, color: '#333', flexShrink: 1 },
  doneText: { textDecorationLine: 'line-through', color: '#999' },
});
