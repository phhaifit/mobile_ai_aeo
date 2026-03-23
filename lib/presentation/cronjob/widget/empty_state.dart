import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';

/// Displays when no cronjobs exist
class EmptyState extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const EmptyState({
    Key? key,
    required this.onCreatePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with subtle background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.schedule_outlined,
                  size: 64,
                  color: theme.primaryColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                l10n.translate('cronjob_no_jobs'),
                style: GoogleFonts.oswald(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                l10n.translate('cronjob_no_jobs_desc'),
                style: GoogleFonts.montserrat(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Create button with modern styling
              ElevatedButton.icon(
                onPressed: onCreatePressed,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(l10n.translate('cronjob_create_new')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
