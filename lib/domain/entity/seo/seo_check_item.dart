enum SeoStatus { pass, warn, fail }

class SeoCheckItem {
  final String title;
  final String detail;
  final SeoStatus status;

  SeoCheckItem({
    required this.title,
    required this.detail,
    required this.status,
  });
}
