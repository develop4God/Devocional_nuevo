// lib/pages/contact_page.dart
// Esta página permite al usuario contactar con los desarrolladores de la aplicación.

import 'dart:developer' as developer;

import 'package:devocional_nuevo/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // MODIFICADO: Variables para el formulario de nombre/email eliminadas
  // final _formKey = GlobalKey<FormState>();
  // final _nameController = TextEditingController();
  // final _emailController = TextEditingController();

  // AÑADIDO: Variables para el formulario de contacto con opciones predefinidas
  String? _selectedContactOption;
  final TextEditingController _messageController = TextEditingController();
  final List<String> _contactOptions = [
    'contact.options.bugs'.tr(),
    'contact.options.feedback'.tr(),
    'contact.options.improvements'.tr(),
    'contact.options.other'.tr()
  ];

// Mantener para el indicador de envío

  @override
  void dispose() {
    // MODIFICADO: Dispose de controladores de nombre/email eliminados
    // _nameController.dispose();
    // _emailController.dispose();
    _messageController
        .dispose(); // Mantener dispose para el controlador de mensaje
    super.dispose();
  }

  // MODIFICADO: Método _sendEmail renombrado y adaptado a _sendContactEmail
  Future<void> _sendContactEmail() async {
    if (_selectedContactOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('contact.errors.select_type'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('contact.errors.write_message'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {});

    // Construir el enlace mailto con los datos del formulario de opciones
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'develop4god@gmail.com',
      query:
          'subject=${Uri.encodeComponent("$_selectedContactOption - ${'contact.email_subject'.tr()}")}&body=${Uri.encodeComponent(message)}',
    );

    developer.log('Intentando abrir cliente de correo: $emailUri',
        name: 'EmailLaunch');

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (mounted) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('contact.success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          // Limpiar el formulario
          setState(() {
            _selectedContactOption = null;
            _messageController.clear();
          });
        }
      } else {
        _showErrorSnackBar('contact.errors.no_email_client'.tr());
      }
    } catch (e) {
      developer.log('Error al intentar abrir cliente de correo: $e',
          error: e, name: 'EmailLaunch');
      _showErrorSnackBar(
          'Error al abrir el cliente de correo: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Método alternativo para contactar a través de WhatsApp (se mantiene)

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
          'contact.title'.tr(),
          style:
              TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
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
              style:
                  textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 30),

            // MODIFICADO: Formulario de contacto con opciones predefinidas
            // Eliminado: Form(key: _formKey, child: Column(...))
            // Eliminado: TextFormField para Nombre y Email

            // Dropdown para seleccionar tipo de contacto
            DropdownButtonFormField<String>(
              value: _selectedContactOption,
              decoration: InputDecoration(
                labelText: 'contact.type_label'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon:
                    Icon(Icons.topic_outlined, color: colorScheme.primary),
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
              hint: Text('contact.select_option'.tr()),
            ),
            const SizedBox(height: 20),

            // Campo de texto para el mensaje
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'contact.message_label'.tr(),
                hintText: 'contact.message_hint'.tr(),
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
                onPressed:
                    _sendContactEmail, // MODIFICADO: Llama a _sendContactEmail
                icon: Icon(Icons.send, color: colorScheme.onPrimary),
                label: Text('contact.open_email'.tr(),
                    style: TextStyle(color: colorScheme.onPrimary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // Otras formas de contacto (se mantienen)
            Text(
              'Otras formas de contacto',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),

            // Email directo
            ListTile(
              leading: Icon(Icons.email, color: colorScheme.primary),
              title: Text('develop4God@gmail.com',
                  style: TextStyle(color: colorScheme.onSurface)),
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
              title: Text('contact.website'.tr(),
                  style: TextStyle(color: colorScheme.onSurface)),
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
