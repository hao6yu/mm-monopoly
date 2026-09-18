import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/city_theme/city_theme.dart';

/// In-app privacy policy (Apple guideline 5.1.1(i): the policy must be
/// accessible inside the app, not only in the store listing).
///
/// The content mirrors what the app actually does: everything stays on
/// device, and the only network touchpoint is the optional support link.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _worldController;

  @override
  void initState() {
    super.initState();
    _worldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _worldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: CityThemeBackground(
        animation: _worldController,
        imageAsset: 'assets/images/home_city_dusk.jpg',
        imageAlignment: const Alignment(0.08, 0),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n, context),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('privacy-policy-scroll-view'),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: CityGlassPanel(
                        padding: const EdgeInsets.all(20),
                        radius: 22,
                        accent: const Color(0xFF35D5C5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.privacyLastUpdated,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              context,
                              title: l10n.privacyIntroTitle,
                              body: l10n.privacyIntro,
                            ),
                            _buildSection(
                              context,
                              title: l10n.privacyDataTitle,
                              body: l10n.privacyData,
                            ),
                            _buildSection(
                              context,
                              title: l10n.privacyPermissionsTitle,
                              body: l10n.privacyPermissions,
                            ),
                            _buildSection(
                              context,
                              title: l10n.privacyNoTrackingTitle,
                              body: l10n.privacyNoTracking,
                            ),
                            _buildSection(
                              context,
                              title: l10n.privacyChildrenTitle,
                              body: l10n.privacyChildren,
                            ),
                            _buildSection(
                              context,
                              title: l10n.privacyContactTitle,
                              body: l10n.privacyContact,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 5),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('privacy-policy-back-button'),
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF243657), Color(0xFF162541)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x555F91B5)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.privacyPolicy,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.privacyPolicyTagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mark section titles as accessibility headers so screen readers
          // can navigate the policy by heading.
          Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF9AF1E8),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
