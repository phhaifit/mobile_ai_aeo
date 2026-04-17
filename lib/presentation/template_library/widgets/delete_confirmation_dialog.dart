import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/template_library/store/template_library_store.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String projectId;
  final String contentProfileId;
  final String profileName;
  final VoidCallback onSuccess;

  const DeleteConfirmationDialog({
    Key? key,
    required this.projectId,
    required this.contentProfileId,
    required this.profileName,
    required this.onSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = getIt<TemplateLibraryStore>();

    return AlertDialog(
      title: Text('Delete Content Profile?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete this profile?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile: $profileName',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        Observer(
          builder: (_) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: store.isDeletingProfile
                ? null
                : () async {
                    try {
                      await store.deleteContentProfile(
                        projectId: projectId,
                        contentProfileId: contentProfileId,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        onSuccess();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile deleted successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Error: ${store.errorStore.errorMessage}'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
            child: store.isDeletingProfile
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    ),
                  )
                : Text('Delete'),
          ),
        ),
      ],
    );
  }
}
