import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'safety_report_card_page.dart';
import 'url_helper.dart';

class ResultPage extends StatelessWidget {
  final String url;

  const ResultPage({
    Key? key,
    required this.url,
  }) : super(key: key);

  void copyContent(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: url),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String normalizedUrl = UrlHelper.normalizeUrl(url);
    final bool validUrl = UrlHelper.isValidHttpUrl(url);

    final Color statusColor = validUrl ? Colors.teal : Colors.orange;
    final IconData statusIcon =
        validUrl ? Icons.language : Icons.info_outline;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        title: const Text('Scan Result'),
        centerTitle: true,
        backgroundColor: statusColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 48,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Center(
                          child: Text(
                            validUrl ? 'Web URL Detected' : 'Non-URL QR Content',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: Text(
                            validUrl
                                ? 'This content can be analyzed using the Safety Report Card.'
                                : 'This content may be an attendance code, class session ID, WiFi data, or plain text.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Decoded QR Content',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SelectableText(
                                  url,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy',
                                onPressed: () => copyContent(context),
                              ),
                            ],
                          ),
                        ),

                        if (validUrl && normalizedUrl != url.trim()) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Normalized URL',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(normalizedUrl),
                        ],

                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: statusColor.withOpacity(0.45),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(statusIcon, color: statusColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  validUrl
                                      ? 'Recommended action: continue to the Safety Report Card before opening this link.'
                                      : 'Recommended action: copy this content if needed. Security API checks are skipped because it is not a web URL.',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (validUrl)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SafetyReportCardPage(url: normalizedUrl),
                        ),
                      );
                    },
                    icon: const Icon(Icons.security),
                    label: const Text('View Safety Report Card'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => copyContent(context),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy QR Content'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}