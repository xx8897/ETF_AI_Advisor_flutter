import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/portfolio_pie_chart.dart';
import '../widgets/etf_details_dialog.dart';

class ResultPage extends StatefulWidget {
  final Map<String, dynamic> report;

  const ResultPage({super.key, required this.report});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<Map<String, dynamic>>? _aggregatedHoldings;
  bool _isLoadingHoldings = true;

  @override
  void initState() {
    super.initState();
    _fetchAggregatedHoldings();
  }

  Future<void> _fetchAggregatedHoldings() async {
    try {
      final portfolio = (widget.report['report']['portfolio'] as List).cast<Map<String, dynamic>>();
      final response = await http.post(
        Uri.parse('http://localhost:8080/portfolio_holdings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'portfolio': portfolio}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _aggregatedHoldings = (data['portfolio_holdings'] as List).cast<Map<String, dynamic>>();
          _isLoadingHoldings = false;
        });
      } else {
        throw Exception('Failed to load aggregated holdings');
      }
    } catch (e) {
      setState(() {
        _isLoadingHoldings = false;
      });
      // Optionally show an error message
    }
  }

  Future<void> _showEtfDetailsDialog(String etfCode) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/etf_details/$etfCode'));
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        final etfDetails = jsonDecode(utf8.decode(response.bodyBytes));
        showDialog(
          context: context,
          builder: (context) => EtfDetailsDialog(etfDetails: etfDetails),
        );
      } else {
        throw Exception('Failed to load ETF details: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportData = widget.report['report'];
    final overallAnalysis = reportData['overall_analysis']?.toString() ?? 'No analysis provided.';
    final portfolio = (reportData['portfolio'] as List).cast<Map<String, dynamic>>();

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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('分析報告'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SelectableText('整體分析', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            SelectableText(overallAnalysis),
            const SizedBox(height: 24),
            SelectableText('投資組合建議', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PortfolioPieChart(portfolio: portfolio),
            ),
            const SizedBox(height: 16),
            ...portfolio.asMap().entries.map((entry) {
              final index = entry.key;
              final etf = entry.value;
              final etfCode = etf['etf_code']?.toString() ?? '未知代碼';
              final etfName = etf['etf_name']?.toString() ?? '未知名稱';
              final reason = etf['reason']?.toString() ?? '無';
              final allocation = etf['allocation']?.toString() ?? '?';
              final color = Colors.primaries[index % Colors.primaries.length];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: Text(
                      '$allocation%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  title: SelectableText('$etfName ($etfCode)'),
                  subtitle: SelectableText(reason),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () => _showEtfDetailsDialog(etfCode.split('.').first),
                ),
              );
            }),
            const SizedBox(height: 24),
            _buildAggregatedHoldings(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregatedHoldings(ThemeData theme) {
    return ExpansionTile(
      title: Text('投資組合總覽 (合併持股)', style: theme.textTheme.headlineSmall),
      children: [
        if (_isLoadingHoldings)
          const Center(child: CircularProgressIndicator())
        else if (_aggregatedHoldings == null || _aggregatedHoldings!.isEmpty)
          const ListTile(title: Text('無法計算合併持股。'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _aggregatedHoldings!.length,
            itemBuilder: (context, index) {
              final holding = _aggregatedHoldings![index];
              return ListTile(
                title: Text(holding['name']),
                trailing: Text(
                  '${holding['weight']}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
      ],
    );
  }
}