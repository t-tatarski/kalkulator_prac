import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
//import 'package:flutter_svg/flutter_svg.dart';
import 'summary_page.dart';

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
      home: const SplashScreen(), // splash screen
      debugShowCheckedModeBanner: false, 
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
    // delay 3 sec
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/bitmapa.png',
              width: 250,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              'Kalkulator Pracy Protetycznej',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Color(0xFF022341),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Twoje narzędzie do wyceny prac protetycznych',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Color(0xFF022341),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            // Progress Indicator
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
      final url =
          'https://raw.githubusercontent.com/t-tatarski/kalkulator_prac/refs/heads/main/proteItems.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          proteticItems =
              data.map((item) => ProteticItem.fromJson(item)).toList();
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
      int index =
          selectedItems.indexWhere((element) => element.item.id == item.id);
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
        backgroundColor: Color(0xFF063C73),
        title: const Text(
          'Kalkulator Pracy Protetycznej',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
        toolbarTextStyle: TextStyle(color: Color(0xffffffff)),
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
                                          final selectedItem =
                                              selectedItems[index];
                                          return ListTile(
                                            title: Text(selectedItem.item.name),
                                            subtitle: Text(
                                                'Cena: ${selectedItem.item.price.toStringAsFixed(2)} zł'),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.remove),
                                                  onPressed: () =>
                                                      updateQuantity(
                                                          index,
                                                          selectedItem
                                                                  .quantity -
                                                              1),
                                                ),
                                                Text(
                                                    '${selectedItem.quantity}'),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () =>
                                                      updateQuantity(
                                                          index,
                                                          selectedItem
                                                                  .quantity +
                                                              1),
                                                ),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () =>
                                                      removeItem(index),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              const Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.summarize),
                                      label: const Text('Podsumowanie'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF063C73),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: selectedItems.isEmpty
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SummaryPage(
                                                    selectedItems:
                                                        selectedItems,
                                                    total: total,
                                                  ),
                                                ),
                                              );
                                            },
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
                                'Dostępne elementy :',
                                style: TextStyle(
                                  fontSize: 16,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Cena: ${item.price.toStringAsFixed(2)} PLN'),
                                          Text('Kategoria: ${item.category}'),
                                          Divider(),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.add_circle),
                                        onPressed: () =>
                                            addItemToCalculation(item),
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
