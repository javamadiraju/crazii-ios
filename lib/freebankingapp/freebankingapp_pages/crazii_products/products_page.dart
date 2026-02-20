import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/Product.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_payments/productpurchase.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_payments/crypto_payment_webview.dart';

class ProductsPage extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: FutureBuilder<List<Product>>(
        future: apiService.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${'error'.tr}: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('no_products'.tr));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ProductCard(
                  id: product.id,
                  title: product.name,
                  description: product.description,
                  imageUrl: product.image,
                  credits: product.credits,
                  price: product.price,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String credits;
  final String price;

  const ProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.credits,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = imageUrl.startsWith("http")
        ? imageUrl
        : "https://cgmember.com$imageUrl";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // 🔥 Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              fullImageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 16),

          // Price
          Text(
            "\$ $price",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: "Exo",
              color: Color(0xFF0D1436),
            ),
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: "Exo",
            ),
          ),

          const SizedBox(height: 6),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Exo",
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 20),

          // Purchase Button
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC76E00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () => _showPurchaseDialog(context),
              child:   Text(
                'purchase_now'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Exo",
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // 🔥 PAYMENT POPUP DIALOG (CARD + CRYPTO)
  // -------------------------------------------------------
  void _showPurchaseDialog(BuildContext context) async {
    ApiService apiService = ApiService();
    User user = await apiService.getUserData();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "payment".tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Exo",
                  ),
                ),

                const SizedBox(height: 6),
                Container(height: 1, color: Colors.grey),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    "choose_payment_method".tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Exo",
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // CARD PAYMENT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB38F3F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PayProductPurchase(
                            fullname:
                                "${user.data.firstName} ${user.data.lastName ?? ''}",
                            product: description,
                            amount: price,
                            productId: id,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "pay_with_card".tr,
                      style: const TextStyle(
                        fontFamily: "Exo",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CRYPTO PAYMENT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DCC70),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _createCryptoOrder(context, price, id);
                    },
                    child: Text(
                      "pay_with_crypto".tr,
                      style: const TextStyle(
                        fontFamily: "Exo",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------
  // 🔥 CRYPTO ORDER CREATION
  // -------------------------------------------------------
  void _createCryptoOrder(
      BuildContext context, String amount, String productId) async {
    try {
      ApiService api = ApiService();
      double value = double.tryParse(amount) ?? 0;

      final result = await api.createCryptoOrder(
        amount: value,
        currency: "USD",
        description: "Product ID: $productId",
      );

      if (!context.mounted) return;

      if (result["success"] == true) {
        String url = result["data"]["invoice_url"];
        String invoiceId = result["data"]["invoice_id"];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CryptoPaymentWebView(url: url, invoiceId: invoiceId),
          ),
        );
      } else {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"])),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error creating crypto order")),
      );
    }
  }
}
