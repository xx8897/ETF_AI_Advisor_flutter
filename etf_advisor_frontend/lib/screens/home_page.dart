import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import './result_page.dart';

class AdvisorHomePage extends StatefulWidget {
  const AdvisorHomePage({super.key});

  @override
  State<AdvisorHomePage> createState() => _AdvisorHomePageState();
}

class _AdvisorHomePageState extends State<AdvisorHomePage> {
  int _currentStep = 0;
  String _riskProfile = '穩健型';
  double _portfolioSize = 4;
  final Map<String, double> _themeWeights = {
    "高股息": 50.0, "科技/半導體": 50.0, "市值型": 0.0, "ESG": 0.0,
  };
  bool _useAdvancedFilters = false;
  double _betaMax = 1.2;
  double _sharpeMin = 1.5;
  bool _isLoading = false;

  Future<void> _startAnalysis() async {
    setState(() => _isLoading = true);

    final requestBody = {
      'risk_profile': _riskProfile,
      'theme_weights': _themeWeights..removeWhere((key, value) => value == 0.0),
      'filters': _useAdvancedFilters ? {'beta_max': _betaMax, 'sharpe_min': _sharpeMin} : {},
      'portfolio_size': _portfolioSize.toInt(),
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/advanced_recommendation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final report = jsonDecode(utf8.decode(response.bodyBytes));
        // Navigate to the new result page with the report data
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ResultPage(report: report),
        ));
      } else {
        throw Exception('Failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分析失敗: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make scaffold transparent
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Make appbar transparent
          elevation: 0, // Remove appbar shadow
          title: const Text('ETF AI Advisor'),
          actions: [
            IconButton(
              icon: Icon(Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildStepper(),
      ),
    );
  }

  Widget _buildStepper() {
    return SingleChildScrollView(
      child: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            _startAnalysis();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          _buildRiskProfileStep(),
          _buildThemeWeightsStep(),
          _buildAdvancedFiltersStep(),
        ],
      ),
    );
  }

  Step _buildRiskProfileStep() {
    return Step(
      title: const Text('步驟一：風險承受度'),
      content: Column(
        children: ['保守型', '穩健型', '積極型'].map((profile) {
          return RadioListTile<String>(
            title: Text(profile),
            value: profile,
            groupValue: _riskProfile,
            onChanged: (value) => setState(() => _riskProfile = value!),
          );
        }).toList(),
      ),
      isActive: _currentStep >= 0,
    );
  }

  Step _buildThemeWeightsStep() {
    return Step(
      title: const Text('步驟二：主題權重'),
      subtitle: Text('總權重: ${_themeWeights.values.reduce((a, b) => a + b).toStringAsFixed(0)}%'),
      content: Column(
        children: _themeWeights.keys.map((theme) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$theme (${_themeWeights[theme]!.toStringAsFixed(0)}%)'),
              Slider(
                value: _themeWeights[theme]!,
                min: 0,
                max: 100,
                divisions: 20,
                label: _themeWeights[theme]!.round().toString(),
                onChanged: (value) {
                  setState(() {
                    final total = _themeWeights.values.reduce((a, b) => a + b) - _themeWeights[theme]!;
                    if (total + value <= 100) {
                      _themeWeights[theme] = value;
                    } else {
                      _themeWeights[theme] = 100 - total;
                    }
                  });
                },
              ),
            ],
          );
        }).toList(),
      ),
      isActive: _currentStep >= 1,
    );
  }

  Step _buildAdvancedFiltersStep() {
    return Step(
      title: const Text('步驟三：進階設定'),
      content: Column(
        children: [
          Text('投資組合規模 (推薦 ${ _portfolioSize.toInt()} 檔)'),
          Slider(
            value: _portfolioSize,
            min: 3,
            max: 8,
            divisions: 5,
            label: _portfolioSize.toInt().toString(),
            onChanged: (value) => setState(() => _portfolioSize = value),
          ),
          SwitchListTile(
            title: const Text('啟用量化篩選'),
            value: _useAdvancedFilters,
            onChanged: (value) => setState(() => _useAdvancedFilters = value),
          ),
          if (_useAdvancedFilters) ...[
            const Divider(),
            Text('Beta 值 (篩選低於 ${_betaMax.toStringAsFixed(1)})'),
            Slider(
              value: _betaMax,
              min: 0.5,
              max: 1.5,
              divisions: 10,
              label: _betaMax.toStringAsFixed(1),
              onChanged: (value) => setState(() => _betaMax = value),
            ),
            Text('夏普值 (篩選高於 ${_sharpeMin.toStringAsFixed(1)})'),
            Slider(
              value: _sharpeMin,
              min: 0.5,
              max: 2.5,
              divisions: 20,
              label: _sharpeMin.toStringAsFixed(1),
              onChanged: (value) => setState(() => _sharpeMin = value),
            ),
          ]
        ],
      ),
      isActive: _currentStep >= 2,
    );
  }
}
