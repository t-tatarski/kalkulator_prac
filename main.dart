import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const ProteticCalculatorApp());
}

class ProteticCalculatorApp extends StatelessWidget {
  const ProteticCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Pracy Protetycznej',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Rozpoczynamy od ekranu powitalnego
      debugShowCheckedModeBanner: false, // Usuwa baner debug
    );
  }
}

// Nowa klasa Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Po 3 sekundach przechodzimy do głównego ekranu
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100], // Jasne niebieskie tło
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikonka dentystyczna/protetyczna
            Icon(
              Icons.medical_services,
              size: 100,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 30),
            const Text(
              'Kalkulator Pracy Protetycznej',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Twoje narzędzie do wyceny prac protetycznych',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            // Wskaźnik ładowania
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String errorMessage = '';
  List<ProteticItem> proteticItems = [];
  List<SelectedItem> selectedItems = [];
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Tutaj należy podać właściwy adres URL do pliku JSON
      final url = 'https://example.com/proteticItems.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          proteticItems = data
              .map((item) => ProteticItem.fromJson(item))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Błąd pobierania danych: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Błąd: $e';
        isLoading = false;
      });
    }
  }

  void addItemToCalculation(ProteticItem item) {
    setState(() {
      int index = selectedItems.indexWhere((element) => element.item.id == item.id);
      if (index != -1) {
        selectedItems[index].quantity += 1;
      } else {
        selectedItems.add(SelectedItem(item: item, quantity: 1));
      }
      updateTotal();
    });
  }

  void removeItem(int index) {
    setState(() {
      selectedItems.removeAt(index);
      updateTotal();
    });
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }
    
    setState(() {
      selectedItems[index].quantity = quantity;
      updateTotal();
    });
  }

  void updateTotal() {
    total = selectedItems.fold(
        0,
        (sum, item) => sum + (item.item.price * item.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Pracy Protetycznej'),
        elevation: 2,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : errorMessage.isNotEmpty
          ? Center(child: Text('Błąd: $errorMessage'))
          : Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wybrane elementy:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: selectedItems.isEmpty
                                ? const Center(
                                    child: Text('Brak wybranych elementów'),
                                  )
                                : ListView.builder(
                                    itemCount: selectedItems.length,
                                    itemBuilder: (context, index) {
                                      final selectedItem = selectedItems[index];
                                      return ListTile(
                                        title: Text(selectedItem.item.name),
                                        subtitle: Text(
                                            'Cena: ${selectedItem.item.price.toStringAsFixed(2)} zł'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () => updateQuantity(
                                                  index,
                                                  selectedItem.quantity - 1),
                                            ),
                                            Text('${selectedItem.quantity}'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () => updateQuantity(
                                                  index,
                                                  selectedItem.quantity + 1),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () => removeItem(index),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Suma:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${total.toStringAsFixed(2)} zł',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dostępne elementy protetyczne:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: proteticItems.length,
                              itemBuilder: (context, index) {
                                final item = proteticItems[index];
                                return ListTile(
                                  title: Text(item.name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cena: ${item.price.toStringAsFixed(2)} zł'),
                                      Text('Kategoria: ${item.category}'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: () => addItemToCalculation(item),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ProteticItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;

  ProteticItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
  });

  factory ProteticItem.fromJson(Map<String, dynamic> json) {
    return ProteticItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: json['price'].toDouble(),
    );
  }
}

class SelectedItem {
  final ProteticItem item;
  int quantity;

  SelectedItem({
    required this.item,
    required this.quantity,
  });
}
