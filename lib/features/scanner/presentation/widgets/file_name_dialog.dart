import 'package:flutter/material.dart';

class FileNameDialog extends StatefulWidget {
  final String defaultFileName;

  const FileNameDialog({
    super.key,
    required this.defaultFileName,
  });

  @override
  State<FileNameDialog> createState() => _FileNameDialogState();

  static Future<String?> show(
      BuildContext context, {
        String? defaultFileName,
      }) {
    final fileName = defaultFileName ??
        'QuickScan_${DateTime.now().millisecondsSinceEpoch}';

    return showDialog<String>(
      context: context,
      builder: (context) => FileNameDialog(defaultFileName: fileName),
    );
  }
}

class _FileNameDialogState extends State<FileNameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultFileName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final fileName = _controller.text.trim();
      Navigator.pop(context, '$fileName.pdf');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Save PDF',
        style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: 22
        ),),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter file name:',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controller,
              autofocus: true,
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 14
              ),
              decoration: InputDecoration(
                hintText: 'File name',
                suffixText: '.pdf',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a file name';
                }

                // Check for invalid characters
                final invalidChars = RegExp(r'[<>:"/\\|?*]');
                if (invalidChars.hasMatch(value)) {
                  return 'File name contains invalid characters';
                }

                return null;
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 10),
            Text(
              'Note: The file will be saved to Downloads folder',
              style: theme.textTheme.bodyMedium?.copyWith(
                 // fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 11
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}