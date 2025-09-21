import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class EtfDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> etfDetails;

  const EtfDetailsDialog({super.key, required this.etfDetails});

  @override
  State<EtfDetailsDialog> createState() => _EtfDetailsDialogState();
}

class _EtfDetailsDialogState extends State<EtfDetailsDialog> {
  int touchedIndex = -1;

  // Final, robust parser for holdings string
  List<Map<String, dynamic>> _parseHoldings(String? holdingsStr) {
    if (holdingsStr == null || holdingsStr.isEmpty) return [];
    if (!holdingsStr.contains('%')) return [{'name': holdingsStr, 'weight': 100.0}];
    
    final items = <Map<String, dynamic>>[];
    final regex = RegExp(r'([\s\S]+?)\((\d+\.\d+)%\)');
    final matches = regex.allMatches(holdingsStr);
    
    for (final match in matches) {
      try {
        items.add({
          'name': match.group(1)!.trim(),
          'weight': double.parse(match.group(2)!)
        });
      } catch (e) {/* ignore */}
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // --- Holdings Parsing & "Other" Calculation ---
    final holdings = _parseHoldings(widget.etfDetails['主要持股/持債']);
    final isBondEtf = holdings.length == 1 && holdings.first['weight'] == 100.0;

    var displayHoldings = List<Map<String, dynamic>>.from(holdings);

    if (!isBondEtf) {
      final topHoldingsSum = displayHoldings.fold<double>(0, (sum, item) => sum + (item['weight'] ?? 0.0));
      // Use a small tolerance for floating point inaccuracies
      if (topHoldingsSum < 99.9) { 
        final otherWeight = 100.0 - topHoldingsSum;
        displayHoldings.add({'name': '其他', 'weight': otherWeight});
      }
    }

    return AlertDialog(
      title: Text('${widget.etfDetails['ETF名稱']} (${widget.etfDetails['ETF代號']})'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (displayHoldings.isNotEmpty)
                _buildChartSection('主要持股/持債分佈', displayHoldings, touchedIndex, (index) {
                  setState(() => touchedIndex = index);
                }),
              
              Text('關鍵指標', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildDetails(context),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('關閉'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildChartSection(String title, List<Map<String, dynamic>> data, int touchedIndex, Function(int) onTouch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  int newIndex = -1;
                  if (event.isInterestedForInteractions && pieTouchResponse?.touchedSection != null) {
                    newIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                  }
                  onTouch(newIndex);
                },
              ),
              sections: data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isTouched = index == touchedIndex;
                return PieChartSectionData(
                  color: Colors.primaries[index % Colors.primaries.length],
                  value: item['weight'],
                  title: '${item['name']}\n${item['weight']?.toStringAsFixed(2)}%',
                  radius: isTouched ? 90.0 : 80.0,
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 14.0 : 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    const displayKeys = [
      'ETF代號', 'ETF名稱', '類別', '基金規模(億)', 'Tech_Exposure (%)',
      '年化配息率(%)', '配息頻率', '近一年報酬率(%)', 'Beta值', '夏普值'
    ];

    final details = <Widget>[];
    for (final key in displayKeys) {
      if (widget.etfDetails.containsKey(key)) {
        final value = widget.etfDetails[key];
        if (value != null && value.toString().isNotEmpty) {
          details.add(
            SizedBox(
              width: 250,
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(key, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(value.toString(), style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: details,
    );
  }
}
