import 'package:flutter/material.dart';

class BookingDetailsPlaceholderScreen extends StatelessWidget {
  const BookingDetailsPlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This is a temporary booking details screen.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'The flow is under integration. Below are the arguments passed to this route:',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _prettyPrintArgs(args),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _prettyPrintArgs(Map<String, dynamic>? args) {
  if (args == null || args.isEmpty) return 'No arguments provided.';
  final buffer = StringBuffer();
  void writeValue(dynamic value, {int indent = 0}) {
    final String pad = '  ' * indent;
    if (value is Map) {
      buffer.writeln('{');
      value.forEach((k, v) {
        buffer.write('$pad  $k: ');
        writeValue(v, indent: indent + 1);
      });
      buffer.writeln('$pad}');
    } else if (value is List) {
      buffer.writeln('[');
      for (final v in value) {
        buffer.write('$pad  ');
        writeValue(v, indent: indent + 1);
      }
      buffer.writeln('$pad]');
    } else {
      buffer.writeln(value);
    }
  }

  args.forEach((key, value) {
    buffer.write('$key: ');
    writeValue(value, indent: 1);
  });
  return buffer.toString();
} 