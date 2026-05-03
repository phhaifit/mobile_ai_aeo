import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/template_library/store/template_library_store.dart';
import 'package:boilerplate/presentation/template_library/widgets/loading_widgets.dart';
import 'package:boilerplate/presentation/template_library/widgets/profile_operation_banner.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String projectId;
  final String contentProfileId;
  final String profileName;
  /// Stays valid after this dialog is popped (for loading + snackbars).
  final BuildContext hostContext;
  final VoidCallback onSuccess;

  const DeleteConfirmationDialog({
    Key? key,
    required this.projectId,
    required this.contentProfileId,
    required this.profileName,
    required this.hostContext,
    required this.onSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = getIt<TemplateLibraryStore>();
    final screenSize = MediaQuery.of(context).size;

    // Calculate responsive dimensions based on screen size
    final dialogWidth =
        screenSize.width > 600 ? 400.0 : screenSize.width * 0.85;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Delete Content Profile?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              // Divider
              const Divider(height: 1, thickness: 1),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to delete this profile?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile: $profileName',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'This action cannot be undone.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    Observer(
                      builder: (_) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: store.isDeletingProfile
                            ? null
                            : () async {
                                final host = hostContext;
                                Navigator.pop(context);

                                await Future<void>.delayed(Duration.zero);
                                if (!host.mounted) return;

                                showDialog<void>(
                                  context: host,
                                  barrierDismissible: false,
                                  builder: (_) => LoadingDialog(
                                    message: 'Deleting profile...',
                                  ),
                                );

                                try {
                                  await store.deleteContentProfile(
                                    projectId: projectId,
                                    contentProfileId: contentProfileId,
                                  );

                                  if (host.mounted) {
                                    Navigator.of(host, rootNavigator: true)
                                        .pop();
                                    onSuccess();
                                    showProfileOperationTopBanner(
                                      host,
                                      success: true,
                                      message:
                                          'Profile deleted successfully.',
                                    );
                                  }
                                } catch (e) {
                                  if (host.mounted) {
                                    Navigator.of(host, rootNavigator: true)
                                        .pop();
                                    final err =
                                        store.errorStore.errorMessage.trim();
                                    showProfileOperationTopBanner(
                                      host,
                                      success: false,
                                      message: err.isNotEmpty
                                          ? 'Failed: $err'
                                          : 'Something went wrong. Please try again.',
                                    );
                                  }
                                }
                              },
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
