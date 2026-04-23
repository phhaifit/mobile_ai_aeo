export interface InvoicePaidEmailParams {
  amountFormatted: string;
  currency: string;
  paidDate: string;
  invoicePdfUrl: string | null;
  billingPageUrl: string;
}

export function buildInvoicePaidEmailHtml(
  params: InvoicePaidEmailParams,
): string {
  const { amountFormatted, currency, paidDate, invoicePdfUrl, billingPageUrl } =
    params;

  const ctaUrl = invoicePdfUrl || billingPageUrl;
  const ctaLabel = invoicePdfUrl ? 'Download Invoice' : 'View Billing';

  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Payment Confirmed</title>
</head>
<body style="margin:0;padding:0;background-color:#f3f4f6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#f3f4f6;padding:40px 0;">
    <tr>
      <td align="center">
        <table role="presentation" width="560" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.1);">
          <!-- Header -->
          <tr>
            <td style="background-color:#ea580c;padding:28px 40px;text-align:center;">
              <span style="font-size:24px;font-weight:700;color:#ffffff;letter-spacing:-0.5px;">AEO Platform</span>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:40px;">
              <h1 style="margin:0 0 8px;font-size:22px;font-weight:700;color:#111827;">Payment Confirmed</h1>
              <p style="margin:0 0 24px;font-size:15px;color:#6b7280;line-height:1.5;">
                Your payment has been successfully processed. Here are the details:
              </p>
              <!-- Payment Details -->
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:0 0 24px;background-color:#f9fafb;border-radius:8px;">
                <tr>
                  <td style="padding:20px;">
                    <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding:4px 0;font-size:14px;color:#6b7280;">Amount</td>
                        <td style="padding:4px 0;font-size:14px;font-weight:600;color:#111827;text-align:right;">${amountFormatted} ${currency}</td>
                      </tr>
                      <tr>
                        <td style="padding:4px 0;font-size:14px;color:#6b7280;">Date</td>
                        <td style="padding:4px 0;font-size:14px;font-weight:600;color:#111827;text-align:right;">${paidDate}</td>
                      </tr>
                      <tr>
                        <td style="padding:4px 0;font-size:14px;color:#6b7280;">Status</td>
                        <td style="padding:4px 0;font-size:14px;font-weight:600;color:#16a34a;text-align:right;">Paid</td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
              <!-- CTA Button -->
              <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 auto 24px;">
                <tr>
                  <td style="border-radius:8px;background-color:#ea580c;">
                    <a href="${ctaUrl}" target="_blank" style="display:inline-block;padding:14px 32px;font-size:15px;font-weight:600;color:#ffffff;text-decoration:none;border-radius:8px;">
                      ${ctaLabel}
                    </a>
                  </td>
                </tr>
              </table>
              <p style="margin:0;font-size:13px;color:#9ca3af;line-height:1.5;">
                You can view all your invoices and manage your subscription on the <a href="${billingPageUrl}" style="color:#ea580c;text-decoration:none;">billing page</a>.
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="padding:20px 40px;background-color:#f9fafb;text-align:center;">
              <p style="margin:0;font-size:12px;color:#9ca3af;">
                &copy; ${new Date().getFullYear()} AEO Platform &mdash; <a href="https://aeo.how" style="color:#ea580c;text-decoration:none;">aeo.how</a>
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`.trim();
}
