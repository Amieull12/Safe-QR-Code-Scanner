import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'safe_browsing_service.dart';
import 'virustotal_service.dart';
import 'heuristic_service.dart';
import 'redirect_service.dart';
import 'blacklist_service.dart';

class SafetyReportCardPage extends StatefulWidget {
  final String url;

  const SafetyReportCardPage({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<SafetyReportCardPage> createState() => _SafetyReportCardPageState();
}

class _SafetyReportCardPageState extends State<SafetyReportCardPage> {
  bool isLoading = true;

  String originalUrl = '';
  String finalUrl = '';
  bool redirected = false;
  String redirectMessage = '';

  bool? isSafeBrowsingSafe;
  String safeBrowsingMessage = '';
  List<dynamic> googleMatches = [];

  bool? isVirusTotalSafe;
  String virusTotalMessage = '';
  int vtMalicious = 0;
  int vtSuspicious = 0;
  int vtHarmless = 0;

  @override
  void initState() {
    super.initState();
    checkLink();
  }

  Future<void> checkLink() async {
    final redirectResult = await RedirectService.inspectRedirect(widget.url);
    final inspectedUrl = redirectResult['finalUrl'] ?? widget.url;

    final safeBrowsingResult =
        await SafeBrowsingService.checkUrl(inspectedUrl);

    final virusTotalResult =
        await VirusTotalService.checkUrl(inspectedUrl);

    setState(() {
      isLoading = false;

      originalUrl = redirectResult['originalUrl'] ?? widget.url;
      finalUrl = inspectedUrl;
      redirected = redirectResult['redirected'] ?? false;
      redirectMessage = redirectResult['message'] ?? '';

      isSafeBrowsingSafe = safeBrowsingResult['safe'];
      safeBrowsingMessage = safeBrowsingResult['message'];
      googleMatches = safeBrowsingResult['matches'] ?? [];

      isVirusTotalSafe = virusTotalResult['safe'];
      virusTotalMessage = virusTotalResult['message'];
      vtMalicious = virusTotalResult['malicious'] ?? 0;
      vtSuspicious = virusTotalResult['suspicious'] ?? 0;
      vtHarmless = virusTotalResult['harmless'] ?? 0;
    });
  }

  Future<void> openLink() async {
    final String urlToOpen = finalUrl.isNotEmpty ? finalUrl : widget.url;
    final uri = Uri.parse(urlToOpen);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> openSemakMule() async {
    final uri = Uri.parse('https://semakmule.rmp.gov.my');

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  IconData getStatusIcon(String classification) {
    if (classification == 'VERIFIED SAFE') return Icons.verified;
    if (classification == 'SUSPICIOUS') return Icons.warning_amber_rounded;
    if (classification == 'DANGEROUS') return Icons.dangerous;
    if (classification == 'UNVERIFIED') return Icons.help_outline;
    return Icons.search;
  }

  Widget sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String originalCheckedUrl =
        originalUrl.isNotEmpty ? originalUrl : widget.url;

    final String checkedUrl =
        finalUrl.isNotEmpty ? finalUrl : widget.url;

    final bool suspicious =
        HeuristicService.isSuspicious(checkedUrl) ||
        HeuristicService.isSuspicious(originalCheckedUrl);

    final heuristicReasons = [
      ...HeuristicService.getReasons(originalCheckedUrl),
      ...HeuristicService.getReasons(checkedUrl),
    ].toSet().toList();

    // IMPORTANT:
    // Blacklist checks BOTH original URL and final redirected URL.
    // This fixes cases like zness.com redirecting to atom.com.
    final bool blacklisted =
        BlacklistService.isBlacklisted(originalCheckedUrl) ||
        BlacklistService.isBlacklisted(checkedUrl);

    final blacklistMatches = [
      ...BlacklistService.getMatchedItems(originalCheckedUrl),
      ...BlacklistService.getMatchedItems(checkedUrl),
    ].toSet().toList();

    final bool showSemakMule =
        HeuristicService.shouldShowSemakMuleAdvisory(originalCheckedUrl) ||
        HeuristicService.shouldShowSemakMuleAdvisory(checkedUrl) ||
        blacklisted;

    final bool unverified =
        safeBrowsingMessage.toLowerCase().contains('error') ||
        virusTotalMessage.toLowerCase().contains('error') ||
        safeBrowsingMessage.toLowerCase().contains('connection') ||
        virusTotalMessage.toLowerCase().contains('connection');

    String classification = '';
    String description = '';
    String buttonText = 'Open';
    Color riskColor = Colors.grey;

    if (isLoading) {
      classification = 'CHECKING';
      description =
          'Analyzing URL using redirect inspection, APIs, blacklist, and heuristic checks.';
      riskColor = Colors.grey;
    } else if (blacklisted) {
      classification = 'DANGEROUS';
      description =
          'This URL matches the local BNM scam reference list and is classified as malicious.';
      buttonText = 'Open Anyway';
      riskColor = Colors.red;
    } else if (unverified) {
      classification = 'UNVERIFIED';
      description =
          'The URL cannot be fully checked due to network issues or API timeout.';
      buttonText = 'Open';
      riskColor = Colors.grey;
    } else if (isSafeBrowsingSafe == false || vtMalicious >= 5) {
      classification = 'DANGEROUS';
      description =
          'The URL is confirmed or strongly indicated as malicious by threat intelligence.';
      buttonText = 'Open Anyway';
      riskColor = Colors.red;
    } else if (suspicious || redirected || vtMalicious > 0 || vtSuspicious > 0) {
      classification = 'SUSPICIOUS';
      description =
          'The URL contains suspicious indicators, redirect behavior, or mixed VirusTotal reputation.';
      buttonText = 'Open';
      riskColor = Colors.orange;
    } else {
      classification = 'VERIFIED SAFE';
      description =
          'No threat detected by APIs and the URL passed blacklist and heuristic checks.';
      buttonText = 'Open';
      riskColor = Colors.green;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Safety Report Card'),
        backgroundColor: riskColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.12),
                          border: Border.all(color: riskColor, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              getStatusIcon(classification),
                              color: riskColor,
                              size: 54,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              classification,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: riskColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),

                      sectionCard(
                        title: 'URL Information',
                        icon: Icons.link,
                        children: [
                          const Text(
                            'Original Scanned URL:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(originalCheckedUrl),
                          const SizedBox(height: 12),
                          const Text(
                            'Final Destination URL:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(checkedUrl),
                          const SizedBox(height: 8),
                          Text(
                            redirectMessage,
                            style: TextStyle(
                              color: redirected ? Colors.orange : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      if (blacklisted)
                        sectionCard(
                          title: 'BNM Local Scam Blacklist',
                          icon: Icons.verified_user,
                          children: [
                            const Text(
                              'This URL matches an item in the local scam blacklist dataset.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('Matched keyword/domain:'),
                            const SizedBox(height: 6),
                            ...blacklistMatches.map(
                              (item) => Text('• $item'),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Result: Verified as malicious by local BNM scam reference list.',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                      sectionCard(
                        title: 'Google Safe Browsing',
                        icon: Icons.security,
                        children: [
                          Text(safeBrowsingMessage),
                          if (googleMatches.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Threat Details:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...googleMatches.map(
                              (match) => Text(
                                '- ${match['threatType']} / ${match['platformType']}',
                              ),
                            ),
                          ],
                        ],
                      ),

                      sectionCard(
                        title: 'VirusTotal Analysis',
                        icon: Icons.bug_report,
                        children: [
                          Text(virusTotalMessage),
                          const SizedBox(height: 8),
                          Text('Malicious: $vtMalicious'),
                          Text('Suspicious: $vtSuspicious'),
                          Text('Harmless: $vtHarmless'),
                        ],
                      ),

                      sectionCard(
                        title: 'Local Heuristic Check',
                        icon: Icons.psychology,
                        children: [
                          if (suspicious) ...[
                            const Text('Suspicious indicators found:'),
                            const SizedBox(height: 6),
                            ...heuristicReasons.map(
                              (reason) => Text('• $reason'),
                            ),
                          ] else
                            const Text('No suspicious pattern found.'),
                        ],
                      ),

                      if (showSemakMule)
                        sectionCard(
                          title: 'Malaysia Scam Advisory',
                          icon: Icons.warning_amber_rounded,
                          children: [
                            const Text(
                              'This QR code may involve financial, contact, or personal information.',
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'For Malaysian users, please verify suspicious details using the official SemakMule portal before proceeding.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text('You may verify:'),
                            const Text('• Bank account number'),
                            const Text('• Phone number'),
                            const Text('• Company or service name'),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: openSemakMule,
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Verify with SemakMule'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : openLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: riskColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel / Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}