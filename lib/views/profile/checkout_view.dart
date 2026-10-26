import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/viewmodels/profile/subscription_viewmodel.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class CheckoutView extends StatelessWidget {
  final String planName;
  final String planPrice;
  final bool isYearly;

  const CheckoutView({
    super.key,
    required this.planName,
    required this.planPrice,
    required this.isYearly,
  });

  void _handlePayment(BuildContext context, SubscriptionViewModel vm) {
    vm.processPayment();
  }

  @override
  Widget build(BuildContext context) {
    final subViewModel = Provider.of<SubscriptionViewModel>(context);
    final bool isPro = planName.toLowerCase() == 'pro';
    final String billingCyclesText = isYearly ? '12 months' : '1 month';

    if (subViewModel.paymentSuccess) {
      return _buildSuccessScreen(context, subViewModel);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(context.hMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 4.0,
                            ),
                            child: SvgPicture.asset(
                              AppIcons.assetBackArrow,
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: context.sp(20),
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray800,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),

                    const Divider(height: 1, color: AppColors.black),
                    SizedBox(height: context.scaleH(20)),
                    // 1. Blue Gradient Plan Card
                    _buildGradientHeaderCard(context, isPro),
                    SizedBox(height: context.scaleH(20)),

                    // 2. Order Summary
                    _buildOrderSummaryCard(context, billingCyclesText),
                    SizedBox(height: context.scaleH(20)),

                    // 3. Payment Method
                    _buildPaymentMethodSelector(context, subViewModel),
                    SizedBox(height: context.scaleH(20)),

                    // 4. Card Details Form (Conditional)
                    if (subViewModel.selectedPaymentMethod == 'card') ...[
                      _buildCardDetailsForm(context, subViewModel),
                      SizedBox(height: context.scaleH(24)),
                    ],

                    // 5. Footer Trust Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFooterIndicator(
                          AppIcons.shield,
                          'Secure Payment',
                        ),
                        _buildFooterIndicator(
                          AppIcons.restartSvg,
                          'Cancel Anytime',
                        ),
                        _buildFooterIndicator(
                          AppIcons.supportSvg,
                          '24/7 Support',
                        ),
                      ],
                    ),
                    SizedBox(height: context.scaleH(20)),

                    // 6. Action Button (Pay / Processing)
                    CustomButton(
                      text: subViewModel.isProcessing
                          ? 'Processing...'
                          : 'Pay $planPrice',
                      onPressed: () => _handlePayment(context, subViewModel),
                      isLoading: subViewModel.isProcessing,
                      backgroundColor: isPro
                          ? AppColors.secondaryPurple
                          : AppColors.vibrantBlue,
                      height: context.scaleH(52),
                      borderRadius: 12,
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: context.scaleH(12)),

                    // 7. Consent text
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: context.sp(11),
                            color: AppColors.gray500,
                            fontFamily: 'Inter',
                          ),
                          children: const [
                            TextSpan(text: 'By subscribing you agree to our '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: AppColors.vibrantBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.scaleH(24)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientHeaderCard(BuildContext context, bool isPro) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPro
              ? [AppColors.secondaryPurple, AppColors.primaryPurple]
              : [AppColors.vibrantBlue, AppColors.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPro ? AppColors.secondaryPurple : AppColors.vibrantBlue)
                .withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    isPro ? AppIcons.Badge : AppIcons.starFavoriteSvg,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      AppColors.accentYellow,
                      BlendMode.srcIn,
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
                      planName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPro ? 'For power users' : 'Most popular choice',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                planPrice,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const Text(
                '/mo',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildWhiteBenefitRow(
                  isPro ? 'Unlimited Active Ads' : '10 Active Ads',
                ),
                const SizedBox(height: 8),
                _buildWhiteBenefitRow(
                  isPro ? 'Featured Listing' : 'Featured Listings',
                ),
                const SizedBox(height: 8),
                _buildWhiteBenefitRow('Priority Support'),
                const SizedBox(height: 8),
                _buildWhiteBenefitRow(
                  isPro ? '10 Photos per Ad' : '4 Photos per Ad',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteBenefitRow(String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: AppColors.green400,
            shape: BoxShape.circle,
          ),
          child: Center(child: SvgPicture.asset(AppIcons.tickAltSvg)),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, String billingCycle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$planName Plan × $billingCycle',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                planPrice,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax (0%)',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '€0.00',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.gray100, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                planPrice,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.vibrantBlue,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector(
    BuildContext context,
    SubscriptionViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 14),

          // Option A: Credit / Debit Card
          _buildPaymentOption(
            viewModel: viewModel,
            id: 'card',
            title: 'Credit / Debit Card',
            icon: SvgPicture.asset(AppIcons.CardSvg),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCardBadge('VISA', AppColors.navyBlue, true),
                const SizedBox(width: 4),
                _buildCardBadge('MC', AppColors.mastercardRed, false),
              ],
            ),
          ),

          // Option B: PayPal
          _buildPaymentOption(
            viewModel: viewModel,
            id: 'paypal',
            title: 'PayPal',
            icon: const Text(
              'PayPal',
              style: TextStyle(
                color: AppColors.paypalBlue,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ),

          // Option C: Apple Pay
          _buildPaymentOption(
            viewModel: viewModel,
            id: 'apple',
            title: 'Apple Pay',
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppIcons.appleBrandSvg,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Pay',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Option D: Google Pay
          _buildPaymentOption(
            viewModel: viewModel,
            id: 'google',
            title: 'Google Pay',
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(AppIcons.googleSvg, height: 15, width: 15),
                const SizedBox(width: 2),
                const Text(
                  'Pay',
                  style: TextStyle(
                    color: AppColors.googleGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required SubscriptionViewModel viewModel,
    required String id,
    required String title,
    required Widget icon,
    Widget? trailing,
  }) {
    final bool isSelected = viewModel.selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () {
        viewModel.setSelectedPaymentMethod(id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.vibrantBlue : AppColors.slate200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Radio Circle
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.vibrantBlue : AppColors.gray400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.vibrantBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            icon,
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
                fontFamily: 'Inter',
              ),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildCardBadge(String label, Color color, bool isItalic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildCardDetailsForm(
    BuildContext context,
    SubscriptionViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),

          // Card Number
          _buildTextFieldLabel('Card Number'),
          const SizedBox(height: 6),
          CustomTextField(
            controller: viewModel.cardNumberController,
            keyboardType: TextInputType.number,
            hintText: '123 456 789 9876',
            suffixIcon: SvgPicture.asset(AppIcons.lockSvg),
          ),
          const SizedBox(height: 16),

          // Expiry & CVV Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('Expiry Date'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: viewModel.expiryController,
                      keyboardType: TextInputType.datetime,
                      hintText: 'MM/YY',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('CVV'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: viewModel.cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      hintText: '***',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cardholder Name
          _buildTextFieldLabel('Cardholder Name'),
          const SizedBox(height: 6),
          CustomTextField(
            controller: viewModel.cardholderController,
            hintText: 'Ali khan',
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.gray600,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildFooterIndicator(String icon, String text) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          height: 16,
          width: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.slate600,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.gray600,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen(
    BuildContext context,
    SubscriptionViewModel viewModel,
  ) {
    final double checkmarkOuterSize = (context.scale(96)).clamp(72.0, 104.0);
    final double checkmarkInnerSize = (context.scale(64)).clamp(48.0, 72.0);
    final String daysText = isYearly ? '365 Days' : '30 Days';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.hMargin,
                vertical: context.scaleH(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.scaleH(40)),
                  // Animated / Green Checkmark
                  Center(
                    child: Container(
                      width: checkmarkOuterSize,
                      height: checkmarkOuterSize,
                      decoration: const BoxDecoration(
                        color: AppColors.greenLight100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: checkmarkInnerSize,
                          height: checkmarkInnerSize,
                          decoration: const BoxDecoration(
                            color: AppColors.green400,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(AppIcons.tickAltSvg),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaleH(32)),

                  // Title
                  Text(
                    'Payment Successful!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.sp(22),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: context.scaleH(8)),

                  // Subtitle
                  Text(
                    'Your payment has been processed successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.sp(13),
                      color: AppColors.gray500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: context.scaleH(32)),

                  // Summary Card
                  Container(
                    padding: EdgeInsets.all(context.cardPad),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(
                      children: [
                        _buildSuccessRow('Transaction ID', '#DC78564789'),
                        SizedBox(height: context.scaleH(12)),
                        _buildSuccessRow('Date', '20 May 2024'),
                        SizedBox(height: context.scaleH(12)),
                        _buildSuccessRow(
                          'Plan',
                          '$planName Plan ($daysText)',
                        ),
                        SizedBox(height: context.scaleH(12)),
                        _buildSuccessRow('Amount', planPrice),
                        SizedBox(height: context.scaleH(12)),
                        const Divider(color: AppColors.gray200, height: 1),
                        SizedBox(height: context.scaleH(12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Paid',
                              style: TextStyle(
                                fontSize: context.sp(13),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              planPrice,
                              style: TextStyle(
                                fontSize: context.sp(13),
                                fontWeight: FontWeight.bold,
                                color: AppColors.vibrantBlue,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // View Invoice Button
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invoice downloaded successfully!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantBlue,
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaleH(16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'View Invoice',
                      style: TextStyle(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaleH(16)),

                  // Back To Membership link
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close checkout
                    },
                    child: Text(
                      'Back To Membership',
                      style: TextStyle(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.bold,
                        color: AppColors.vibrantBlue,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.gray500,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
