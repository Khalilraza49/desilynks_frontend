import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/support/contact_us_viewmodel.dart';
import 'package:desilynks/viewmodels/navigation/navigation_viewmodel.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final viewModel = context.watch<ContactUsViewModel>();

    if (!viewModel.initialized && authViewModel.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.initFromUser(authViewModel.currentUser);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate800,
              BlendMode.srcIn,
            ),
            width: context.scale(20),
            height: context.scale(20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Us',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(16),
            vertical: context.scaleH(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Header Card
              _buildHeroHeader(context),
              SizedBox(height: context.scaleH(18)),

              // 2. 2x2 Quick Contact Cards
              _buildQuickContactGrid(context, viewModel),
              SizedBox(height: context.scaleH(18)),

              // 3. Send Us a Message Card
              _buildMessageFormCard(context, viewModel),
              SizedBox(height: context.scaleH(20)),

              // // 4. Follow Us Section
              // _buildFollowUsSection(context, viewModel),
              // SizedBox(height: context.scaleH(24)),
            ],
          ),
        ),
      ),
    );
  }

  /// Hero Banner Card with rich blue-indigo-purple gradient and headset badge
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.scale(24)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E58F6), // Vibrant blue
            Color(0xFF4338CA), // Indigo
            Color(0xFF7040ED), // Vibrant purple
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E58F6).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient soft glow circles in background
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: context.scale(120),
              height: context.scale(120),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -35,
            bottom: -35,
            child: Container(
              width: context.scale(130),
              height: context.scale(130),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Main Header Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.scale(20),
              vertical: context.scaleH(26),
            ),
            child: Column(
              children: [
                // Headset Icon Badge
                Center(
                  child: Container(
                    width: context.scale(58),
                    height: context.scale(58),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(context.scale(18)),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.supportSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: context.scale(28),
                        height: context.scale(28),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(14)),

                // Headline
                Text(
                  "We're Here to Help!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: context.scaleH(6)),

                // Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(8)),
                  child: Text(
                    'Reach out to us anytime — we usually respond within 24 hours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.90),
                      fontSize: context.sp(12.5),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2x2 Grid of Quick Contact Cards
  Widget _buildQuickContactGrid(
    BuildContext context,
    ContactUsViewModel viewModel,
  ) {
    return Column(
      children: [
        // Row 1: Email & WhatsApp
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                context: context,
                iconPath: AppIcons.emailSvg,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFEEF4FF),
                title: 'Email',
                detail: ContactUsViewModel.contactEmail,
                onTap: () => viewModel.launchEmail(context),
              ),
            ),
            SizedBox(width: context.scale(12)),
            Expanded(
              child: _buildContactCard(
                context: context,
                iconPath: AppIcons.chatRoundSvg,
                iconColor: const Color(0xFF6366F1),
                iconBgColor: const Color(0xFFEEF2FF),
                title: 'In-App Chat',
                detail: 'Support Team',
                onTap: () => context.read<NavigationViewModel>().openChat(),
              ),
            ),
          ],
        ),
        SizedBox(height: context.scaleH(12)),

        // Row 2: Phone & Office
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                context: context,
                iconPath: AppIcons.callSvg,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFFEF6E6),
                title: 'Phone',
                detail: ContactUsViewModel.contactPhone,
                onTap: () => viewModel.launchPhone(context),
              ),
            ),
            SizedBox(width: context.scale(12)),
            Expanded(
              child: _buildContactCard(
                context: context,
                iconPath: AppIcons.locationSvg,
                iconColor: const Color(0xFFEF4444),
                iconBgColor: const Color(0xFFFFECEF),
                title: 'Office',
                detail: ContactUsViewModel.contactOffice,
                onTap: () => viewModel.launchOfficeLocation(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Individual Quick Contact Card
  Widget _buildContactCard({
    required BuildContext context,
    required String iconPath,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String detail,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.scale(18)),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(12),
            vertical: context.scaleH(16),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(context.scale(18)),
            border: Border.all(color: AppColors.slate100),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                width: context.scale(42),
                height: context.scale(42),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(context.scale(12)),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    width: context.scale(20),
                    height: context.scale(20),
                  ),
                ),
              ),
              SizedBox(height: context.scaleH(10)),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              SizedBox(height: context.scaleH(4)),

              // Subtitle/Detail
              Text(
                detail,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.sp(11),
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Send us a Message" Input Form Card
  Widget _buildMessageFormCard(
    BuildContext context,
    ContactUsViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scale(18)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Send us a Message',
            style: TextStyle(
              fontSize: context.sp(16),
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          SizedBox(height: context.scaleH(16)),

          // 1. Name Input
          Text(
            'Your Name',
            style: TextStyle(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w600,
              color: AppColors.slate800,
            ),
          ),
          SizedBox(height: context.scaleH(6)),
          _buildTextField(
            context: context,
            controller: viewModel.nameController,
            hintText: 'Ali Khan',
            maxLength: 100,
          ),
          SizedBox(height: context.scaleH(14)),

          // 2. Email Input
          Text(
            'Email Address',
            style: TextStyle(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w600,
              color: AppColors.slate800,
            ),
          ),
          SizedBox(height: context.scaleH(6)),
          _buildTextField(
            context: context,
            controller: viewModel.emailController,
            hintText: 'ali@example.com',
            keyboardType: TextInputType.emailAddress,
            maxLength: 100,
          ),
          SizedBox(height: context.scaleH(14)),

          // 3. Message Input with Character Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Message',
                style: TextStyle(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate800,
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: viewModel.messageController,
                builder: (context, value, _) {
                  final length = value.text.length;
                  return Text(
                    '$length / 2000',
                    style: TextStyle(
                      fontSize: context.sp(11.5),
                      fontWeight: FontWeight.w500,
                      color: length > 2000
                          ? AppColors.primaryRed
                          : AppColors.slate400,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: context.scaleH(6)),
          _buildTextField(
            context: context,
            controller: viewModel.messageController,
            hintText: 'How can we help you?',
            maxLines: 4,
            maxLength: 2000,
          ),
          SizedBox(height: context.scaleH(18)),

          // 4. Send Message Button
          SizedBox(
            width: double.infinity,
            child: Container(
              height: context.scaleH(48),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB), // Blue
                    Color(0xFF7040ED), // Purple
                  ],
                ),
                borderRadius: BorderRadius.circular(context.scale(12)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: viewModel.isSubmitting
                    ? null
                    : () => viewModel.sendMessage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.scale(12)),
                  ),
                ),
                child: viewModel.isSubmitting
                    ? SizedBox(
                        width: context.scale(20),
                        height: context.scale(20),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.send2,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                            width: context.scale(16),
                            height: context.scale(16),
                          ),
                          SizedBox(width: context.scale(8)),
                          Text(
                            'Send Message',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: context.sp(14.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Form Text Field with subtle slate style
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: (
        context, {
        required currentLength,
        required isFocused,
        maxLength,
      }) =>
          null,
      style: TextStyle(fontSize: context.sp(13.5), color: AppColors.slate900),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.slate400,
          fontSize: context.sp(13),
        ),
        filled: true,
        fillColor: AppColors.slate50,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.scale(14),
          vertical: context.scaleH(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: const BorderSide(color: AppColors.slate200, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  /// "Follow Us" Social Media Section
  // ignore: unused_element
  Widget _buildFollowUsSection(
    BuildContext context,
    ContactUsViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow Us',
          style: TextStyle(
            fontSize: context.sp(14),
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        SizedBox(height: context.scaleH(10)),
        Row(
          children: [
            // 1. Instagram
            Expanded(
              child: _buildSocialButton(
                context: context,
                iconPath: 'assets/svg/insta-black.svg',
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFFA7E1E),
                    Color(0xFFD62976),
                    Color(0xFF962FBF),
                  ],
                ),
                onTap: () => viewModel.launchSocial(context, 'instagram'),
              ),
            ),
            SizedBox(width: context.scale(8)),

            // 2. Facebook
            Expanded(
              child: _buildSocialButton(
                context: context,
                iconPath: AppIcons.facebookSvg,
                solidColor: const Color(0xFF1877F2),
                onTap: () => viewModel.launchSocial(context, 'facebook'),
              ),
            ),
            SizedBox(width: context.scale(8)),

            // 3. YouTube
            Expanded(
              child: _buildSocialButton(
                context: context,
                iconPath: AppIcons.youtubeSvg,
                solidColor: const Color(0xFFFF0000),
                onTap: () => viewModel.launchSocial(context, 'youtube'),
              ),
            ),
            SizedBox(width: context.scale(8)),

            // 4. Twitter / X
            Expanded(
              child: _buildSocialButton(
                context: context,
                iconPath: AppIcons.twitterSvg,
                solidColor: const Color(0xFF1DA1F2),
                onTap: () => viewModel.launchSocial(context, 'twitter'),
              ),
            ),
            SizedBox(width: context.scale(8)),

            // 5. TikTok
            Expanded(
              child: _buildSocialButton(
                context: context,
                iconPath: AppIcons.tiktokSvg,
                solidColor: const Color(0xFF000000),
                onTap: () => viewModel.launchSocial(context, 'tiktok'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Individual Social Media Action Button
  Widget _buildSocialButton({
    required BuildContext context,
    required String iconPath,
    Color? solidColor,
    Gradient? gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.scale(12)),
        child: Ink(
          height: context.scaleH(42),
          decoration: BoxDecoration(
            color: solidColor,
            gradient: gradient,
            borderRadius: BorderRadius.circular(context.scale(12)),
            boxShadow: [
              BoxShadow(
                color: (solidColor ?? const Color(0xFFFA7E1E)).withValues(
                  alpha: 0.25,
                ),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
              width: context.scale(20),
              height: context.scale(20),
            ),
          ),
        ),
      ),
    );
  }
}
