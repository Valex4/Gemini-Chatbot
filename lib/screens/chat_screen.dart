// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:google_gemini/google_gemini.dart';

// const apiKey = "AIzaSyCTREetNKiEu4cs1Wp8f8So5t6QJrfTJIs";

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   bool loading = false;
//   bool isConnected = true;
//   List<Map<String, String>> textChat = [];

//   final TextEditingController _textController = TextEditingController();
//   final ScrollController _controller = ScrollController();

//   final gemini = GoogleGemini(apiKey: apiKey);

//   @override
//   void initState() {
//     super.initState();
//     _checkConnectivity();
//   }

//   void _checkConnectivity() async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     setState(() {
//       isConnected = connectivityResult != ConnectivityResult.none;
//     });
//   }

//   void fromText({required String query}) {
//     if (!isConnected) return;

//     setState(() {
//       loading = true;
//       textChat.add({"role": "User", "text": query});
//       _textController.clear();
//     });
//     scrollToTheEnd();

//     gemini.generateFromText(query).then((value) {
//       setState(() {
//         loading = false;
//         textChat.add({"role": "Gemini", "text": value.text});
//       });
//       scrollToTheEnd();
//     }).onError((error, stackTrace) {
//       setState(() {
//         loading = false;
//         textChat.add({"role": "Gemini", "text": error.toString()});
//       });
//       scrollToTheEnd();
//     });
//   }

//   void scrollToTheEnd() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_controller.hasClients) {
//         _controller.animateTo(
//           _controller.position.maxScrollExtent,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat con Gemini'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 controller: _controller,
//                 itemCount: textChat.length,
//                 padding: const EdgeInsets.all(8),
//                 itemBuilder: (context, index) {
//                   return Card(
//                     elevation: 1,
//                     margin: EdgeInsets.symmetric(vertical: 4),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         child: Text(textChat[index]["role"]!.substring(0, 1)),
//                         backgroundColor: textChat[index]["role"] == "User" ? Colors.blue : Colors.green,
//                       ),
//                       title: Text(textChat[index]["role"]!, style: TextStyle(fontWeight: FontWeight.bold)),
//                       subtitle: Text(textChat[index]["text"]!),
//                       contentPadding: EdgeInsets.all(8),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _textController,
//                       decoration: InputDecoration(
//                         hintText: 'Escribe un mensaje...',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   IconButton(
//                     icon: Icon(Icons.send),
//                     onPressed: isConnected && !loading
//                         ? () => fromText(query: _textController.text)
//                         : null,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_gemini/google_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const apiKey = "AIzaSyCTREetNKiEu4cs1Wp8f8So5t6QJrfTJIs";

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool loading = false;
  bool isConnected = true;
  List<Map<String, String>> textChat = [];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _controller = ScrollController();

  final gemini = GoogleGemini(apiKey: apiKey);

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadChats();
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  void _loadChats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? chatHistory = prefs.getString('chat_history');
    if (chatHistory != null) {
      setState(() {
        textChat = List<Map<String, String>>.from(
          json.decode(chatHistory).map((item) => Map<String, String>.from(item))
        );
      });
    }
  }

  void _saveChats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', json.encode(textChat));
  }

  void fromText({required String query}) {
    if (!isConnected) return;

    setState(() {
      loading = true;
      textChat.add({"role": "User", "text": query});
      _textController.clear();
    });
    _saveChats();
    scrollToTheEnd();

    gemini.generateFromText(query).then((value) {
      setState(() {
        loading = false;
        textChat.add({"role": "Gemini", "text": value.text});
      });
      _saveChats();
      scrollToTheEnd();
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
        textChat.add({"role": "Gemini", "text": error.toString()});
      });
      _saveChats();
      scrollToTheEnd();
    });
  }

  void scrollToTheEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat con Gemini'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              setState(() {
                textChat.clear();
              });
              _saveChats();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _controller,
                itemCount: textChat.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(textChat[index]["role"]!.substring(0, 1)),
                        backgroundColor: textChat[index]["role"] == "User" ? Colors.blue : Colors.green,
                      ),
                      title: Text(textChat[index]["role"]!, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(textChat[index]["text"]!),
                      contentPadding: EdgeInsets.all(8),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: isConnected && !loading
                        ? () => fromText(query: _textController.text)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}