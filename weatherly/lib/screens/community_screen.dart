import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<String> reports = [];
  final TextEditingController _controller = TextEditingController();

  void _submitReport() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        reports.insert(0, _controller.text);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Community Reports")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "What's the weather like?",
                suffixIcon: IconButton(icon: Icon(Icons.send), onPressed: _submitReport),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.message),
                  title: Text(reports[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}