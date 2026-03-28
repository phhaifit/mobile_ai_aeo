class SeoAuditRequest {
  final String url;

  SeoAuditRequest({required this.url});

  Map<String, dynamic> toMap() => {'url': url};
}
