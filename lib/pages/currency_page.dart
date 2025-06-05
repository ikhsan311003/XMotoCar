import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final TextEditingController _amountController = TextEditingController(text: '1');
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  double? _result;
  bool _isLoading = false;
  Map<String, String> currencyDescriptions = {};

  final _numberFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    fetchCurrencySymbols();
  }

  Future<void> fetchCurrencySymbols() async {
    try {
      final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = Map<String, dynamic>.from(data['rates']);
        setState(() {
          currencyDescriptions = rates.map((key, value) => MapEntry(key, key));
        });
        convertCurrency();
      } else {
        throw Exception('Gagal memuat simbol');
      }
    } catch (_) {
      setState(() {
        currencyDescriptions = {
          'USD': 'United States Dollar',
          'IDR': 'Indonesian Rupiah',
          'EUR': 'Euro',
          'JPY': 'Japanese Yen',
          'SGD': 'Singapore Dollar',
          'AUD': 'Australian Dollar',
          'GBP': 'British Pound',
        };
      });
      convertCurrency();
    }
  }

  Future<void> convertCurrency() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('https://open.er-api.com/v6/latest/$_fromCurrency');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rates = data['rates'];
      final rate = rates[_toCurrency];
      if (rate != null) {
        setState(() => _result = amount * (rate as num));
      } else {
        setState(() => _result = null);
      }
    } else {
      setState(() => _result = null);
    }

    setState(() => _isLoading = false);
  }

  String _getFlag(String code) {
    if (code.length != 2 && code.length != 3) return '';
    String countryCode = code.substring(0, 2).toUpperCase();
    return String.fromCharCodes(countryCode.codeUnits.map((c) => 0x1F1E6 + c - 65));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konversi Mata Uang', style: GoogleFonts.poppins(
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        )),
        backgroundColor: Colors.deepPurple,
      ),
      body: currencyDescriptions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputBox(),
                    const SizedBox(height: 15),
                    Center(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            final temp = _fromCurrency;
                            _fromCurrency = _toCurrency;
                            _toCurrency = temp;
                          });
                          convertCurrency();
                        },
                        icon: const Icon(Icons.swap_vert, color: Colors.green, size: 28),
                      ),
                    ),
                    const SizedBox(height: 0),
                    _buildOutputBox(),
                    const SizedBox(height: 54),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : convertCurrency,
                      icon: const Icon(Icons.currency_exchange),
                      label: const Text(
    'Konversi',
    style: TextStyle(color: Colors.white), // Ubah warna teks di sini
  ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_result != null)
                      Center(
                        child: Text(
                          '${_amountController.text} $_fromCurrency = ${_numberFormat.format(_result)} $_toCurrency',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      const Center(child: Text('Gagal melakukan konversi', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jumlah', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildCurrencyDropdown(_fromCurrency, (val) {
              setState(() => _fromCurrency = val!);
              convertCurrency();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildOutputBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dikonversi menjadi', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _result != null ? _numberFormat.format(_result) : '-',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildCurrencyDropdown(_toCurrency, (val) {
              setState(() => _toCurrency = val!);
              convertCurrency();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      icon: const Icon(Icons.arrow_drop_down),
      underline: const SizedBox(),
      onChanged: onChanged,
      items: currencyDescriptions.keys.map((code) {
        return DropdownMenuItem(
          value: code,
          child: Row(
            children: [
              Text(_getFlag(code)),
              const SizedBox(width: 6),
              Text(code, style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
