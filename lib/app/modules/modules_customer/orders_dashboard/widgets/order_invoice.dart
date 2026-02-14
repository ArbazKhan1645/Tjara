import 'package:barcode_widget/barcode_widget.dart' show Barcode;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tjara/app/models/order_model.dart';

class OrderInvoiceGenerator {
  final Order order;
  final List<dynamic> items;

  OrderInvoiceGenerator({required this.order, required this.items});

  Future<void> generateAndPrint() async {
    final pdf = pw.Document();
    final meta = order.meta ?? <String, dynamic>{};

    // Order info
    final orderNumber = meta['order_id']?.toString() ?? order.id ?? '--';
    final orderDate =
        order.createdAt?.toLocal().toString().split(' ')[0] ?? '--';
    final trackingNumber = meta['tracking_number']?.toString() ?? '';

    // Shop info
    final shopName = order.shop?.shop?.name ?? 'Shop';

    // Buyer info
    final customBuyer = order.customBuyerDetails ?? <String, dynamic>{};
    final customAddress = order.customAddressDetails ?? <String, dynamic>{};
    final buyer = order.buyer;
    final user = buyer?.user;

    final buyerFirstName = customBuyer['first_name']?.toString() ??
        meta['custom_buyer_first_name']?.toString() ??
        user?.firstName ?? '';
    final buyerLastName = customBuyer['last_name']?.toString() ??
        meta['custom_buyer_last_name']?.toString() ??
        user?.lastName ?? '';
    final buyerName = '$buyerFirstName $buyerLastName'.trim();
    final buyerEmail = customBuyer['email']?.toString() ??
        meta['custom_buyer_email']?.toString() ??
        user?.email ?? '';
    final buyerPhone = customBuyer['phone']?.toString() ??
        meta['custom_buyer_phone']?.toString() ??
        user?.phone ?? '';
    final buyerAddress = customAddress['formatted_address']?.toString() ??
        customAddress['street_address']?.toString() ??
        meta['custom_buyer_formatted_address']?.toString() ??
        meta['custom_buyer_street_address']?.toString() ??
        '';
    final buyerCity = customAddress['city']?.toString() ??
        meta['custom_buyer_city']?.toString() ??
        '';
    final buyerState = customAddress['state']?.toString() ??
        meta['custom_buyer_state']?.toString() ??
        '';
    final buyerCountry = customAddress['country']?.toString() ??
        meta['custom_buyer_country']?.toString() ??
        '';
    final buyerPostal = customAddress['postal_code']?.toString() ??
        meta['custom_buyer_postal_code']?.toString() ??
        '';

    // Build full address
    final addressParts = <String>[];
    if (buyerAddress.isNotEmpty && buyerAddress != 'null') {
      addressParts.add(buyerAddress);
    }
    if (buyerCity.isNotEmpty && buyerCity != 'null') {
      addressParts.add(buyerCity);
    }
    if (buyerState.isNotEmpty && buyerState != 'null') {
      addressParts.add(buyerState);
    }
    if (buyerCountry.isNotEmpty && buyerCountry != 'null') {
      addressParts.add(buyerCountry);
    }
    if (buyerPostal.isNotEmpty && buyerPostal != 'null') {
      addressParts.add(buyerPostal);
    }
    final fullAddress = addressParts.join(', ');

    // Amounts
    final double subtotal =
        double.tryParse(meta['initial_total']?.toString() ?? '0') ?? 0.0;
    final double shippingFee =
        double.tryParse(meta['shipping_total']?.toString() ?? '0') ?? 0.0;
    final double discountTotal =
        double.tryParse(meta['discount_total']?.toString() ?? '0') ?? 0.0;
    final double couponDiscount =
        double.tryParse(meta['coupon_discount']?.toString() ?? '0') ?? 0.0;
    final double resellerDiscount = double.tryParse(
            meta['reseller_commission_amount']?.toString() ?? '0') ??
        0.0;
    final double finalTotal = order.orderTotal ?? 0.0;

    double totalDiscounts = 0;
    if (resellerDiscount > 0) totalDiscounts += resellerDiscount;
    if (couponDiscount > 0) totalDiscounts += couponDiscount;
    if (discountTotal > 0 && totalDiscounts == 0) {
      totalDiscounts = discountTotal;
    }

    const accentColor = PdfColor.fromInt(0xFF1E88E5);
    const lightBg = PdfColor.fromInt(0xFFF5F7FA);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Order #$orderNumber',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date: $orderDate',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Status: ${order.status ?? '--'}',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(color: accentColor, thickness: 2),
              pw.SizedBox(height: 16),

              // Shop & Buyer Details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Shop Details
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: lightBg,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Shop Details',
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(shopName,
                              style: const pw.TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Buyer Details
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: lightBg,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Buyer Details',
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          if (buyerName.isNotEmpty)
                            pw.Text(buyerName,
                                style: const pw.TextStyle(fontSize: 11)),
                          if (buyerPhone.isNotEmpty && buyerPhone != 'null')
                            pw.Text(buyerPhone,
                                style: const pw.TextStyle(fontSize: 11)),
                          if (buyerEmail.isNotEmpty && buyerEmail != 'null')
                            pw.Text(buyerEmail,
                                style: const pw.TextStyle(fontSize: 11)),
                          if (fullAddress.isNotEmpty)
                            pw.Text(fullAddress,
                                style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Tracking barcode
              if (trackingNumber.isNotEmpty && trackingNumber != 'null') ...[
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text(
                        'Tracking #: $trackingNumber',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Spacer(),
                      pw.BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: trackingNumber,
                        width: 160,
                        height: 40,
                        drawText: false,
                      ),
                    ],
                  ),
                ),
              ],

              pw.SizedBox(height: 20),

              // Items Table
              pw.Text(
                'Order Items',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildItemsTable(items, accentColor),

              pw.SizedBox(height: 20),

              // Totals
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 250,
                  child: pw.Column(
                    children: [
                      _totalRow('Subtotal',
                          '\$${subtotal.toStringAsFixed(2)}'),
                      if (shippingFee > 0)
                        _totalRow('Shipping',
                            '\$${shippingFee.toStringAsFixed(2)}'),
                      if (shippingFee == 0)
                        _totalRow('Shipping', 'Free'),
                      if (totalDiscounts > 0)
                        _totalRow('Discounts',
                            '-\$${totalDiscounts.toStringAsFixed(2)}',
                            color: PdfColors.green700),
                      pw.Divider(color: PdfColors.grey400),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '\$${finalTotal.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'Thank you for your order!',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_$orderNumber',
    );
  }

  pw.Widget _buildItemsTable(List<dynamic> items, PdfColor accentColor) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(color: accentColor),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      headers: ['Product', 'Qty', 'Price', 'Total'],
      data: items.map((item) {
        final name = item.product?.name ?? 'Unknown';
        final qty = item.quantity ?? 1;
        final price = (item.price ?? 0).toDouble();
        final total = price * qty;
        return [
          name,
          '$qty',
          '\$${price.toStringAsFixed(2)}',
          '\$${total.toStringAsFixed(2)}',
        ];
      }).toList(),
    );
  }

  pw.Widget _totalRow(String label, String value, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
