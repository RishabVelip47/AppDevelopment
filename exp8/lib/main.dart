import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() => runApp(const FitnessTrackerApp());

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomeSlide(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Slide 1: Home
class HomeSlide extends StatelessWidget {
  const HomeSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.show_chart),
              label: const Text('View Daily Stats'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const StatsSlide(steps: 7500, calories: 450, water: 5)),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.fitness_center),
              label: const Text('Workout Plans'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutSlide()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Slide 2: Daily Stats
class StatsSlide extends StatelessWidget {
  final int steps;
  final int calories;
  final int water;

  const StatsSlide({super.key, this.steps = 0, this.calories = 0, this.water = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Stats')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            StatCard(
              icon: Icons.directions_walk,
              label: 'Steps',
              value: steps,
              goal: 10000,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            StatCard(
              icon: Icons.local_fire_department,
              label: 'Calories Burned',
              value: calories,
              goal: 600,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            StatCard(
              icon: Icons.water_drop,
              label: 'Water Intake',
              value: water,
              goal: 8,
              color: Colors.teal,
              unit: 'glasses',
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Stat Card Widget
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int goal;
  final Color color;
  final String unit;

  const StatCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.value,
      required this.goal,
      required this.color,
      this.unit = ''});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      shadowColor: color.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 18.0,
                    percent: (value / goal).clamp(0.0, 1.0),
                    center: Text('$value / $goal $unit',
                        style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    progressColor: color,
                    backgroundColor: Colors.grey[300]!,
                    animation: true,
                    animationDuration: 1000,
                    barRadius: const Radius.circular(10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Slide 3: Workout Plans
class WorkoutSlide extends StatefulWidget {
  const WorkoutSlide({super.key});

  @override
  _WorkoutSlideState createState() => _WorkoutSlideState();
}

class _WorkoutSlideState extends State<WorkoutSlide> {
  final List<String> workouts = [
    'Morning Yoga - 20 min',
    'Cardio - 30 min',
    'Strength Training - 25 min',
    'Evening Walk - 15 min',
  ];

  late List<bool> completed;

  @override
  void initState() {
    super.initState();
    completed = List<bool>.filled(workouts.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plans')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: CheckboxListTile(
              title: Text(workouts[index], style: const TextStyle(fontSize: 18)),
              value: completed[index],
              onChanged: (val) {
                setState(() {
                  completed[index] = val!;
                });
              },
              secondary: const Icon(Icons.fitness_center, color: Colors.green),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[800],
        child: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
