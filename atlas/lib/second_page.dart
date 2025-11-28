import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ar_view.dart';


/// main search page
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // controller --> saving the word i searched for 
  final TextEditingController _controller = TextEditingController();

  
  List<dynamic> _results = [];

  
  bool _isLoading = false;

  
  String _error = '';

  // search function
  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
      _results = [];
    });

    // IP andress
    final url = Uri.parse('http://192.168.2.4:5000/search?q=$query');

    try {
      // get 
      final response = await http.get(url);
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        //saving results
        setState(() {
          _results = json.decode(response.body);
        });
      } else {
        // no results found
        final body = json.decode(response.body);
        setState(() {
          _error = body['message'] ?? 'No results found.';
        });
      }
    } catch (e) {
      // connection error
      setState(() {
        _error = 'Error connecting to server: $e';
      });
    } finally {
      // final result
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ui design 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forensic Atlas'),
        backgroundColor: Colors.pink[100],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // search bar 
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true,
                fillColor: Colors.pink[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.pink),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(), // enter
              textInputAction: TextInputAction.search,
            ),

            const SizedBox(height: 20),

            // conditions-->results
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red))
            else
              Expanded(
                child: _results.isEmpty
                    ? const Text('No results yet.')
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final row = _results[index] as Map<String, dynamic>;
                          return _buildResultCard(row);
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

  //function for designing cards
  Widget _buildResultCard(Map<String, dynamic> row) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // picture
            if (row['Image Path'] != null &&
                row['Image Path'].toString().trim().isNotEmpty)
              GestureDetector(
                 onTap: () {
                  final imageUrl = row['Image Path'].toString().trim();

                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ARViewer(imageUrl: imageUrl),
                   ),
                  );
                  },
             child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
               child: Image.network(
                 row['Image Path'].toString().trim(),
                 fit: BoxFit.cover,
                height: 180,
                 width: double.infinity,
               ),
              ),
            ),
            const SizedBox(height: 10),

            // text on page
            if (row.containsKey('Text on Page'))
              Text(
                row['Text on Page'].toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),

            // other results
            const SizedBox(height: 6),
            Text(
              row.entries
                  .where((e) =>
                      e.key != 'Image Path' && e.key != 'Text on Page')
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n'),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
