import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:amork/data/models/food_model.dart';
import 'package:amork/core/app_config.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodModel> _results = [];
  bool _isLoading = false;

  // This calls your C# api/foods?search=...
  Future<void> _searchAPI(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/foods?search=$query'));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        setState(() {
          _results = data.map((json) => FoodModel.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          onChanged: _searchAPI,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search dishes...",
            border: InputBorder.none,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _results.isEmpty && _searchController.text.isNotEmpty
              ? const Center(child: Text("No results found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final food = _results[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(food.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("\$${food.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.orange)),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(food: food))),
                      ),
                    );
                  },
                ),
    );
  }
}