import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/create_post_viewmodel.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';

class CreatePostView extends StatelessWidget {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final createPostViewModel = context.watch<CreatePostViewModel>();
    final user = authViewModel.currentUser;
    final bool isLoggedIn = authViewModel.isAuthenticated;
    final isSmall = context.isSmall;
    final hMargin = isSmall ? 14.0 : AppConstants.marginHorizontal;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hMargin,
                vertical: AppConstants.paddingMedium,
              ),
              child: Row(
                children: [
                  // Close button (X) on the left
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingSmall),
                      decoration: const BoxDecoration(
                        color: AppColors.slate100,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.crossSmallSvg,
                        width: AppConstants.iconSize18,
                        height: AppConstants.iconSize18,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate500,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Title
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate800,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 34),
                ],
              ),
            ),
            const Divider(
              color: AppColors.slate200,
              thickness: AppConstants.borderWidth,
              height: 1,
            ),

            // Scrollable Content area
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hMargin,
                        vertical: AppConstants.padding20,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                              AppConstants.padding2,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.vibrantBlue,
                                width: AppConstants.borderWidthThick,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: isSmall
                                  ? 20.0
                                  : AppConstants.borderRadius24,
                              backgroundColor: AppColors.slate200,
                              backgroundImage:
                                  isLoggedIn &&
                                      user?.profilePhotoUrl != null &&
                                      user!.profilePhotoUrl!.isNotEmpty
                                  ? NetworkImage(user.profilePhotoUrl!)
                                  : null,
                              child:
                                  isLoggedIn &&
                                      user?.profilePhotoUrl != null &&
                                      user!.profilePhotoUrl!.isNotEmpty
                                  ? null
                                  : SvgPicture.asset(
                                      AppIcons.personSvg,
                                      width: 26,
                                      height: 26,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.slate500,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingLarge),
                          // User Name & Tagline
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLoggedIn
                                      ? '${user?.firstName} ${user?.lastName ?? ''}'
                                            .trim()
                                      : 'Ahmad Hassan',
                                  style: TextStyle(
                                    fontSize: isSmall
                                        ? 18
                                        : AppConstants.fontSizeXXL,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate800,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppConstants.padding2),
                                const Text(
                                  'What would you like to post today?',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeMD,
                                    color: AppColors.slate500,
                                    fontFamily: AppStrings.fontInter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Select Category Header Label
                    Container(
                      width: double.infinity,
                      color: AppColors.slate50,
                      padding: EdgeInsets.symmetric(
                        horizontal: hMargin,
                        vertical: AppConstants.paddingMedium,
                      ),
                      child: const Text(
                        'SELECT CATEGORY',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSM,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate500,
                          letterSpacing: 0.8,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),

                    // Category Cards Section
                    Container(
                      color: AppColors.slate50,
                      padding: EdgeInsets.only(
                        left: hMargin,
                        right: hMargin,
                        top: AppConstants.paddingLarge,
                        bottom: AppConstants.padding32,
                      ),
                      child: Column(
                        children: [
                          ...createPostViewModel.categories.map(
                            (cat) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.paddingMedium,
                              ),
                              child: _buildCategoryCard(
                                context: context,
                                category: cat,
                                onTap: () =>
                                    createPostViewModel.handleCategorySelection(
                                      context,
                                      cat,
                                      isAuthenticated: isLoggedIn,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required CreatePostCategoryItem category,
    VoidCallback? onTap,
  }) {
    final isSmall = context.isSmall;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          border: Border.all(
            color: AppColors.slate200,
            width: AppConstants.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12.0 : AppConstants.paddingLarge,
          vertical: isSmall ? 10.0 : AppConstants.paddingStandard,
        ),
        child: Row(
          children: [
            Container(
              width: isSmall ? 40 : 46,
              height: isSmall ? 40 : 46,
              decoration: BoxDecoration(
                color: category.bgColor,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  category.svg,
                  colorFilter: ColorFilter.mode(
                    category.iconColor,
                    BlendMode.srcIn,
                  ),
                  width: isSmall ? 18 : 22,
                  height: isSmall ? 18 : 22,
                ),
              ),
            ),
            SizedBox(width: isSmall ? 10 : AppConstants.paddingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${category.emoji} ',
                        style: TextStyle(
                          fontSize: isSmall ? 16 : AppConstants.fontSizeXL,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          category.title,
                          style: TextStyle(
                            fontSize: isSmall ? 15 : AppConstants.fontSizeXL,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800,
                            fontFamily: AppStrings.fontInter,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category.subtitle,
                    style: TextStyle(
                      fontSize: isSmall ? 12 : AppConstants.fontSizeSM,
                      color: AppColors.slate500,
                      fontFamily: AppStrings.fontInter,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              AppIcons.More_arrow,
              colorFilter: const ColorFilter.mode(
                AppColors.slate400,
                BlendMode.srcIn,
              ),
              width: isSmall ? 20 : AppConstants.iconSizeLG,
              height: isSmall ? 20 : AppConstants.iconSizeLG,
            ),
          ],
        ),
      ),
    );
  }
}
