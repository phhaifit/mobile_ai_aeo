import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for displaying error states with retry capability
/// 
/// Shows error message and provides a retry button for users to recover
class ErrorStateWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final String? retryButtonText;
  final IconData icon;
  final String? title;

  const ErrorStateWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    this.retryButtonText,
    this.icon = Icons.error_outline,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Icon(
                icon,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),

              // Title
              if (title != null) ...[
                Text(
                  title!,
                  style: GoogleFonts.oswald(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],

              // Error message
              Text(
                errorMessage ?? 'An unexpected error occurred',
                style: GoogleFonts.montserrat(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Retry button
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying empty states
/// 
/// Shows a message when there is no data to display
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionButtonText;
  final VoidCallback? onActionButtonPressed;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.icon = Icons.inbox,
    this.actionButtonText,
    this.onActionButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionButtonText != null && onActionButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionButtonPressed,
                child: Text(actionButtonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
