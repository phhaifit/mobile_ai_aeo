export class PaymentMethodDto {
  id: string;
  brand: string;
  last4: string;
  expMonth: number;
  expYear: number;
  cardholderName: string | null;
  country: string | null;
  isDefault: boolean;
}

export class InvoiceDto {
  id: string;
  date: string;
  amount: number;
  currency: string;
  status: string;
  invoicePdf: string | null;
  hostedInvoiceUrl: string | null;
}

export class BillingDetailsResponseDto {
  paymentMethods: PaymentMethodDto[];
  billingInfo: {
    name: string | null;
    email: string | null;
  };
  invoices: InvoiceDto[];
}
