import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reference_models.dart';

// Color constants
const Color _bgMain = Color(0xFF1E232A);
const Color _bgElevated = Color(0xFF242A33);
const Color _bgCard = Color(0xFF2A313B);
const Color _textPrimary = Color(0xFFEDF9FF);
const Color _textSecondary = Color(0xFFAEBBC8);
const Color _textMuted = Color(0xFF7F8A96);
const Color _accentPrimary = Color(0xFF6C5BFF);
const Color _accentSuccess = Color(0xFF00E5A8);

/// Reusable search bar for reference pages
class ReferenceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const ReferenceSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: _bgElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: _textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: _textMuted),
          prefixIcon: const Icon(Icons.search, color: _textMuted),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: _textMuted),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

/// Reusable table widget with horizontal scroll
class ReferenceTable extends StatelessWidget {
  final List<String> headers;
  final List<ReferenceRow> rows;

  const ReferenceTable({
    super.key,
    required this.headers,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            _bgElevated,
          ),
          dataRowColor: MaterialStateProperty.all(
            Colors.transparent,
          ),
          columns: [
            DataColumn(
              label: Text(
                'Item',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...headers.map(
              (header) => DataColumn(
                label: Text(
                  header,
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          rows: rows.map((row) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    row.label,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...headers.map((header) {
                  final value = row.columns[header] ?? '-';
                  return DataCell(
                    Text(
                      value,
                      style: const TextStyle(color: _textSecondary),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Cheat sheet section card
class CheatSheetSectionCard extends StatelessWidget {
  final CheatSheetSection section;
  final Color accentColor;

  const CheatSheetSectionCard({
    super.key,
    required this.section,
    this.accentColor = _accentPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                if (section.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    section.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: section.items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.white.withOpacity(0.05),
            ),
            itemBuilder: (context, index) {
              final item = section.items[index];
              return CheatItemTile(
                item: item,
                accentColor: accentColor,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual cheat item tile
class CheatItemTile extends StatelessWidget {
  final CheatItem item;
  final Color accentColor;

  const CheatItemTile({
    super.key,
    required this.item,
    this.accentColor = _accentPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
              CopyToClipboardButton(
                text: item.value,
                accentColor: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bgElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
              ),
            ),
            child: Text(
              item.value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: accentColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
          if (item.note != null) ...[
            const SizedBox(height: 8),
            Text(
              item.note!,
              style: const TextStyle(
                fontSize: 12,
                color: _textMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Copy to clipboard button
class CopyToClipboardButton extends StatefulWidget {
  final String text;
  final Color accentColor;

  const CopyToClipboardButton({
    super.key,
    required this.text,
    this.accentColor = _accentPrimary,
  });

  @override
  State<CopyToClipboardButton> createState() => _CopyToClipboardButtonState();
}

class _CopyToClipboardButtonState extends State<CopyToClipboardButton> {
  bool _copied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.text));
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _copied ? Icons.check : Icons.content_copy,
        size: 18,
      ),
      color: _copied ? _accentSuccess : widget.accentColor,
      onPressed: _copyToClipboard,
      tooltip: _copied ? 'Copied!' : 'Copy to clipboard',
    );
  }
}

/// Workflow step card
class WorkflowStepCard extends StatelessWidget {
  final WorkflowStep step;
  final Color accentColor;
  final int stepNumber;

  const WorkflowStepCard({
    super.key,
    required this.step,
    required this.stepNumber,
    this.accentColor = _accentPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and number
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      stepNumber.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Sub-steps
            if (step.subSteps != null && step.subSteps!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...step.subSteps!.map((subStep) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: accentColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subStep,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

/// Disclaimer footer widget
class DisclaimerFooter extends StatelessWidget {
  final String message;
  final Color accentColor;

  const DisclaimerFooter({
    super.key,
    required this.message,
    this.accentColor = const Color(0xFFFE637E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: accentColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: _textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
