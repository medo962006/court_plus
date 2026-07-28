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
  final Map<String, int> _quantities = {
    'Racket Rental': 0,
    'Ball Pack': 0,
    'Water Bottle': 0,
  };

  static const _prices = {
    'Racket Rental': 20,
    'Ball Pack': 15,
    'Water Bottle': 5,
  };

  static const _icons = {
    'Racket Rental': Ph.tennis_ball,
    'Ball Pack': Ph.dribbble_logo_fill,
    'Water Bottle': Ph.drop_fill,
  };

  int get _subtotal {
    int total = 0;
    _quantities.forEach((key, value) => total += value * (_prices[key] ?? 0));
    return total;
  }

  void _updateQty(String key, int delta) {
    setState(() {
      _quantities[key] = (_quantities[key] ?? 0) + delta;
      if (_quantities[key]! < 0) _quantities[key] = 0;
    });
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
        title: const Text('Add-ons',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Extras & Equipment',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  ..._quantities.keys.map((key) => Container(
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
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.darkSlate,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Iconify(_icons[key]!, size: 22, color: AppColors.neonGreen),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(key, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              Text('SR ${_prices[key]}', style: const TextStyle(color: AppColors.white60, fontSize: 13)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _updateQty(key, -1),
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: _quantities[key]! > 0 ? AppColors.neonGreen : AppColors.darkBorder,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(child: Icon(Icons.remove, size: 16, color: Colors.black)),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              child: Center(
                                child: Text('${_quantities[key]}',
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _updateQty(key, 1),
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.neonGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(child: Icon(Icons.add, size: 16, color: Colors.black)),
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
                  onPressed: () => Navigator.of(context).pushNamed(Routes.bookingStep4),
                  child: const Text('Next'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}