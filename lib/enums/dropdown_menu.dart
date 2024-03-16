enum PaymentModeLabel {
  momo("Mobile money"),
  cash("Cash"),
  card("Card"),
  bankTransfer("Bank transfer");

  const PaymentModeLabel(this.label);
  final String label;
}
