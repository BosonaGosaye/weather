import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;

    String getTitle() {
      if (lang == 'am') return "ስለ አልሚው";
      if (lang == 'om') return "Waa'ee Developer";
      return "About Developer";
    }

    String getName() {
      return "Bosona Gosaye";
    }

    String getBio() {
      if (lang == 'am') return "በተንቀሳቃሽ ስልክ መተግበሪያዎች እና በዘመናዊ የቴክኖሎጂ ውጤቶች ላይ የሚሰራ የሶፍትዌር መሐንዲስ። የኢትዮጵያን የቴክኖሎጂ እድገት ለማፋጠን እና የተሻሉ መፍትሄዎችን ለማምጣት ይተጋል።";
      if (lang == 'om') return "Injinera sooftiweerii kan application moobaayilaa fi teeknoolojii amayyaa irratti hojjetu. Guddina teeknoolojii Itoophiyaa ariifachiisuu fi furmaata fooyya'aa fiduuf carraaqqii taasisa.";
      return "A passionate Software Engineer specialized in mobile application development and modern tech stacks. Dedicated to accelerating Ethiopia's digital transformation through innovative solutions.";
    }

    String getSkillsTitle() {
      if (lang == 'am') return "ክህሎቶች";
      if (lang == 'om') return "Dandeettii";
      return "Skills";
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          getTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Image/Avatar
                    Center(
                      child: Hero(
                        tag: 'dev_avatar',
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://github.com/BosonaGosaye.png', // Replace with actual profile image if available
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white10,
                                  child: const Icon(Icons.person, size: 80, color: Colors.white70),
                                );
                              },
                            ),
                          ),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      getName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      "Full-Stack Developer",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 32),
                    // Bio Section
                    _buildGlassCard(
                      isDark: isDark,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getBio(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 32),
                  
                    // Social Links
                    Column(
                      children: [
                        _buildSocialButton(
                          icon: Icons.language_rounded,
                          label: "Portfolio",
                          onPressed: () => _launchUrl("https://bsgportfolio.vercel.app/"),
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildSocialButton(
                                icon: Icons.code,
                                label: "GitHub",
                                onPressed: () => _launchUrl("https://github.com/BosonaGosaye"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSocialButton(
                                icon: Icons.link,
                                label: "LinkedIn",
                                onPressed: () => _launchUrl("https://www.linkedin.com/in/bosona-gosaye-5887533aa/"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required String label, required VoidCallback onPressed, bool isFullWidth = false}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
