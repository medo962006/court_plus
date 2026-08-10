import 'package:flutter/material.dart';
import 'country_flag.dart';
import 'country_codes.dart';

/// A tap-to-open country code picker that shows a searchable bottom sheet.
/// Returns the selected [CountryData] or null if unchanged.
class CountryCodePicker extends StatelessWidget {
  final CountryData selected;
  final ValueChanged<CountryData> onChanged;
  final double flagWidth;
  final double iconSize;
  final Color? textColor;
  final Color? arrowColor;

  const CountryCodePicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.flagWidth = 26,
    this.iconSize = 18,
    this.textColor,
    this.arrowColor,
  });

  @override
  Widget build(BuildContext context) {
    final bright = Theme.of(context).brightness;
    final defaultText = textColor ?? (bright == Brightness.dark ? Colors.white : const Color(0xFF1B2834));
    final defaultArrow = arrowColor ?? (bright == Brightness.dark ? Colors.white60 : const Color(0xFF6B7280));

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CountryFlag(code: selected.code, width: flagWidth),
          const SizedBox(width: 4),
          Text(
            selected.dialCode,
            style: TextStyle(
              color: defaultText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down, color: defaultArrow, size: iconSize),
        ],
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final bright = Theme.of(context).brightness;
    final bgColor = bright == Brightness.dark ? const Color(0xFF1E2A36) : Colors.white;
    final textColor = bright == Brightness.dark ? Colors.white : const Color(0xFF1B2834);
    final hintColor = bright == Brightness.dark ? Colors.white38 : const Color(0xFF9CA3AF);
    final fieldColor = bright == Brightness.dark ? const Color(0xFF2A3744) : const Color(0xFFF3F4F6);

    final result = await showModalBottomSheet<CountryData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _CountryPickerSheet(
          bgColor: bgColor,
          textColor: textColor,
          hintColor: hintColor,
          fieldColor: fieldColor,
        );
      },
    );

    if (result != null && result.code != selected.code) {
      onChanged(result);
    }
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final Color bgColor, textColor, hintColor, fieldColor;
  const _CountryPickerSheet({
    required this.bgColor,
    required this.textColor,
    required this.hintColor,
    required this.fieldColor,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<CountryData> _filtered = allCountries;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = allCountries;
      } else {
        _filtered = allCountries.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.dialCode.contains(query) ||
              c.code.contains(query) ||
              c.nationality.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Country',
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: widget.hintColor, size: 22),
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.fieldColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(color: widget.textColor, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search country or code...',
                    hintStyle: TextStyle(color: widget.hintColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: widget.hintColor, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Country list
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => Divider(
                  color: widget.hintColor.withValues(alpha: 0.15),
                  height: 1,
                ),
                itemBuilder: (ctx, i) {
                  final c = _filtered[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            CountryFlag(code: c.code, width: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                c.name,
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              c.dialCode,
                              style: TextStyle(
                                color: widget.hintColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}