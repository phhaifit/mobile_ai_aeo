enum ContentOperation { enhance, rewrite, humanize, summarize }

extension ContentOperationExt on ContentOperation {
  String get apiPath => name;

  String get displayName {
    switch (this) {
      case ContentOperation.enhance:
        return 'Enhance';
      case ContentOperation.rewrite:
        return 'Rewrite';
      case ContentOperation.humanize:
        return 'Humanize';
      case ContentOperation.summarize:
        return 'Summarize';
    }
  }
}
