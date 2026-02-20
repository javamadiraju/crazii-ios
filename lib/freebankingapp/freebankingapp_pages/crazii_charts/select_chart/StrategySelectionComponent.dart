// strategy_selection_component.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class Strategy {
  final String id;
  final String name;

  Strategy({required this.id, required this.name});

  factory Strategy.fromJson(Map<String, dynamic> json) {
    return Strategy(
      id: json['id'].toString(),
      name: json['name'].toString(),
    );
  }

  @override
  String toString() => name;
}

class StrategySelectionComponent extends StatefulWidget {
  final String? selectedStrategy;
  final Function(String?) onSelectionChanged;

  const StrategySelectionComponent({
    Key? key,
    required this.selectedStrategy,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _StrategySelectionComponentState createState() =>
      _StrategySelectionComponentState();
}

class _StrategySelectionComponentState
    extends State<StrategySelectionComponent> {
  String? _selectedStrategy;
  List<Strategy> _strategyList = [];
  String? _strategyError;
  String? _lastLang;

  @override
  void initState() {
    super.initState();
    _selectedStrategy = widget.selectedStrategy;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reactively detect locale changes
    final currentLocale = Localizations.localeOf(context);
    final currentLang = currentLocale.languageCode;
    
    if (_lastLang != currentLang) {
      _lastLang = currentLang;
      fetchStrategyOptions(currentLang);
    }
  }

  Future<void> fetchStrategyOptions(String lang) async {
    // API expects 'zh' for Chinese, 'vi' for Vietnamese, 'en' for English
    final Uri url = Uri.parse('https://cgmember.com/api/strategy?lang=$lang');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _strategyList = jsonData.map((e) => Strategy.fromJson(e)).toList();
          });
        }
      } else {
        debugPrint("Strategy API error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Strategy fetch exception: $e");
    }
  }

  void _validateSelection() {
    setState(() {
      _strategyError =
          _selectedStrategy == null ? "please_select_strategy".tr : null;
    });
  }

  String _getTranslationKey(String name) {
    // Standardize the name to match keys in stringtranslation.dart
    String key = name.toLowerCase().trim().replaceAll(' ', '_');
    // Handle specific mappings if necessary
    if (key == 'blue_diamond') return 'blue_diamonds';
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 350),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "select_strategy".tr,
            style: const TextStyle(
              fontFamily: 'Exo',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          if (_strategyList.isEmpty)
            const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Column(
              children: _strategyList.map((strategy) {
                // Use the standardized key for .tr translation
                final translationKey = _getTranslationKey(strategy.name);
                
                return RadioListTile<String>(
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFFB38F3F),
                  title: Text(translationKey.tr),
                  // Using id as value to send to API
                  value: strategy.id,
                  groupValue: _selectedStrategy,
                  onChanged: (value) {
                    setState(() {
                      _selectedStrategy = value;
                      _validateSelection();
                    });
                    widget.onSelectionChanged(value);
                  },
                );
              }).toList(),
            ),
          if (_strategyError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _strategyError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
