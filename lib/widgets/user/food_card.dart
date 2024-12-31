import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes/screens/users/order/order_payment.dart';

class FoodCard extends StatelessWidget {
  final String name;
  final int price;
  final String seller;
  final int stock;
  final int cookingTime;
  final String description;

  const FoodCard({
    required this.cookingTime,
    required this.name,
    required this.price,
    required this.seller,
    required this.stock,
    required this.description,
  });

  Future<void> saveToSharedPreferences(String name, String seller) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('food_name', name);
    await prefs.setString('food_seller', seller);
  }

  Future<Map<String, dynamic>> fetchSellerDetails(String sellerName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('seller')
        .where('nama', isEqualTo: sellerName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return {};
  }

  Future<void> showOverlay(BuildContext context) async {
    final sellerDetails = await fetchSellerDetails(seller);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Food Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: $description'),
              SizedBox(height: 8),
              Text('Cooking Time: $cookingTime mins'), // Modify if needed
              SizedBox(height: 8),
              if (sellerDetails.isNotEmpty)
                Text('Seller Address: ${sellerDetails['alamat']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Price: Rp $price',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Seller: $seller',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Stock: $stock',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            SizedBox(height: 16),
            if (stock == 0)
              Text(
                'Sold out',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: stock > 0
                  ? () async {
                      await saveToSharedPreferences(name, seller);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(),
                        ),
                      );
                    }
                  : null,
              child: Text('Buy Now'),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => showOverlay(context),
              child: Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}

