/// Route arguments passed when navigating to `SeoOptimizationScreen`.
///
/// Usage:
/// ```dart
/// Navigator.pushNamed(context, Routes.seoOptimization,
///     arguments: SeoRouteArgs(contentId: post.contentId, projectId: post.projectId));
/// ```
class SeoRouteArgs {
  final String contentId;
  final String projectId;
  final String? contentTitle;

  const SeoRouteArgs({
    required this.contentId,
    required this.projectId,
    this.contentTitle,
  });
}
