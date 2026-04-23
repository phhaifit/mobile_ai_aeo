export function extractTitle(markdown: string): string {
  if (!markdown) return '';

  const h1Match = markdown.match(/^#\s+(.+)$/m);
  if (h1Match && h1Match[1]) {
    return h1Match[1].trim();
  }

  // Fallback to first sentence (up to . or ! or ?)
  const firstSentence = markdown.match(/^([^.!?]+)[.!?]/);
  if (firstSentence && firstSentence[1]) {
    return firstSentence[1].trim().substring(0, 100); // Limit to 100 chars
  }

  return '';
}
