import * as crypto from 'crypto';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16;
const ENCRYPTED_PREFIX = 'enc:';

/**
 * Encrypt a string using AES-256-GCM.
 * Returns format: "enc:{iv_hex}:{authTag_hex}:{ciphertext_hex}"
 */
export function encryptValue(plaintext: string, key: string): string {
  const keyBuffer = Buffer.from(key, 'hex');
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, keyBuffer, iv);

  let encrypted = cipher.update(plaintext, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  const authTag = cipher.getAuthTag().toString('hex');

  return `${ENCRYPTED_PREFIX}${iv.toString('hex')}:${authTag}:${encrypted}`;
}

/**
 * Decrypt an encrypted string.
 * Expects format: "enc:{iv_hex}:{authTag_hex}:{ciphertext_hex}"
 */
export function decryptValue(encryptedText: string, key: string): string {
  if (!encryptedText.startsWith(ENCRYPTED_PREFIX)) {
    return encryptedText;
  }

  const withoutPrefix = encryptedText.slice(ENCRYPTED_PREFIX.length);
  const [ivHex, authTagHex, ciphertext] = withoutPrefix.split(':');

  const keyBuffer = Buffer.from(key, 'hex');
  const decipher = crypto.createDecipheriv(
    ALGORITHM,
    keyBuffer,
    Buffer.from(ivHex, 'hex'),
  );
  decipher.setAuthTag(Buffer.from(authTagHex, 'hex'));

  let decrypted = decipher.update(ciphertext, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
}
