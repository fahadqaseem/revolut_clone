import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the red "Debug" banner
      home: RevolutClone(),
    ));

class RevolutClone extends StatefulWidget {
  const RevolutClone({super.key});

  @override
  State<RevolutClone> createState() => _RevolutCloneState();
}

class _RevolutCloneState extends State<RevolutClone> {
  String balance = "0.00";
  bool isLoading = false;

Future<void> fetchBalance() async {
  setState(() => isLoading = true);
  try {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/test'));
    
    // THE FIX: Check if the user is still on this screen before updating UI
    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        balance = data['mock_balance'].toString();
        isLoading = false;
      });
    }
  } catch (e) {
    // THE FIX: Check mounted again here
    if (!mounted) return;
    
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Backend not found! Check PyCharm.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Light grey background
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [const Icon(Icons.bar_chart, color: Colors.black), const SizedBox(width: 15)],
      ),
      body: Column(
        children: [
          // Balance Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 40),
            width: double.infinity,
            child: Column(
              children: [
                const Text("Euro account", style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 10),
                isLoading 
                  ? const CircularProgressIndicator() 
                  : Text("€$balance", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Action Buttons Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.add, "Add money", fetchBalance),
                _buildActionButton(Icons.compare_arrows, "Transfer", () {}),
                _buildActionButton(Icons.more_horiz, "Details", () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF0075FF), // Revolut Blue
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}