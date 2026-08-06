import 'package:flutter/material.dart';

class CheckoutSectionCard extends StatelessWidget {
  const CheckoutSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class CheckoutTextField extends StatelessWidget {
  const CheckoutTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
  }
}

class CheckoutNoticeBanner extends StatelessWidget {
  const CheckoutNoticeBanner({
    super.key,
    required this.message,
    required this.color,
    required this.textColor,
    required this.borderColor,
  });

  final String message;
  final Color color;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    required this.formatter,
    this.bold = false,
  });

  final String label;
  final num value;
  final String Function(num) formatter;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      fontSize: bold ? 18 : 15,
      color: const Color(0xFF0F172A),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatter(value), style: style),
        ],
      ),
    );
  }
}

class CheckoutCartItemTile extends StatelessWidget {
  const CheckoutCartItemTile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.quantity,
    required this.priceText,
  });

  final String? imageUrl;
  final String name;
  final int quantity;
  final String priceText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl ?? '',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFFE2E8F0),
                alignment: Alignment.center,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty $quantity',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutCartItemList extends StatelessWidget {
  const CheckoutCartItemList({
    super.key,
    required this.isEmpty,
    required this.emptyMessage,
    required this.children,
  });

  final bool isEmpty;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(emptyMessage),
      );
    }

    return Column(children: children);
  }
}

class CheckoutShippingForm extends StatelessWidget {
  const CheckoutShippingForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.address1Controller,
    required this.address2Controller,
    required this.cityController,
    required this.stateController,
    required this.pincodeController,
    required this.countryController,
    required this.onPayPressed,
    required this.formatTotal,
    required this.total,
    required this.isProcessing,
    required this.isPreparingOrder,
    required this.isOrderReady,
    required this.requiredValidator,
    required this.emailValidator,
    required this.phoneValidator,
    required this.pincodeValidator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController address1Controller;
  final TextEditingController address2Controller;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController pincodeController;
  final TextEditingController countryController;
  final VoidCallback onPayPressed;
  final String Function(num) formatTotal;
  final num total;
  final bool isProcessing;
  final bool isPreparingOrder;
  final bool isOrderReady;
  final String? Function(String?, String) requiredValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) pincodeValidator;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 680;
              if (wide) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CheckoutTextField(
                            controller: fullNameController,
                            label: 'Full name *',
                            hintText: 'Aarav Sharma',
                            validator: (value) => requiredValidator(value, 'Full name'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CheckoutTextField(
                            controller: emailController,
                            label: 'Email *',
                            hintText: 'aarav@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: emailValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CheckoutTextField(
                            controller: phoneController,
                            label: 'Phone *',
                            hintText: '+91 98765 43210',
                            keyboardType: TextInputType.phone,
                            validator: phoneValidator,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CheckoutTextField(
                            controller: pincodeController,
                            label: 'PIN code *',
                            hintText: '560001',
                            keyboardType: TextInputType.number,
                            validator: pincodeValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CheckoutTextField(
                            controller: cityController,
                            label: 'City *',
                            hintText: 'Bengaluru',
                            validator: (value) => requiredValidator(value, 'City'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CheckoutTextField(
                            controller: stateController,
                            label: 'State *',
                            hintText: 'Karnataka',
                            validator: (value) => requiredValidator(value, 'State'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CheckoutTextField(
                      controller: address1Controller,
                      label: 'Address line 1 *',
                      hintText: 'House number, street name',
                      validator: (value) => requiredValidator(value, 'Address line 1'),
                    ),
                    const SizedBox(height: 14),
                    CheckoutTextField(
                      controller: address2Controller,
                      label: 'Address line 2',
                      hintText: 'Apartment, landmark, etc.',
                    ),
                    const SizedBox(height: 14),
                    CheckoutTextField(
                      controller: countryController,
                      label: 'Country *',
                      hintText: 'India',
                      validator: (value) => requiredValidator(value, 'Country'),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  CheckoutTextField(
                    controller: fullNameController,
                    label: 'Full name *',
                    hintText: 'Aarav Sharma',
                    validator: (value) => requiredValidator(value, 'Full name'),
                  ),
                  const SizedBox(height: 14),
                  CheckoutTextField(
                    controller: emailController,
                    label: 'Email *',
                    hintText: 'aarav@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 14),
                  CheckoutTextField(
                    controller: phoneController,
                    label: 'Phone *',
                    hintText: '+91 98765 43210',
                    keyboardType: TextInputType.phone,
                    validator: phoneValidator,
                  ),
                  const SizedBox(height: 14),
                  CheckoutTextField(
                    controller: address1Controller,
                    label: 'Address line 1 *',
                    hintText: 'House number, street name',
                    validator: (value) => requiredValidator(value, 'Address line 1'),
                  ),
                  const SizedBox(height: 14),
                  CheckoutTextField(
                    controller: address2Controller,
                    label: 'Address line 2',
                    hintText: 'Apartment, landmark, etc.',
                  ),
                  const SizedBox(height: 14),
                  CheckoutTextField(
                    controller: cityController,
                    label: 'City *',
                    hintText: 'Bengaluru',
                    validator: (value) => requiredValidator(value, 'City'),
                  ),
                  const SizedBox(height: 14),
                  CheckoutTextField(
                    controller: stateController,
                    label: 'State *',
                    hintText: 'Karnataka',
                    validator: (value) => requiredValidator(value, 'State'),
                  ),
                  const SizedBox(height: 14),
                  CheckoutTextField(
                    controller: pincodeController,
                    label: 'PIN code *',
                    hintText: '560001',
                    keyboardType: TextInputType.number,
                    validator: pincodeValidator,
                  ),
                  const SizedBox(height: 14),
                  CheckoutTextField(
                    controller: countryController,
                    label: 'Country *',
                    hintText: 'India',
                    validator: (value) => requiredValidator(value, 'Country'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Text(
              'Only the Razorpay Key ID is used on the client. The secret key stays on your backend.',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isProcessing || isPreparingOrder || !isOrderReady) ? null : onPayPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : isPreparingOrder
                      ? const Text(
                          'Preparing payment...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        )
                      : !isOrderReady
                          ? const Text(
                              'Fill details to continue',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            )
                          : Text(
                              'Pay now - ${formatTotal(total)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
