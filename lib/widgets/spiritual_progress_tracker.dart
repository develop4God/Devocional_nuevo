// lib/widgets/spiritual_progress_tracker.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/models/spiritual_progress_stats.dart';

/// Widget que proporciona una interfaz simple para rastrear el progreso espiritual
/// y completar actividades como devocionales, oración y memorización de versículos.
class SpiritualProgressTracker extends StatelessWidget {
  final Devocional? currentDevocional;
  final VoidCallback? onProgressUpdated;

  const SpiritualProgressTracker({
    super.key,
    this.currentDevocional,
    this.onProgressUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DevocionalProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Progreso Espiritual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Botón para completar devocional
                if (currentDevocional != null)
                  _buildActionButton(
                    context,
                    icon: Icons.book,
                    label: 'Completar Devocional',
                    color: Colors.blue,
                    onTap: () => _completeDevotional(context, provider),
                  ),
                
                const SizedBox(height: 8),
                
                // Botón para registrar tiempo de oración
                _buildActionButton(
                  context,
                  icon: Icons.favorite,
                  label: 'Registrar Oración',
                  color: Colors.purple,
                  onTap: () => _showPrayerTimeDialog(context, provider),
                ),
                
                const SizedBox(height: 8),
                
                // Botón para registrar versículo memorizado
                _buildActionButton(
                  context,
                  icon: Icons.psychology,
                  label: 'Versículo Memorizado',
                  color: Colors.orange,
                  onTap: () => _showVerseMemorizedDialog(context, provider),
                ),

                const SizedBox(height: 16),
                
                // Mostrar estadísticas básicas
                _buildStatsPreview(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatsPreview(DevocionalProvider provider) {
    return StreamBuilder<SpiritualProgressStats?>(
      stream: provider.watchSpiritualProgressStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        
        if (stats == null) {
          return const Text(
            'Cargando estadísticas...',
            style: TextStyle(color: Colors.grey),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Progreso:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Devocionales',
                  stats.devotionalsCompleted.toString(),
                  Icons.book,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Oración (min)',
                  stats.prayerTimeMinutes.toString(),
                  Icons.favorite,
                  Colors.purple,
                ),
                _buildStatItem(
                  'Racha',
                  stats.currentStreak.toString(),
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Future<void> _completeDevotional(
    BuildContext context,
    DevocionalProvider provider,
  ) async {
    if (currentDevocional == null) return;

    try {
      await provider.markDevotionalAsCompleted(currentDevocional!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Devocional completado! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      onProgressUpdated?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar devocional: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showPrayerTimeDialog(
    BuildContext context,
    DevocionalProvider provider,
  ) async {
    final TextEditingController controller = TextEditingController();
    
    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tiempo de Oración'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cuántos minutos oraste hoy?'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minutos',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final minutes = int.tryParse(controller.text);
                if (minutes != null && minutes > 0) {
                  Navigator.of(context).pop(minutes);
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        await provider.recordPrayerTime(result);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Tiempo de oración registrado: $result minutos! 🙏'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        onProgressUpdated?.call();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar tiempo de oración: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showVerseMemorizedDialog(
    BuildContext context,
    DevocionalProvider provider,
  ) async {
    final TextEditingController controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Versículo Memorizado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Qué versículo memorizaste?'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Versículo',
                  hintText: 'Ej: Juan 3:16 - Porque de tal manera...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final verse = controller.text.trim();
                if (verse.isNotEmpty) {
                  Navigator.of(context).pop(verse);
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        await provider.recordVerseMemorized(result);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Versículo memorizado registrado! 📖'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        onProgressUpdated?.call();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar versículo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}