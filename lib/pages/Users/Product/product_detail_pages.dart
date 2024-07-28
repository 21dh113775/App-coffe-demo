import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String selectedSize = 'M';
  Map<String, int> toppings = {};
  String selectedIce = 'Bình thường';
  String selectedSugar = 'Ngọt bình thường';
  int quantity = 1;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SHAKE', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {  
               
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.product['image'] ?? '',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {
                      // Implement favorite functionality
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'] ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['description'] ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: ['S', 'M', 'L'].map((size) => 
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(size),
                          selected: selectedSize == size,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedSize = size;
                            });
                          },
                        ),
                      )
                    ).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Thêm Topping', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildToppingOptions(),
                  const SizedBox(height: 16),
                  const Text('Chọn mức đá', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildIceOptions(),
                  const SizedBox(height: 16),
                  const Text('Chọn mức đường', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildSugarOptions(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildToppingOptions() {
    List<Map<String, dynamic>> toppingOptions = [
      {'name': 'Trân châu đen', 'price': 10000},
      {'name': 'Bánh flan', 'price': 10000},
      {'name': 'Kem trứng trân châu', 'price': 10000},
      {'name': 'Trân châu cam', 'price': 10000},
    ];

    return Column(
      children: toppingOptions.map((topping) =>
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text(topping['name']),
                value: toppings[topping['name']] != null,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      toppings[topping['name']] = topping['price'];
                    } else {
                      toppings.remove(topping['name']);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Text(_formatCurrency(topping['price'].toDouble())),
            const SizedBox(width: 16), // Add some padding
          ],
        )
      ).toList(),
    );
  }

  Widget _buildIceOptions() {
    return Column(
      children: ['Bình thường', 'Ít đá', 'Không đá'].map((option) =>
        RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: selectedIce,
          onChanged: (String? value) {
            setState(() {
              selectedIce = value!;
            });
          },
        )
      ).toList(),
    );
  }

  Widget _buildSugarOptions() {
    return Column(
      children: ['Ngọt bình thường', 'Ít ngọt', 'Không đường'].map((option) =>
        RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: selectedSugar,
          onChanged: (String? value) {
            setState(() {
              selectedSugar = value!;
            });
          },
        )
      ).toList(),
    );
  }

  Widget _buildBottomBar() {
    double basePrice = widget.product['price'] ?? 0.0;
    double toppingPrice = toppings.values.fold(0, (sum, price) => sum + price);
    double totalPrice = (basePrice + toppingPrice) * quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_formatCurrency(totalPrice), style: const TextStyle(fontSize: 18, color: Colors.green)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    setState(() => quantity--);
                  }
                },
              ),
              Text('$quantity', style: const TextStyle(fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() => quantity++);
                },
              ),
            ],
          ),
          ElevatedButton(
            child: const Text('Thêm vào giỏ hàng'),
            onPressed: () {
              // Implement add to cart functionality
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
