import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon (optional)
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.document_scanner,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 16),

            // App Name
            Text(
              'QuickScan PDF',
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 26
              ),
            ),

            const SizedBox(height: 6),

            // Tagline
            Text(
              'Fast & Secure PDF Scanner',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontSize: 12
              ),
            ),

            const SizedBox(height: 24),

            // Description
            Text(
              'QuickScan is a fast, secure, and easy-to-use document scanning app '
                  'that turns your phone into a powerful portable scanner.\n\n'
                  'Scan documents, receipts, IDs, notes, and contracts in seconds. '
                  'With smart edge detection and high-quality PDF output, '
                  'QuickScan delivers professional results every time.',

                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: 12
                ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Features Section
            _sectionTitle(context, 'Key Features'),
            const SizedBox(height: 12),
            _featureItem(context, 'High-quality document scanning'),
            _featureItem(context, 'Smart auto-crop & edge detection'),
            _featureItem(context, 'Scan enhancement filters'),
            _featureItem(context, 'Easy PDF saving & organization'),
            _featureItem(context, 'Files stay private on your device'),

            const SizedBox(height: 32),

            // Developer Section
            _sectionTitle(context, 'Developer'),
            const SizedBox(height: 10),
            Text(
              'Developed by Abonyi Linus O.',
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 12
              ),
            ),

            const SizedBox(height: 42),

            // Footer
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "© $currentYear QuickScan PDF . All rights reserved.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),


          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: 12
        ),
      ),
    );
  }

  static Widget _featureItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 12
              ),
            ),
          ),
        ],
      ),
    );
  }
}
