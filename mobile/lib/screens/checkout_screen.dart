import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/cart.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/parsers.dart';
import '../utils/ui.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _usernameController.text = user?.username ?? '';
    _phoneController.text = user?.phone ?? '';
    _addressController.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _loading) {
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await context.read<ApiClient>().post(
        '/orders/checkout/',
        body: {
          'username': _usernameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        },
      );
      final order = Cart.fromJson(asMap(data));
      if (!mounted) {
        return;
      }
      context.read<CartProvider>().afterCheckout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: order),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) {
        showAppSnack(context, error.message, error: true);
      }
    } catch (error) {
      if (mounted) {
        showAppSnack(context, error.toString(), error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final currency = context.tr('currency');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.tr('checkout'), style: AppText.display(size: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              context.tr('orderDetails'),
              style: AppText.display(size: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: context.tr('fullName'),
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? context.tr('requiredField')
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('phoneNumber'),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? context.tr('requiredField')
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: context.tr('deliveryAddress'),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Icon(Icons.location_on_outlined),
                ),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? context.tr('requiredField')
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('orderDetails'),
              style: AppText.display(size: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  for (final item in cart.items)
                    if (item.product != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product!.displayName}  ×${item.count}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.body(size: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatPrice(item.totalPrice, currency),
                              style: AppText.body(
                                size: 13,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  const Divider(),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        context.tr('total'),
                        style: AppText.body(
                          size: 13,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatPrice(cart.cartTotalPrice, currency),
                        style: AppText.display(size: 17),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.tr('placeOrder')),
            ),
          ],
        ),
      ),
    );
  }
}
