import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/checkin_view_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.trending_up, color: Colors.deepPurple, size: 32),
                        const SizedBox(height: 8),
                        const Text('Avg Mood', style: TextStyle(fontSize: 12)),
                        Consumer<CheckinViewModel>(
                          builder: (context, vm, child) => Text(
                            '3.5/5',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Icon(Icons.nights_stay, color: Colors.deepPurple, size: 32),
                        SizedBox(height: 8),
                        Text('Avg Sleep', style: TextStyle(fontSize: 12)),
                        Text('7.2h',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Check-ins',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.emoji_emotions)),
                  title: Text('Day ${index + 1}'),
                  subtitle: const Text('Mood: 🙂 | Sleep: 7h | Exercised'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          ),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/checkin'),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Check-in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
