import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RevolutClone(),
    ));

class RevolutClone extends StatefulWidget {
  const RevolutClone({super.key});

  @override
  State<RevolutClone> createState() => _RevolutCloneState();
}

class _RevolutCloneState extends State<RevolutClone> {
  String balance = "0.00";
  List transactions = [];
  bool isLoading = false;

  // Change this to 'http://127.0.0.1:8000/test' if testing on Windows/Chrome
  // Use 'http://10.0.2.2:8000/test' for Android Emulator
  final String apiUrl = 'http://127.0.0.1:8000/test'; 

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (!mounted) return; // Safety check for async gaps

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          balance = data['mock_balance'].toString();
          transactions = data['transactions'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error connecting to Python: $e")),
      );
    }
  }

  // This is the helper function that was causing the error
  IconData getIcon(String category) {
    switch (category) {
      case 'Entertainment':
        return Icons.movie;
      case 'Income':
        return Icons.work;
      case 'Coffee':
        return Icons.coffee;
      case 'Shopping':
        return Icons.shopping_cart;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Home", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Balance Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Euro account", 
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 10),
                isLoading 
                  ? const CircularProgressIndicator() 
                  : Text("€$balance", 
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Action Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionBtn(Icons.add, "Add money", fetchData),
                _buildActionBtn(Icons.swap_horiz, "Transfer", () {}),
                _buildActionBtn(Icons.more_horiz, "More", () {}),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Transactions List Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Transactions", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          // Scrollable List
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchData,
            child: transactions.isEmpty 
              ? ListView(children: const [Center(child: Padding(padding: EdgeInsets.only(top: 20), child: Text("Pull down to refresh")))])
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isPositive = tx['amount'] > 0;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFF0F2F5),
                        child: Icon(
                          getIcon(tx['category']), // Uses the helper function
                          color: const Color(0xFF0075FF),
                        ),
                      ),
                      title: Text(tx['name'], 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(tx['date'] ?? "Recent"),
                      trailing: Text(
                        "${isPositive ? '+' : ''}${tx['amount']}",
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    );
                  },
                ),
          ),
          )
        ],
      ),
    );
  }

  // Helper to build the blue circular buttons
  Widget _buildActionBtn(IconData icon, String label, VoidCallback action) {
    return Column(
      children: [
        GestureDetector(
          onTap: action,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF0075FF),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}