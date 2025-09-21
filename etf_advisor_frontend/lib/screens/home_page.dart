import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../widgets/portfolio_pie_chart.dart';
import '../providers/theme_provider.dart';

class AdvisorHomePage extends StatefulWidget {
  const AdvisorHomePage({super.key});

  @override
  State<AdvisorHomePage> createState() => _AdvisorHomePageState();
}

class _AdvisorHomePageState extends State<AdvisorHomePage> {
  final List<String> _availableThemes = [
    "高股息", "科技/半導體", "市值型", "ESG", "債券型", "低波動"
  ];
  final Set<String> _selectedThemes = {};

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _report;

  void _onThemeSelected(bool selected, String themeName) {
    setState(() {
      if (selected) {
        _selectedThemes.add(themeName);
      } else {
        _selectedThemes.remove(themeName);
      }
    });
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _report = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'themes': _selectedThemes.toList()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _report = jsonDecode(utf8.decode(response.bodyBytes));
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ETF AI Advisor',
          style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.onPrimary),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '請選擇您感興趣的投資主題:',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _availableThemes.map((theme) {
                        final isSelected = _selectedThemes.contains(theme);
                        return FilterChip(
                          label: Text(theme),
                          selected: isSelected,
                          onSelected: (selected) {
                            _onThemeSelected(selected, theme);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildResultArea(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedThemes.isEmpty || _isLoading ? null : _startAnalysis,
        label: const Text('開始分析'),
        icon: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.analytics),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildResultArea() {
    final theme = Theme.of(context);
    if (_errorMessage != null) {
      return Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '分析失敗:\n$_errorMessage',
            style: TextStyle(color: theme.colorScheme.onError),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_report != null) {
      final reportData = _report!['report'];
      final overallAnalysis = reportData['overall_analysis'] as String;
      final portfolio = (reportData['portfolio'] as List).cast<Map<String, dynamic>>();

      return Expanded(
        child: ListView(
          children: [
            Text('整體分析', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(overallAnalysis),
            const SizedBox(height: 24),
            Text('投資組合建議', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PortfolioPieChart(portfolio: portfolio),
            ),
            const SizedBox(height: 16),
            ...portfolio.map((etf) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondary,
                    child: Text(
                      '${etf['allocation']}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  title: Text('${etf['etf_name']} (${etf['etf_code']})'),
                  subtitle: Text(etf['reason']),
                ),
              );
            }),
          ],
        ),
      );
    }
    return const Expanded(
      child: Center(
        child: Text('請選擇主題並開始分析。'),
      ),
    );
  }
}
