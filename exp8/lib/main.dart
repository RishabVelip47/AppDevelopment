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

// Drawer Widget
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("John Doe"),
            accountEmail: Text("john@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.green),
            ),
            decoration: BoxDecoration(color: Colors.green),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeSlide()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text("Daily Stats"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const StatsSlide(
                        steps: 7500, calories: 450, water: 5)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text("Workout Plans"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutSlide()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSlide()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SettingsSlide()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Slide 1: Home
class HomeSlide extends StatelessWidget {
  const HomeSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StatsSlide(
                          steps: 7500, calories: 450, water: 5)),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.fitness_center),
              label: const Text('Workout Plans'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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

  const StatsSlide(
      {super.key, this.steps = 0, this.calories = 0, this.water = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Daily Stats')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            StatCard(
              icon: Icons.directions_walk,
              label: 'Steps',
              value: steps,
              goal: 10000,
              color: Colors.blue,
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
            ),
            const SizedBox(height: 20),
            StatCard(
              icon: Icons.local_fire_department,
              label: 'Calories Burned',
              value: calories,
              goal: 600,
              color: Colors.red,
              gradient: const LinearGradient(
                colors: [Colors.red, Colors.orange],
              ),
            ),
            const SizedBox(height: 20),
            StatCard(
              icon: Icons.water_drop,
              label: 'Water Intake',
              value: water,
              goal: 8,
              color: Colors.teal,
              unit: 'glasses',
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.cyan],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Stat Card Widget with Gradient
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int goal;
  final Color color;
  final String unit;
  final Gradient? gradient;

  const StatCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.value,
      required this.goal,
      required this.color,
      this.unit = '',
      this.gradient});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.8),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 20.0,
                    percent: (value / goal).clamp(0.0, 1.0),
                    center: Text('$value / $goal $unit',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white)),
                    progressColor: Colors.white,
                    backgroundColor: Colors.black26,
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
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Workout Plans')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: CheckboxListTile(
              title: Text(workouts[index],
                  style: const TextStyle(fontSize: 18)),
              value: completed[index],
              onChanged: (val) {
                setState(() {
                  completed[index] = val!;
                });
              },
              secondary:
                  const Icon(Icons.fitness_center, color: Colors.green),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          );
        },
      ),
    );
  }
}

// Slide 4: Profile
class ProfileSlide extends StatelessWidget {
  const ProfileSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text("User Profile Page",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Slide 5: Settings
class SettingsSlide extends StatelessWidget {
  const SettingsSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text("Settings Page",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
