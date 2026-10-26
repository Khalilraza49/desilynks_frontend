import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/settings/settings_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showLogoutDialog(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to log out of DesiConnect?'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    vm.cancelLogout();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.slate600),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Flexible(
                child: CustomButton(
                  text: 'Logout',
                  width: 96,
                  height: 40,
                  backgroundColor: AppColors.primaryRed,
                  borderRadius: AppConstants.borderRadius10.toDouble(),
                  fontWeight: FontWeight.bold,
                  onPressed: () {
                    Navigator.pop(ctx);
                    vm.confirmLogout(() async {
                      await Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      ).logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    bool obscure = true;
    bool isDeleting = false;
    String? localError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.redLight100,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius10,
                  ),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.primaryRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              const Expanded(
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This action is permanent and cannot be undone. All your posts, ads, messages, and profile data will be permanently deleted.\n\nPlease enter your password to confirm:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.slate600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingStandard,
                      vertical: AppConstants.paddingMedium,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusSmall,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: AppColors.slate400,
                      ),
                      onPressed: () {
                        setDialogState(() => obscure = !obscure);
                      },
                    ),
                  ),
                ),
                if (localError != null) ...[
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    localError!,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.slate600),
              ),
            ),
            CustomButton(
              text: 'Delete',
              width: 100,
              height: 40,
              backgroundColor: AppColors.primaryRed,
              borderRadius: AppConstants.borderRadius10.toDouble(),
              fontWeight: FontWeight.bold,
              isLoading: isDeleting,
              onPressed: isDeleting
                  ? null
                  : () async {
                      final pwd = passwordController.text.trim();
                      if (pwd.isEmpty) {
                        setDialogState(
                          () => localError = 'Please enter your password',
                        );
                        return;
                      }

                      setDialogState(() {
                        isDeleting = true;
                        localError = null;
                      });

                      final authVm = Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      );
                      final success = await authVm.deleteAccount(pwd);

                      if (success) {
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      } else {
                        setDialogState(() {
                          isDeleting = false;
                          localError = authVm.errorMessage ??
                              'Failed to delete account. Please try again.';
                        });
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageComingSoon(BuildContext context) {
    ComingSoonDialog.show(
      context,
      title: 'Coming Soon',
      featureName: 'Language Selection',
      message:
          'Multiple language support is currently under development. Soon you will be able to use DesiConnect in Urdu, Hindi, Spanish, and more!',
      svgIcon: AppIcons.translate2,
      badgeColor: AppColors.amber100,
      iconColor: AppColors.amber700,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.slate50,
          appBar: AppBar(
            backgroundColor: AppColors.slate50,
            elevation: AppConstants.elevationNone,
            scrolledUnderElevation: AppConstants.elevationNone,
            leading: IconButton(
              icon: SvgPicture.asset(
                AppIcons.arrowBackBasicSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate800,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                fontSize: context.sp(AppConstants.fontSizeTitle),
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.isSmall
                  ? AppConstants.paddingStandard
                  : AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(context),
                const SizedBox(height: AppConstants.padding20),

                _buildSectionHeader(context, 'ACCOUNT'),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildGroupCard([
                  _buildSettingRow(
                    context: context,
                    icon: AppIcons.personSvg,
                    iconBgColor: AppColors.lightBlue,
                    iconColor: AppColors.blue500,
                    title: 'Account Settings',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                  _buildSettingRow(
                    context: context,
                    icon: AppIcons.lockClosedSvg,
                    iconBgColor: AppColors.violetLight,
                    iconColor: AppColors.primaryPurple,
                    title: 'Privacy',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy settings opened'),
                        ),
                      );
                    },
                  ),
                  _buildSettingRow(
                    context: context,
                    icon: AppIcons.notificationSvg,
                    iconBgColor: AppColors.softGreen,
                    iconColor: AppColors.emerald,
                    title: 'Notifications',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.notifications),
                  ),
                  _buildSettingRow(
                    context: context,
                    icon: AppIcons.blockSvg,
                    iconBgColor: AppColors.redLight100,
                    iconColor: AppColors.primaryRed,
                    title: 'Blocked Users',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.blockedUsers),
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: AppConstants.padding20),

                _buildSectionHeader(context, 'PREFERENCES'),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildGroupCard([
                  _buildSettingRow(
                    context: context,
                    icon: AppIcons.translate2,
                    iconBgColor: AppColors.amber100,
                    iconColor: AppColors.amber700,
                    title: 'Language',
                    trailingText: vm.selectedLanguage,
                    onTap: () => _showLanguageComingSoon(context),
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: AppConstants.padding20),

                _buildSectionHeader(context, 'SUPPORT'),
                const SizedBox(height: AppConstants.paddingSmall),
                _buildGroupCard([
                  _buildSettingRow(
                    context: context,
                    icon: AppIcons.infoCircularButtonSvg,
                    iconBgColor: AppColors.redLight100,
                    iconColor: AppColors.primaryRed,
                    title: 'Help Center',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help Center opened')),
                      );
                    },
                  ),
                  _buildSettingRow(
                    context: context,
                    icon: AppIcons.supportSvg,
                    iconBgColor: AppColors.greenLight100,
                    iconColor: AppColors.successGreen,
                    title: 'Contact Us',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.contactUs);
                    },
                  ),
                  _buildSettingRow(
                    context: context,
                    icon: AppIcons.infoCircularButtonSvg,
                    iconBgColor: AppColors.blueBg,
                    iconColor: AppColors.primaryBlue,
                    title: 'About DesiConnect',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('About DesiConnect App v1.0.0'),
                        ),
                      );
                    },
                  ),
                  _buildSettingRow(
                    context: context,
                    icon: AppIcons.newspaperSvg,
                    iconBgColor: AppColors.greenLight100,
                    iconColor: AppColors.successGreen,
                    title: 'Daily News',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Daily News section opened'),
                        ),
                      );
                    },
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: AppConstants.padding20),

                _buildLogoutButton(context, vm),

                const SizedBox(height: AppConstants.paddingSmall),

                _buildDeleteAccountButton(context),

                const SizedBox(height: AppConstants.paddingExtraLarge),

                _buildDeveloperTestCard(context),

                const SizedBox(height: AppConstants.padding32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        final user = authViewModel.currentUser;
        final String userName =
            (user?.username != null && user!.username.trim().isNotEmpty)
            ? user.username
            : 'Guest User';
        final String userEmail =
            (user?.email != null && user!.email.trim().isNotEmpty)
            ? user.email
            : 'khalil@desiconnect.es';
        final String? picPath = user?.profilePhotoUrl;

        ImageProvider? avatarImage;
        if (picPath != null && picPath.isNotEmpty) {
          if (picPath.startsWith('http')) {
            avatarImage = NetworkImage(picPath);
          } else {
            avatarImage = FileImage(File(picPath));
          }
        }

        final double avatarSize = context.isSmall ? 44 : 52;

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          child: Container(
            padding: EdgeInsets.all(
              context.isSmall
                  ? AppConstants.paddingMedium
                  : AppConstants.paddingLarge,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
              border: Border.all(color: AppColors.slate200),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: AppConstants.paddingSmall,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightBlue,
                    border: Border.all(
                      color: AppColors.blue500,
                      width: AppConstants.borderWidthMedium,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.blueBg,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? SvgPicture.asset(
                            AppIcons.personSvg,
                            colorFilter: const ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
                            width: context.isSmall ? 24 : 30,
                          )
                        : null,
                  ),
                ),
                SizedBox(
                  width: context.isSmall
                      ? AppConstants.paddingSmall
                      : AppConstants.paddingStandard,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.sp(AppConstants.fontSizeXL),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(height: AppConstants.padding2),
                      Text(
                        userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.sp(AppConstants.fontSizeMD),
                          color: AppColors.slate500,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                SvgPicture.asset(
                  AppIcons.More_arrow,
                  width: context.isSmall ? 22 : 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.sp(AppConstants.fontSizeSM),
        fontWeight: FontWeight.bold,
        color: AppColors.slate400,
        fontFamily: AppStrings.fontInter,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildGroupCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: AppConstants.paddingSmall,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required String icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    Widget? trailing,
    String? trailingText,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.isSmall
                  ? AppConstants.paddingStandard
                  : AppConstants.paddingLarge,
              vertical: AppConstants.paddingStandard,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius10,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      icon,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                SizedBox(
                  width: context.isSmall
                      ? AppConstants.paddingSmall
                      : AppConstants.paddingStandard,
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.sp(AppConstants.fontSizeLG),
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                if (trailing != null)
                  trailing
                else if (trailingText != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trailingText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.sp(AppConstants.fontSizeMD),
                          color: AppColors.slate400,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                      const SizedBox(width: AppConstants.padding4),
                      SvgPicture.asset(
                        AppIcons.More_arrow,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate400,
                          BlendMode.srcIn,
                        ),
                        height: AppConstants.iconSize,
                        width: AppConstants.iconSize,
                      ),
                    ],
                  )
                else
                  SvgPicture.asset(
                    AppIcons.More_arrow,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate400,
                      BlendMode.srcIn,
                    ),
                    height: AppConstants.iconSize,
                    width: AppConstants.iconSize,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: AppConstants.borderWidth,
            indent: 66,
            endIndent: AppConstants.paddingLarge,
            color: AppColors.slate100,
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, SettingsViewModel vm) {
    return InkWell(
      onTap: () => _showLogoutDialog(context, vm),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingStandard,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          border: Border.all(color: AppColors.redLight100, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppIcons.logOut01Svg,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryRed,
                BlendMode.srcIn,
              ),
              height: AppConstants.iconSize,
              width: AppConstants.iconSize,
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Flexible(
              child: Text(
                'Logout',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.sp(AppConstants.fontSizeLG),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return InkWell(
      onTap: () => _showDeleteAccountDialog(context),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingStandard,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          border: Border.all(color: AppColors.slate200, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_forever_outlined,
              color: AppColors.primaryRed,
              size: 20,
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Flexible(
              child: Text(
                'Delete Account',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.sp(AppConstants.fontSizeMD),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryRed,
                  fontFamily: AppStrings.fontInter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperTestCard(BuildContext context) {
    final List<Map<String, String?>> testScreens = [
      {'label': '🚫 No Internet', 'route': null, 'msg': 'No Internet Screen'},
      {'label': '🔍 404', 'route': null, 'msg': '404 Page Not Found'},
      {'label': '⚙️ Admin', 'route': null, 'msg': 'Admin Panel'},
      {'label': '🛡️ Admin Panel', 'route': null, 'msg': 'Admin Panel'},
      {
        'label': '🔔 Empty Notif',
        'route': AppRoutes.notifications,
        'msg': null,
      },
      {'label': '📅 Calendar', 'route': null, 'msg': 'Calendar View'},
      {'label': '💰 Checkout', 'route': AppRoutes.checkout, 'msg': null},
      {'label': '🚩 Report', 'route': null, 'msg': 'Report Dialog'},
      {'label': '🔖 Save Search', 'route': AppRoutes.search, 'msg': null},
      {'label': '🤖 AI Recs', 'route': null, 'msg': 'AI Recommendations'},
      {'label': '🚀 Onboarding', 'route': AppRoutes.onboarding, 'msg': null},
      {
        'label': '📥 Hire Sent',
        'route': AppRoutes.hireWorkerSuccess,
        'msg': null,
      },
      {
        'label': '✅ Hire Accepted',
        'route': null,
        'msg': 'Hire Request Accepted',
      },
      {
        'label': '❌ Hire Declined',
        'route': null,
        'msg': 'Hire Request Declined',
      },
    ];

    return Container(
      padding: EdgeInsets.all(
        context.isSmall
            ? AppConstants.paddingMedium
            : AppConstants.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.build_rounded,
                size: AppConstants.iconSizeMD,
                color: AppColors.slate500,
              ),
              const SizedBox(width: AppConstants.paddingSmall - 2),
              Expanded(
                child: Text(
                  'Developer: Test Screens',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.sp(AppConstants.fontSizeMD),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate500,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children: testScreens.map((item) {
              return InkWell(
                onTap: () {
                  final route = item['route'];
                  final msg = item['msg'];
                  if (route != null) {
                    Navigator.pushNamed(context, route);
                  } else if (msg != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                borderRadius: BorderRadius.circular(AppConstants.paddingMedium),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.padding10,
                    vertical: AppConstants.paddingSmall - 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.paddingMedium,
                    ),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: context.sp(AppConstants.fontSizeSM),
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate600,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
