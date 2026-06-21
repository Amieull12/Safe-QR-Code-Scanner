import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'result_page.dart';

class ManualInputPage extends StatefulWidget {
  const ManualInputPage({super.key});

  @override
  State<ManualInputPage> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  final TextEditingController controller = TextEditingController();

  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);

    if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
      setState(() {
        controller.text = data.text!.trim();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pasted from clipboard')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty')),
      );
    }
  }

  void checkUrl() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste or enter text first')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(url: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paste QR / URL Content'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              enableInteractiveSelection: true,
              decoration: const InputDecoration(
                labelText: 'Paste URL or QR content here',
                hintText: 'Example: https://google.com',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: pasteFromClipboard,
                icon: const Icon(Icons.paste),
                label: const Text('Paste from Clipboard'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: checkUrl,
                icon: const Icon(Icons.security),
                label: const Text('Check Content'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}