import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ScannerPage extends StatefulWidget {
  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final String scriptUrl = 'https://script.google.com/macros/s/AKfycbz6yIsPWSA40YpcOdieVVqfV60zIXp8rj0zSb1LUej2rzUAiPrPvu1MC7lqmMJyB7oU/exec';
  bool _isProcessing = false;
  String? _lastScanned;
  final Dio _dio = Dio();

  bool _isJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleScan(String data) async {
    print("Scanned data raw string: $data");
    if (_isProcessing || data == _lastScanned) return;

    setState(() {
      _isProcessing = true;
      _lastScanned = data;
    });

    if (!_isJson(data)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Not valid JSON")),
      );
      setState(() => _isProcessing = false);
      return;
    }

    final parsedData = jsonDecode(data);
    print("Parsed JSON data: $parsedData");

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Submit this data?"),
        content: SingleChildScrollView(
          child: Text(JsonEncoder.withIndent("  ").convert(parsedData)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Submit")),
        ],
      ),
    );

    if (confirmed != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Submission cancelled.")),
      );
      setState(() => _isProcessing = false);
      return;
    }

    // Check internet
    final connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ No internet connection.")),
      );
      setState(() => _isProcessing = false);
      return;
    }

    // Submit to Google Script
    try {
      final response = await _dio.post(
        scriptUrl,
        data: _lastScanned,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'Accept': '*/*'},
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400, // Allow 302
        ),
      );


      if (response.statusCode == 302 && response.headers.value('location') != null) {
        final redirectedUrl = response.headers.value('location')!;
        final redirectResponse = await _dio.get(redirectedUrl);

        if (redirectResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Final success: Submitted successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ Redirect failed: ${redirectResponse.statusCode}")),
          );
        }
      } else if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Submitted successfully: ${response.data}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error submitting data.")),
      );
    }


    setState(() => _isProcessing = false);
    await Future.delayed(Duration(seconds: 5));
    setState(() => _lastScanned = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final code = capture.barcodes.first.rawValue;
              if (code != null) _handleScan(code);
            },
          ),
          if (_lastScanned != null && !_isProcessing)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Text(
                    "Last scanned: $_lastScanned",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
