import 'package:flutter/material.dart';


class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? selectedOrderStatus; // Holds the selected order status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {},
            ),
            const Text('Dashboard > Website', style: TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.fullscreen),
            const SizedBox(width: 10),
            const Icon(Icons.notifications),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildSearchAndFilters(),
              const SizedBox(height: 20),
              _buildTableHeader(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 10),
          _buildOrderStatusFilter(),
          _buildDropdown('Filter by : Payment Method'),
          _buildDropdown('Filter by : Payment Status'),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'By : Order ID...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.grey[200],
        filled: true,
      ),
    );
  }

  Widget _buildOrderStatusFilter() {
    return GestureDetector(
      onTap: () {
        showAnimatedOrderStatusDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedOrderStatus ?? 'Filter by : Order Status'),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void showAnimatedOrderStatusDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox
            .shrink(); // Placeholder, real content is in transitionBuilder
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Filter by : Order Status'),
              content: _buildOrderStatusDialogContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusDialogContent() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption('Pending', setState),
            _buildRadioOption('Processing', setState),
            _buildRadioOption('Shipping', setState),
            _buildRadioOption('Completed', setState),
            _buildRadioOption('Cancelled', setState),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodDialogContent() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption('Filter by Payment Method', setState),
            _buildRadioOption('Cash on delivery', setState),
            _buildRadioOption('Stripe', setState),
            _buildRadioOption('Paypal', setState),
          ],
        );
      },
    );
  }

  Widget _buildRadioOption(String value, Function setState) {
    return RadioListTile(
      title: Text(value),
      value: value,
      groupValue: selectedOrderStatus,
      onChanged: (newValue) {
        setState(() {
          selectedOrderStatus = newValue.toString();
        });
      },
    );
  }

  Widget _buildDropdown(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        hint: Text(hint),
        items: const [],
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('# Order ID', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 25),
            Text('Buyer', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 25),
            Text('Shop', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 25),
            Text('Order Total', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 25),
            Text('Bonus\nAmount',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 25),
            Text('Payment\nMethod',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 25),
            Text('Payment\nStatus',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 25),
            Text('Order\nDate', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 25),
            Text('Order\nStatus',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 25),
            Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Tjara Club'),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OrdersScreen(),
  ));
}