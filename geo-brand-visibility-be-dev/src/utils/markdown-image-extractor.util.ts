import * as cheerio from 'cheerio';
import { ImageMetadata } from '../content/dto/image-metadata.dto';

const IMAGE_EXT_REGEX =
  /\.(?:jpe?g|png|gif|webp|avif|svg|bmp|tiff)(?:\?[^"']*)?$/i;

function toValidUrl(raw: string | null | undefined): string | null {
  if (!raw) return null;
  const trimmed = raw.trim();
  if (!trimmed || trimmed === '#' || trimmed.startsWith('data:')) return null;
  return trimmed;
}

/**
 * Extracts the best available image URL from an <img> attributes string by
 * checking src, data-src, and data-lazy-src in order.
 */
function resolveImgUrl($img: cheerio.Cheerio<any>): string | null {
  for (const attr of ['src', 'data-src', 'data-lazy-src']) {
    const url = toValidUrl($img.attr(attr));
    if (url) return url;
  }
  return null;
}

export function extractImagesFromHtml(
  html: string | undefined,
  pageUrl: string,
): ImageMetadata[] {
  if (!html) return [];

  const $ = cheerio.load(html);
  const images: ImageMetadata[] = [];

  $('img').each((_, el) => {
    const img = $(el);

    const altText = img.attr('alt') ?? undefined;
    const context = extractContextFromHtml($, img);
    if (!altText && !context) return;

    let imageUrl = resolveImgUrl(img);

    // fallback: check if parent <a> wraps the image
    if (!imageUrl) {
      const parentLink = img.closest('a');
      const href = toValidUrl(parentLink.attr('href'));

      if (href && IMAGE_EXT_REGEX.test(href)) {
        imageUrl = href;
      }
    }

    if (!imageUrl) return;

    try {
      imageUrl = new URL(imageUrl, pageUrl).href;
    } catch {
      return;
    }

    images.push({
      sourceUrl: imageUrl,
      altText,
      context,
    });
  });

  return images;
}

export function extractImagesFromMarkdown(
  markdown: string,
  pageUrl: string,
): ImageMetadata[] {
  if (!markdown) {
    return [];
  }

  const images: ImageMetadata[] = [];

  const imageRegex = /!\[([^\]]*)\]\(([^)\s]+)(?:\s+"([^"]*)")?\)/g; //![alt text](url)

  let match;
  while ((match = imageRegex.exec(markdown)) !== null) {
    const altText = match[1] || '';
    let rawUrl: string = match[2];
    const originalUrl = rawUrl;
    const title = match[3] || '';

    if (!rawUrl) continue;

    if (rawUrl.startsWith('data:')) {
      continue;
    }

    try {
      rawUrl = new URL(rawUrl, pageUrl).href;
    } catch {
      continue;
    }

    images.push({
      sourceUrl: rawUrl,
      originalUrl,
      altText: altText || title || undefined,
      caption: title || undefined,
    });
  }

  return images;
}

/**
 * Extract og:image from HTML meta tags.
 * This is the most reliable way to get a page's featured/share image.
 */
export function extractOgImage(
  html: string | undefined,
  pageUrl: string,
): string | null {
  if (!html) return null;

  const $ = cheerio.load(html);

  // Try og:image first, then twitter:image
  const ogImage =
    $('meta[property="og:image"]').attr('content') ||
    $('meta[name="twitter:image"]').attr('content') ||
    $('meta[name="twitter:image:src"]').attr('content');

  if (!ogImage) return null;

  try {
    return new URL(ogImage, pageUrl).href;
  } catch {
    return null;
  }
}

function extractContextFromHtml(
  $: cheerio.CheerioAPI,
  $img: cheerio.Cheerio<any>,
): string | undefined {
  let $current: cheerio.Cheerio<any> = $img;

  while ($current.length) {
    const $heading = $current.prevAll('h1, h2, h3, h4, h5, h6').first();
    if ($heading.length) {
      return $heading.text().trim() || undefined;
    }
    $current = $current.parent();
  }

  return undefined;
}
