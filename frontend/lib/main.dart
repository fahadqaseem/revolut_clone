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

  // IMPORTANT: 
  // Use 'http://10.0.2.2:8000/test' for Android Emulator
  // Use 'http://127.0.0.1:8000/test' for Windows Desktop or Web
  final String apiUrl = 'http://127.0.0.1:8000/test'; 

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (!mounted) return; // Safety check

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
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Icon(Icons.help_outline, color: Colors.black),
          SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          // Header Section (Balance)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Euro account", style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 10),
                isLoading 
                  ? const CircularProgressIndicator() 
                  : Text("€$balance", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Action Buttons Section
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

          // Transactions Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          // Transactions List
          Expanded(
            child: transactions.isEmpty 
              ? const Center(child: Text("Tap 'Add money' to fetch transactions"))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isPositive = tx['amount'] > 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8EAF6),
                          child: Icon(Icons.shopping_bag, color: Color(0xFF0075FF)),
                        ),
                        title: Text(tx['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text("Payment"),
                        trailing: Text(
                          "${isPositive ? '+' : ''}${tx['amount']}",
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}