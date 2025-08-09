// Example Integration in DevocionalPage
// This shows how to integrate the spiritual progress tracking
// into an existing devotional reading page

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/widgets/spiritual_progress_tracker.dart';

class DevotionalReadingPageExample extends StatefulWidget {
  final Devocional devocional;

  const DevotionalReadingPageExample({
    super.key,
    required this.devocional,
  });

  @override
  State<DevotionalReadingPageExample> createState() => _DevotionalReadingPageExampleState();
}

class _DevotionalReadingPageExampleState extends State<DevotionalReadingPageExample> {
  bool _hasCompletedReading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi espacio íntimo con Dios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showStatsDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Devotional Content
            _buildDevotionalContent(),
            
            const SizedBox(height: 24),
            
            // Progress Tracker - Only show if user has read the content
            if (_hasCompletedReading)
              SpiritualProgressTracker(
                currentDevocional: widget.devocional,
                onProgressUpdated: () {
                  _showCelebration();
                },
              ),
            
            // Reading completion button
            if (!_hasCompletedReading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasCompletedReading = true;
                    });
                  },
                  child: const Text('He terminado de leer'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevotionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatDate(widget.devocional.date),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Verse
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.devocional.versiculo,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Reflection
        const Text(
          'Reflexión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.devocional.reflexion,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Meditation Points
        if (widget.devocional.paraMeditar.isNotEmpty) ...[
          const Text(
            'Para Meditar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.devocional.paraMeditar.map((punto) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punto.cita,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  punto.texto,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          )),
        ],
        
        const SizedBox(height: 16),
        
        // Prayer
        const Text(
          'Oración',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.devocional.oracion,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  void _showCelebration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Felicitaciones! 🎉'),
        content: const Text(
          'Has registrado tu progreso espiritual. '
          '¡Que Dios bendiga tu dedicación!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Amén'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Progreso Espiritual'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<DevocionalProvider>(
            builder: (context, provider, child) {
              return StreamBuilder(
                stream: provider.watchSpiritualProgressStats(),
                builder: (context, snapshot) {
                  final stats = snapshot.data;
                  
                  if (stats == null) {
                    return const CircularProgressIndicator();
                  }
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow('Devocionales completados', stats.devotionalsCompleted),
                      _buildStatRow('Tiempo de oración', '${stats.prayerTimeMinutes} min'),
                      _buildStatRow('Versículos memorizados', stats.versesMemorized),
                      _buildStatRow('Racha actual', '${stats.currentStreak} días'),
                      const SizedBox(height: 16),
                      Text(
                        'Última actividad: ${_formatDate(stats.lastActivityDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Example of how to navigate to this page
class NavigationExample {
  static void openDevotionalWithProgress(
    BuildContext context,
    Devocional devocional,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DevotionalReadingPageExample(
          devocional: devocional,
        ),
      ),
    );
  }
}

// Example of automatic tracking integration
class AutoTrackingExample {
  static Future<void> setupAutomaticTracking(DevocionalProvider provider) async {
    // This could be called when the app starts or when a user logs in
    
    // Listen to provider changes and automatically track certain activities
    provider.addListener(() {
      // Example: Auto-track when favorites are added (could indicate engagement)
      // This is just an example - you'd implement based on your app's specific flows
    });
  }
}