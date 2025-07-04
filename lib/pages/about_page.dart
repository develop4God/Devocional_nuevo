// lib/pages/about_page.dart

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  final bool showContactSection;
  
  const AboutPage({super.key, this.showContactSection = false});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _appVersion = 'Cargando...';
  String? _selectedContactOption;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _contactOptions = [
    'Errores/Bugs',
    'Opinión/Feedback',
    'Mejoras/Improve',
    'Solicitud de oración'
  ];

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    
    // Si se accede desde la opción "Contáctenos", desplazarse automáticamente a la sección de contacto
    if (widget.showContactSection) {
      // Usar un Future.delayed para asegurar que el widget ya está construido
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Método para obtener la versión de la aplicación
  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  // Método para lanzar URL externas
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Si la URL no se puede abrir, muestra un SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Método para enviar correo electrónico de contacto
  Future<void> _sendContactEmail() async {
    if (_selectedContactOption == null) {
      // Mostrar mensaje de error si no se seleccionó una opción
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un tipo de contacto.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final String message = _messageController.text.trim();
    if (message.isEmpty) {
      // Mostrar mensaje de error si el mensaje está vacío
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escribe un mensaje.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Construir el enlace mailto con los datos del formulario
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'develop4god@gmail.com',
      query: 'subject=${Uri.encodeComponent("$_selectedContactOption - App Devocionales")}&body=${Uri.encodeComponent(message)}',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        // Limpiar el formulario después de enviar
        setState(() {
          _selectedContactOption = null;
          _messageController.clear();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir el cliente de correo. Por favor, envía un correo manualmente a develop4god@gmail.com'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el cliente de correo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme
        .of(context)
        .textTheme;
    final ColorScheme colorScheme = Theme
        .of(context)
        .colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Acerca de tu app',
          style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor), // Usa el color del foreground del AppBar del tema
        ),
        centerTitle: true, // Asegura que el título del AppBar esté centrado si hay espacio
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinea los hijos a la izquierda por defecto
          children: <Widget>[
            // Ícono de la Aplicación (Centrado como lo deseas)
            Align(
              alignment: Alignment.center, // Centra el ícono dentro de su espacio disponible
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // Bordes redondeados
                child: Image.asset(
                  'assets/icons/app_icon.png', // Ruta de tu ícono, ¡confirma que exista!
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nombre de la Aplicación
            Text(
              'Devocionales Cristianos',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary, // Usa el color primario de tu tema
              ),
              textAlign: TextAlign.left, // **Corregido:** Alineado a la izquierda
            ),
            const SizedBox(height: 8),

            // Versión de la Aplicación
            Text(
              'Versión $_appVersion',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface, // MODIFICADO: de Colors.grey[600] a colorScheme.onSurface
              ),
              textAlign: TextAlign.center, // centrado
            ),
            const SizedBox(height: 30),

            // Descripción de la Aplicación
            Text(
              'Devocionales Cristianos te trae inspiración diaria directamente a tu teléfono. Disfruta de mensajes bíblicos actualizados, explora, guarda tus favoritos, comparte la palabra y personaliza tu experiencia de lectura.',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), // MODIFICADO: Añadido colorScheme.onSurface
              textAlign: TextAlign.center, //centrado
            ),
            const SizedBox(height: 30),

            // Características Principales
            Text(
              'Características Principales:',
              style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: colorScheme.onSurface), // MODIFICADO: Añadido colorScheme.onSurface
              textAlign: TextAlign.center, // centrado
            ),
            const SizedBox(height: 10),
            const Column(  // Añadido 'const' para mejorar el rendimiento
              crossAxisAlignment: CrossAxisAlignment.start, // Los ítems de características ya están alineados a la izquierda
              children: <Widget>[
                _FeatureItem(text: '• Devocionales Diarios'),
                _FeatureItem(text: '• Soporte Multi-Versión'),
                _FeatureItem(text: '• Favoritos'),
                _FeatureItem(text: '• Compartir Contenido'),
                _FeatureItem(text: '• Oración de Fe'),
                _FeatureItem(text: '• Personalización de Idioma'),
                _FeatureItem(text: '• Interfaz Intuitiva'),
              ],
            ),
            const SizedBox(height: 30),

            // Desarrollado por
            Center( // Envuelve el texto con Center para centrarlo horizontalmente
              child: Text(
                'Desarrollado por Develop4God',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface, // MODIFICADO: de Colors.grey[700] a colorScheme.onSurface
                ),
                textAlign: TextAlign.center, // Este textAlign ahora centrará el texto dentro del Center
              ),
            ),
            const SizedBox(height: 30),

            // Enlace a la Web (Términos y Condiciones / Copyright)
            Center( // Envuelve el botón en un Center para centrarlo horizontalmente
              child: ElevatedButton.icon(
                onPressed: () => _launchURL('https://develop4god.github.io/'),
                icon: Icon(Icons.public, color: colorScheme.onPrimary), // MODIFICADO: de Colors.white a colorScheme.onPrimary
                label: Text('Términos y Condiciones / Copyright', style: TextStyle(color: colorScheme.onPrimary)), // MODIFICADO: de Colors.white a colorScheme.onPrimary
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary, // MODIFICADO: de Colors.deepPurple a colorScheme.primary
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
            
            // Sección de contacto (visible solo si showContactSection es true o si se desplaza automáticamente)
            if (widget.showContactSection) ...[
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              
              // Título de la sección de contacto
              Text(
                'Contáctenos',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              
              // Descripción
              Text(
                'Si tienes alguna pregunta, sugerencia o comentario, no dudes en ponerte en contacto con nosotros.',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              
              // Dropdown para seleccionar tipo de contacto
              DropdownButtonFormField<String>(
                value: _selectedContactOption,
                decoration: InputDecoration(
                  labelText: 'Tipo de contacto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.category, color: colorScheme.primary),
                ),
                items: _contactOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedContactOption = newValue;
                  });
                },
                hint: const Text('Selecciona una opción'),
              ),
              const SizedBox(height: 20),
              
              // Campo de texto para el mensaje
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Tu mensaje',
                  hintText: 'Escribe tu mensaje aquí...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.message, color: colorScheme.primary),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              
              // Botón de enviar
              Center(
                child: ElevatedButton.icon(
                  onPressed: _sendContactEmail,
                  icon: Icon(Icons.send, color: colorScheme.onPrimary),
                  label: Text('Enviar mensaje', style: TextStyle(color: colorScheme.onPrimary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para elementos de la lista de características
class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: Theme
            .of(context)
            .textTheme
            .bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface), // MODIFICADO: Añadido colorScheme.onSurface
        textAlign: TextAlign.center, // centrado
      ),
    );
  }
}
