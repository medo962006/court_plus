import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';

class AddPlayersScreen extends StatefulWidget {
  const AddPlayersScreen({super.key});

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  static const _suggestedPlayers = [
    ('levilleon', 'Levi Leon'),
    ('Hafezs', 'Hafez S.'),
    ('sara_m', 'Sara M.'),
    ('eaglesport', 'Eagle Sport'),
    ('khaled9', 'Khaled A.'),
    ('m_ahmed', 'Mohammed Ahmed'),
    ('nora_r', 'Nora R.'),
    ('fahad_k', 'Fahad K.'),
  ];

  List<(String, String)> get _filteredPlayers {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _suggestedPlayers;
    return _suggestedPlayers.where((p) {
      return p.$1.toLowerCase().contains(q) || p.$2.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Players',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search players…',
                hintStyle:
                    const TextStyle(color: AppColors.white60, fontSize: 14),
                prefixIcon: const Iconify(Ph.magnifying_glass,
                    color: AppColors.white60, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Iconify(Ph.x_circle_fill,
                            color: AppColors.white60, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.darkField,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.darkBorder, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.darkBorder, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.neonGreen, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Suggested players list ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredPlayers.length,
              separatorBuilder: (context, idx) =>
                  const Divider(color: AppColors.darkBorder, height: 1),
              itemBuilder: (context, index) {
                final (handle, name) = _filteredPlayers[index];
                final selected = _selectedIds.contains(handle);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // Avatar circle
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.darkField,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            color: AppColors.white60, size: 22),
                      ),
                      const SizedBox(width: 12),
                      // Name + handle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('@$handle',
                                style: const TextStyle(
                                    color: AppColors.white60, fontSize: 12)),
                          ],
                        ),
                      ),
                      // Add / Added button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedIds.remove(handle);
                            } else {
                              _selectedIds.add(handle);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.neonGreen.withAlpha(25)
                                : AppColors.darkField,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? AppColors.neonGreen
                                  : AppColors.darkBorder,
                            ),
                          ),
                          child: Text(
                            selected ? 'Added' : '+ Add',
                            style: TextStyle(
                              color: selected
                                  ? AppColors.neonGreen
                                  : AppColors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Selected players chips ──
          if (_selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              decoration: const BoxDecoration(
                color: AppColors.darkSlate,
                border: Border(
                  top: BorderSide(color: AppColors.darkBorder, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selected (${_selectedIds.length})',
                      style: const TextStyle(
                          color: AppColors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _selectedIds.map((handle) {
                      final name = _suggestedPlayers
                          .firstWhere((p) => p.$1 == handle)
                          .$2;
                      return Chip(
                        label: Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        deleteIcon: const Iconify(Ph.x,
                            color: AppColors.neonGreen, size: 14),
                        onDeleted: () {
                          setState(() => _selectedIds.remove(handle));
                        },
                        backgroundColor: AppColors.darkField,
                        side: const BorderSide(color: AppColors.darkBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // ── Save button ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.darkBg,
              border: Border(
                top: BorderSide(color: AppColors.darkBorder, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedIds.isNotEmpty ? () => Navigator.of(context).pop() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.darkText,
                  disabledBackgroundColor: AppColors.darkField,
                  disabledForegroundColor: AppColors.white60,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}