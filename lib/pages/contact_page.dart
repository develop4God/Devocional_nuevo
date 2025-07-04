// lib/pages/contact_page.dart
// Esta página permite al usuario contactar con los desarrolladores de la aplicación.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Método para enviar un correo electrónico
  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String message = _messageController.text.trim();

    // Construir el enlace mailto con los datos del formulario
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'develop4god@gmail.com',
      query: 'subject=Contacto desde App Devocionales&body=Nombre: $name%0D%0AEmail: $email%0D%0AMensaje: $message',
    );

    developer.log('Intentando abrir cliente de correo: $emailUri', name: 'EmailLaunch');

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (mounted) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abriendo cliente de correo...'),
              backgroundColor: Colors.green,
            ),
          );
          // Limpiar el formulario
          _nameController.clear();
          _emailController.clear();
          _messageController.clear();
        }
      } else {
        _showErrorSnackBar('No se pudo abrir el cliente de correo. Por favor, envía un correo manualmente a develop4god@gmail.com');
      }
    } catch (e) {
      developer.log('Error al intentar abrir cliente de correo: $e', error: e, name: 'EmailLaunch');
      _showErrorSnackBar('Error al abrir el cliente de correo: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // Método alternativo para contactar a través de WhatsApp
  Future<void> _contactViaWhatsApp() async {
    // Número de WhatsApp (sin espacios ni caracteres especiales)
    const String phoneNumber = '+34600000000'; // Reemplazar con el número real
    // Mensaje predeterminado
    const String message = 'Hola, me comunico desde la app Devocionales Cristianos.';
    
    // Construir la URL de WhatsApp
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    
    developer.log('Intentando abrir WhatsApp: $whatsappUri', name: 'WhatsAppLaunch');
    
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('No se pudo abrir WhatsApp. Asegúrate de tenerlo instalado.');
      }
    } catch (e) {
      developer.log('Error al intentar abrir WhatsApp: $e', error: e, name: 'WhatsAppLaunch');
      _showErrorSnackBar('Error al abrir WhatsApp: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacto',
          style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la página
            Text(
              'Contáctanos',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Descripción
            Text(
              'Si tienes alguna pregunta, sugerencia o comentario, no dudes en ponerte en contacto con nosotros. Estaremos encantados de ayudarte.',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 30),
            
            // Formulario de contacto
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo de nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, introduce tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  
                  // Campo de email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, introduce tu email';
                      }
                      // Validación simple de formato de email
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Por favor, introduce un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  
                  // Campo de mensaje
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Mensaje',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.message, color: colorScheme.primary),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, introduce tu mensaje';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  
                  // Botón de enviar
                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendEmail,
                    icon: _isSending 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Icon(Icons.send, color: colorScheme.onPrimary),
                    label: Text(
                      _isSending ? 'Enviando...' : 'Enviar mensaje',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            
            // Otras formas de contacto
            Text(
              'Otras formas de contacto',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            
            // WhatsApp
            ListTile(
              leading: Icon(Icons.whatsapp, color: Colors.green),
              title: Text('Contactar por WhatsApp', style: TextStyle(color: colorScheme.onSurface)),
              onTap: _contactViaWhatsApp,
            ),
            
            // Email directo
            ListTile(
              leading: Icon(Icons.email, color: colorScheme.primary),
              title: Text('develop4god@gmail.com', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'develop4god@gmail.com',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  _showErrorSnackBar('No se pudo abrir el cliente de correo');
                }
              },
            ),
            
            // Sitio web
            ListTile(
              leading: Icon(Icons.language, color: colorScheme.primary),
              title: Text('Visitar nuestro sitio web', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () async {
                final Uri webUri = Uri.parse('https://develop4god.github.io/');
                if (await canLaunchUrl(webUri)) {
                  await launchUrl(webUri, mode: LaunchMode.externalApplication);
                } else {
                  _showErrorSnackBar('No se pudo abrir el navegador');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}