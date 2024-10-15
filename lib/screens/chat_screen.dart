import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_gemini/google_gemini.dart';

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
    // Verificar conectividad en la inicialización
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  void fromText({required String query}) {
    if (!isConnected) return; // No hacer nada si no hay conexión

    setState(() {
      loading = true;
      textChat.add({"role": "User", "text": query});
      _textController.clear();
    });
    scrollToTheEnd();

    gemini.generateFromText(query).then((value) {
      setState(() {
        loading = false;
        textChat.add({"role": "Gemini", "text": value.text});
      });
      scrollToTheEnd();
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
        textChat.add({"role": "Gemini", "text": error.toString()});
      });
      scrollToTheEnd();
    });
  }

  void scrollToTheEnd() {
    // Mueve el Scroll al final después de cada mensaje
    if (_controller.hasClients) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat con Gemini'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // ListView que contiene los mensajes del chat
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: textChat.length,
              padding: const EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) {
                return ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    child: Text(textChat[index]["role"]!.substring(0, 1)),
                  ),
                  title: Text(textChat[index]["role"]!),
                  subtitle: Text(textChat[index]["text"]!),
                );
              },
            ),
          ),
          // Caja de texto y botón de envío
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 26),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: Theme.of(context).textTheme.bodyMedium!,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: loading
                            ? const CircularProgressIndicator()
                            : InkWell(
                                onTap: isConnected
                                    ? () {
                                        fromText(query: _textController.text);
                                      }
                                    : null,
                                child: CircleAvatar(
                                  backgroundColor: isConnected
                                      ? Colors.deepPurpleAccent
                                      : Colors.grey,
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
