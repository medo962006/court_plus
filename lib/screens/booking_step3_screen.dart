import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class BookingStep3Screen extends StatefulWidget {
  const BookingStep3Screen({super.key});

  @override
  State<BookingStep3Screen> createState() => _BookingStep3ScreenState();
}

class _BookingStep3ScreenState extends State<BookingStep3Screen> {
  static const _items = <_AddonItem>[
    _AddonItem('Racket Rental', Ph.tennis_ball, 20),
    _AddonItem('Ball Pack', Ph.dribbble_logo_fill, 15),
    _AddonItem('Water Bottle', Ph.drop_fill, 5),
    _AddonItem('Towel', Ph.t_shirt_fill, 10),
    _AddonItem('Wristband', Ph.clock_fill, 8),
  ];

  final Map<String, int> _quantities = {
    for (final item in _items) item.name: 0,
  };

  int get _subtotal {
    int total = 0;
    for (final item in _items) {
      total += (_quantities[item.name] ?? 0) * item.price;
    }
    return total;
  }

  void _updateQty(String key, int delta) {
    setState(() {
      final current = _quantities[key] ?? 0;
      _quantities[key] = (current + delta).clamp(0, 99);
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
        title: const Text('Add-ons',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _stepDot('1', true),
                _stepLine(true),
                _stepDot('2', true),
                _stepLine(true),
                _stepDot('3', true),
                _stepLine(false),
                _stepDot('4', false),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Extras & Equipment',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  ..._items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkField,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.darkSlate,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Iconify(item.icon, size: 22, color: AppColors.neonGreen),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              Text('SR ${item.price}/unit',
                                  style: const TextStyle(color: AppColors.white60, fontSize: 13)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _updateQty(item.name, -1),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: (_quantities[item.name] ?? 0) > 0
                                      ? AppColors.neonGreen
                                      : AppColors.darkBorder,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                    child: Icon(Icons.remove, size: 16, color: Colors.black)),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              child: Center(
                                child: Text('${_quantities[item.name]}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _updateQty(item.name, 1),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.neonGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                    child: Icon(Icons.add, size: 16, color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkSlate,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(color: AppColors.white60, fontSize: 15)),
                        const Spacer(),
                        Text('SR $_subtotal',
                            style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.bookingStep4,
                      arguments: {
                        ...?args,
                        'quantities': Map<String, int>.from(_quantities),
                        'addonsSubtotal': _subtotal,
                      },
                    );
                  },
                  child: const Text('Next'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(String label, bool active) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: active ? AppColors.neonGreen : AppColors.darkBorder,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.darkText : AppColors.white60,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _stepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: active ? AppColors.neonGreen : AppColors.darkBorder,
      ),
    );
  }
}

class _AddonItem {
  final String name;
  final String icon;
  final int price;
  const _AddonItem(this.name, this.icon, this.price);
}