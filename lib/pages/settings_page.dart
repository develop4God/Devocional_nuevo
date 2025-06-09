import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'es'; // Idioma por defecto

  Future<void> _launchPaypal() async {
    final url = Uri.parse(
        'https://www.paypal.com/donate/?hosted_button_id=CGQNBA4YPUG7A');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir PayPal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Configuración', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón de donación PayPal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Image.network(
                  'https://www.paypalobjects.com/webstatic/icon/pp258.png',
                  height: 24,
                ),
                label: const Text('Donar con PayPal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _launchPaypal,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Preferencias',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Selector de idioma alineado a la izquierda
            Row(
              children: [
                const Icon(Icons.language, color: Colors.deepPurple),
                const SizedBox(width: 10),
                const Text('Idioma:', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  items: const [
                    DropdownMenuItem(
                      value: 'es',
                      child: Text('Español'),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('Inglés'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLanguage = newValue;
                      });
                      // Aquí puedes agregar lógica para cambiar el idioma globalmente si usas un provider o similar
                    }
                  },
                ),
              ],
            ),
            // Puedes agregar más opciones aquí...
          ],
        ),
      ),
    );
  }
}
