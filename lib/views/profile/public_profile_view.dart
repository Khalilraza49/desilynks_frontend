import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/models/user_model.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/models/chat_model.dart';
import 'package:desilynks/models/marketplace_item_model.dart';
import 'package:desilynks/models/community_post_model.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/post_room_viewmodel.dart';
import 'package:desilynks/viewmodels/community/community_viewmodel.dart';
import 'package:desilynks/views/chat/chat_detail_view.dart';
import 'package:desilynks/viewmodels/chat/chat_viewmodel.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/models/moderation_models.dart';
import 'package:desilynks/viewmodels/moderation/moderation_viewmodel.dart';
import 'package:desilynks/core/utils/image_utils.dart';
import 'package:desilynks/widgets/report_bottom_sheet.dart';

class PublicProfileView extends StatelessWidget {
  final PropertyOwner owner;

  const PublicProfileView({super.key, required this.owner});

  static const List<String> _tabs = [
    'Overview',
    'Jobs',
    'Ads',
    'Posts',
    'Reviews',
  ];

  String _formatAddress(UserAddress? addr) {
    if (addr == null) return '';
    final city = addr.city?.trim() ?? '';
    final province = addr.province?.trim() ?? '';
    final country = addr.country?.trim() ?? '';
    final street = addr.streetAddress.trim();

    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (province.isNotEmpty && province.toLowerCase() != city.toLowerCase()) {
      parts.add(province);
    }
    if (country.isNotEmpty &&
        country.toLowerCase() != city.toLowerCase() &&
        country.toLowerCase() != province.toLowerCase()) {
      parts.add(country);
    }

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    if (street.isNotEmpty) {
      return street;
    }

    return '';
  }

  String _resolveUserLocation({
    required bool hasUserDetails,
    required bool isCurrentUser,
    required UserModel? currentUser,
    required UserModel? userProfile,
    required List<PropertyModel> liveUserRooms,
    required List<JobModel> liveUserJobs,
    required List<MarketplaceItemModel> liveUserProducts,
  }) {
    if (!hasUserDetails) {
      return 'No History found';
    }

    // 1. Check userProfile address
    final profileLocation = _formatAddress(userProfile?.address);
    if (profileLocation.isNotEmpty) return profileLocation;

    // 2. If viewing current user, check currentUser address
    if (isCurrentUser && currentUser?.address != null) {
      final currentLoc = _formatAddress(currentUser!.address);
      if (currentLoc.isNotEmpty) return currentLoc;
    }

    // 3. Fallback to location from user's live postings
    for (final room in liveUserRooms) {
      if (room.location.trim().isNotEmpty) return room.location.trim();
    }
    for (final job in liveUserJobs) {
      if (job.location.trim().isNotEmpty) return job.location.trim();
    }
    for (final prod in liveUserProducts) {
      if (prod.location.trim().isNotEmpty) return prod.location.trim();
    }

    return 'Location not specified';
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }
    if (url.startsWith('/')) {
      return '${ApiEndpoints.baseUrl}$url';
    }
    return url;
  }

  String _getMemberDate(String dateStr) {
    if (dateStr.isEmpty) return 'Jan 2024';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'Jan 2024';
    }
  }

  void _openChat(
    BuildContext context,
    bool hasUserDetails,
    String displayName,
    UserModel? userProfile,
  ) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final currentUserId = authVM.currentUser?.id;

    // Resolve the other user's ID
    String targetUserId = owner.id.trim();
    if (targetUserId.isEmpty &&
        userProfile != null &&
        userProfile.id.trim().isNotEmpty) {
      targetUserId = userProfile.id.trim();
    }

    if (targetUserId.isEmpty) {
      final roomVM = Provider.of<PostRoomViewModel>(context, listen: false);
      for (final p in roomVM.publicProperties) {
        if (p.ownerId.isNotEmpty &&
            (p.owner?.fullName == displayName ||
                p.owner?.firstName == displayName)) {
          targetUserId = p.ownerId;
          break;
        }
      }
    }

    if (targetUserId.isEmpty) {
      final jobsVM = Provider.of<JobsViewModel>(context, listen: false);
      for (final j in jobsVM.publicJobs) {
        if (j.employerId.isNotEmpty && j.companyName == displayName) {
          targetUserId = j.employerId;
          break;
        }
      }
    }

    if (targetUserId.isEmpty) {
      final marketVM = Provider.of<MarketplaceViewModel>(
        context,
        listen: false,
      );
      for (final m in marketVM.items) {
        if (m.sellerId.isNotEmpty && m.sellerName == displayName) {
          targetUserId = m.sellerId;
          break;
        }
      }
    }

    if (targetUserId.isEmpty) {
      final communityVM = Provider.of<CommunityViewModel>(
        context,
        listen: false,
      );
      for (final post in communityVM.posts) {
        final authorId = post.authorId ?? post.author?.id ?? '';
        if (authorId.isNotEmpty &&
            (post.author?.fullName == displayName ||
                post.author?.firstName == displayName)) {
          targetUserId = authorId;
          break;
        }
      }
    }

    // If other user cannot be identified
    if (targetUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User Info not available'),
          backgroundColor: AppColors.backgroundOffWhite,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Cannot chat with self
    if (currentUserId != null && targetUserId == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot chat with yourself.'),
          backgroundColor: AppColors.backgroundOffWhite,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final chatVM = Provider.of<ChatViewModel>(context, listen: false);
    ChatConversationModel? existingConv;
    for (final c in chatVM.conversations) {
      if (c.otherParticipant.id == targetUserId ||
          (c.id.isNotEmpty && c.id == targetUserId)) {
        existingConv = c;
        break;
      }
    }

    final String firstName = owner.firstName.trim().isNotEmpty
        ? owner.firstName.trim()
        : (userProfile?.firstName.trim().isNotEmpty ?? false
              ? userProfile!.firstName.trim()
              : displayName);

    final String lastName =
        (owner.lastName != null && owner.lastName!.trim().isNotEmpty)
        ? owner.lastName!.trim()
        : (userProfile?.lastName?.trim() ?? '');

    final String photoUrl = _resolveImageUrl(
      userProfile?.profilePhotoUrl ?? owner.profilePhotoUrl,
    );

    final conv =
        existingConv ??
        ChatConversationModel(
          id: '',
          otherParticipant: ChatParticipantModel(
            id: targetUserId,
            firstName: firstName,
            lastName: lastName,
            profilePhotoUrl: photoUrl.isNotEmpty ? photoUrl : null,
          ),
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatDetailView(conversation: conv)),
    );
  }

  void _makeCall(
    BuildContext context,
    bool hasUserDetails,
    UserModel? userProfile,
  ) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final isCurrentUser = authVM.currentUser?.id == owner.id;
    final phone =
        userProfile?.phoneNumber ??
        owner.phoneNumber ??
        (isCurrentUser ? authVM.currentUser?.phoneNumber : null);

    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is not available for this user.'),
          backgroundColor: AppColors.backgroundOffWhite,
        ),
      );
      return;
    }

    final double modalIconSize = context.scale(24).clamp(20.0, 28.0);
    final double modalCircleSize = context.scale(50).clamp(46.0, 56.0);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: modalCircleSize,
                  height: modalCircleSize,
                  decoration: const BoxDecoration(
                    color: AppColors.slate100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.callSvg,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryRed,
                        BlendMode.srcIn,
                      ),
                      height: modalIconSize,
                      width: modalIconSize,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Call Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.slate600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling $phone...'),
                          backgroundColor: AppColors.backgroundOffWhite,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.slate900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Dial Number',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _loadData(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (authVM.shouldInitPublicProfile(owner)) {
      authVM.initPublicProfile(owner);
    }

    final jobsVM = Provider.of<JobsViewModel>(context, listen: false);
    if (!jobsVM.hasFetchedPublicJobs && !jobsVM.isLoading) {
      jobsVM.fetchPublicJobs();
    }

    final roomVM = Provider.of<PostRoomViewModel>(context, listen: false);
    if (!roomVM.hasFetchedPublic && !roomVM.isLoadingPublic) {
      roomVM.fetchPublicProperties();
    }

    final marketVM = Provider.of<MarketplaceViewModel>(
      context,
      listen: false,
    );
    if (!marketVM.hasFetched && !marketVM.isLoading) {
      marketVM.fetchPublicProducts();
    }

    final communityVM = Provider.of<CommunityViewModel>(
      context,
      listen: false,
    );
    if (communityVM.posts.isEmpty && !communityVM.isLoading) {
      communityVM.fetchFeed();
    }

    final currentUserId = authVM.currentUser?.id;
    final isCurrentUser = currentUserId != null &&
        (owner.id == currentUserId ||
            (owner.id.isEmpty &&
                owner.fullName.trim() == authVM.currentUser?.username));

    if (isCurrentUser) {
      if (!jobsVM.hasFetchedUserJobs && !jobsVM.isLoading) {
        jobsVM.fetchUserJobs();
      }
      if (!roomVM.hasFetchedUserProps && !roomVM.isLoadingUserProps) {
        roomVM.fetchUserProperties();
      }
      if (!marketVM.hasFetchedMyAds && !marketVM.isLoading) {
        marketVM.fetchMyAds();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(context);
    });

    final authVM = Provider.of<AuthViewModel>(context);

    final userProfile = authVM.publicUserProfile;
    final activeTab = authVM.publicProfileActiveTab;
    final likedPostIds = authVM.publicProfileLikedPosts;

    // ────────────────────────────────────────────────────────────────────────
    // 1. Resolve User Details Existence
    // ────────────────────────────────────────────────────────────────────────
    final bool hasUserDetails =
        (owner.fullName.trim().isNotEmpty &&
            owner.fullName.trim() != 'User Name' &&
            owner.fullName.trim() != 'User') ||
        (userProfile != null &&
            userProfile.username.trim().isNotEmpty &&
            userProfile.username.trim() != 'User Name' &&
            userProfile.username.trim() != 'User');

    final String displayName = hasUserDetails
        ? (owner.fullName.trim().isNotEmpty &&
                  owner.fullName.trim() != 'User Name' &&
                  owner.fullName.trim() != 'User'
              ? owner.fullName.trim()
              : (userProfile?.username.trim().isNotEmpty == true
                    ? userProfile!.username.trim()
                    : 'User Name'))
        : 'User Name';

    final String? avatarUrl = hasUserDetails
        ? _resolveImageUrl(userProfile?.profilePhotoUrl ?? owner.profilePhotoUrl)
        : null;

    final gender = userProfile?.gender?.trim();
    final String displaySubtitle = hasUserDetails
        ? (gender != null && gender.isNotEmpty
              ? 'Member · $gender'
              : 'Member')
        : 'No History found';

    final String memberSince = hasUserDetails
        ? _getMemberDate(
            userProfile?.createdAt != null
                ? userProfile!.createdAt.toString()
                : owner.createdAt,
          )
        : 'No History found';

    // Responsive dimensions clamped smoothly for compact, normal, large, and tablet viewports
    final double bannerHeight = context.isTablet
        ? 240.0
        : (context.scaleH(200.0)).clamp(160.0, 220.0);
    final double avatarSize = context.isTablet
        ? 110.0
        : (context.scale(96.0)).clamp(82.0, 110.0);
    final double maxContentWidth = context.isTablet ? 720.0 : 640.0;
    final double headerIconSize = context.scale(18).clamp(16.0, 22.0);
    final double infoIconSize = context.scale(15).clamp(13.0, 18.0);

    // ────────────────────────────────────────────────────────────────────────
    // 2. Fetch User Postings from ViewModels (Deduplicated by ID)
    // ────────────────────────────────────────────────────────────────────────
    final currentUserId = authVM.currentUser?.id;
    final String targetUserId = owner.id.trim().isNotEmpty
        ? owner.id.trim()
        : (userProfile?.id.trim() ?? '');
    final bool isCurrentUser =
        currentUserId != null &&
        (owner.id == currentUserId ||
            (owner.id.isEmpty &&
                hasUserDetails &&
                displayName == authVM.currentUser?.username));

    // Room Ads posted by this user (deduplicated by id)
    final roomVM = Provider.of<PostRoomViewModel>(context);
    final Map<String, PropertyModel> uniqueRooms = {};
    for (final p in [
      ...roomVM.publicProperties,
      ...roomVM.userProperties,
    ]) {
      final matchesOwner = owner.id.isNotEmpty &&
          (p.ownerId == owner.id || p.owner?.id == owner.id);
      final matchesCurrentUser = isCurrentUser &&
          (p.ownerId == currentUserId || p.owner?.id == currentUserId);
      if (matchesOwner || matchesCurrentUser) {
        final key = p.id.isNotEmpty ? p.id : '${p.title}_${p.location}';
        uniqueRooms[key] = p;
      }
    }
    final List<PropertyModel> liveUserRooms = uniqueRooms.values.toList();

    // Marketplace Products posted by this user (deduplicated by id)
    final marketVM = Provider.of<MarketplaceViewModel>(context);
    final Map<String, MarketplaceItemModel> uniqueProducts = {};
    for (final item in [
      ...marketVM.items,
      ...marketVM.myAds,
    ]) {
      final matchesOwner = owner.id.isNotEmpty && item.sellerId == owner.id;
      final matchesCurrentUser =
          isCurrentUser && item.sellerId == currentUserId;
      if (matchesOwner || matchesCurrentUser) {
        final key = item.id.isNotEmpty ? item.id : '${item.title}_${item.price}';
        uniqueProducts[key] = item;
      }
    }
    final List<MarketplaceItemModel> liveUserProducts =
        uniqueProducts.values.toList();

    // Jobs posted by this user (deduplicated by id)
    final jobsVM = Provider.of<JobsViewModel>(context);
    final Map<String, JobModel> uniqueJobs = {};
    for (final j in [
      ...jobsVM.publicJobs,
      ...jobsVM.userJobs,
    ]) {
      final matchesOwner = owner.id.isNotEmpty && j.employerId == owner.id;
      final matchesCurrentUser =
          isCurrentUser && j.employerId == currentUserId;
      if (matchesOwner || matchesCurrentUser) {
        final key = j.id.isNotEmpty ? j.id : '${j.title}_${j.companyName}';
        uniqueJobs[key] = j;
      }
    }
    final List<JobModel> liveUserJobs = uniqueJobs.values.toList();

    // Community Posts posted by this user (deduplicated by id)
    final communityVM = Provider.of<CommunityViewModel>(context);
    final Map<String, CommunityPostModel> uniquePosts = {};
    if (hasUserDetails) {
      for (final post in communityVM.posts) {
        final matchesOwner = owner.id.isNotEmpty &&
            (post.authorId == owner.id || post.author?.id == owner.id);
        final matchesCurrentUser = isCurrentUser &&
            (post.authorId == currentUserId ||
                post.author?.id == currentUserId);
        if (matchesOwner || matchesCurrentUser) {
          final key = post.id.isNotEmpty ? post.id : post.content;
          uniquePosts[key] = post;
        }
      }
    }
    final List<CommunityPostModel> liveUserPosts = uniquePosts.values.toList();

    // Dynamically resolve actual user-entered location
    final String displayLocation = _resolveUserLocation(
      hasUserDetails: hasUserDetails,
      isCurrentUser: isCurrentUser,
      currentUser: authVM.currentUser,
      userProfile: userProfile,
      liveUserRooms: liveUserRooms,
      liveUserJobs: liveUserJobs,
      liveUserProducts: liveUserProducts,
    );

    // Stats counts
    final String jobsCountStr = hasUserDetails
        ? liveUserJobs.length.toString()
        : '0';
    final int totalLiveAds = liveUserRooms.length + liveUserProducts.length;
    final String adsCountStr = hasUserDetails ? totalLiveAds.toString() : '0';
    final String postsCountStr = hasUserDetails
        ? liveUserPosts.length.toString()
        : '0';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Top Cover Banner and Overlapping Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: bannerHeight,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: bannerHeight,
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                    // Back Button (Top Left)
                    Positioned(
                      left: context.scale(16).clamp(12.0, 20.0),
                      top: MediaQuery.of(context).padding.top + 10,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.arrowBackBasicSvg,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            height: headerIconSize,
                            width: headerIconSize,
                          ),
                        ),
                      ),
                    ),
                    // 3-Dots Button (Top Right)
                    if (!isCurrentUser && targetUserId.isNotEmpty)
                      Positioned(
                        right: context.scale(16).clamp(12.0, 20.0),
                        top: MediaQuery.of(context).padding.top + 10,
                        child: Consumer<ModerationViewModel>(
                          builder: (context, modVm, _) {
                            final isBlocked = modVm.isUserBlocked(targetUserId);
                            return Theme(
                              data: Theme.of(context).copyWith(
                                popupMenuTheme: const PopupMenuThemeData(
                                  color: Colors.white,
                                  surfaceTintColor: Colors.transparent,
                                ),
                              ),
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    AppIcons.moreVerticalSvg,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.white,
                                      BlendMode.srcIn,
                                    ),
                                    height: headerIconSize,
                                    width: headerIconSize,
                                  ),
                                ),
                                onSelected: (value) async {
                                  if (value == 'report') {
                                    ReportBottomSheet.show(
                                      context,
                                      targetType: ReportTargetType.user,
                                      targetId: targetUserId,
                                      targetTitle: 'Report $displayName',
                                      targetOwnerId: targetUserId,
                                    );
                                  } else if (value == 'block') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        title: Text('Block $displayName?'),
                                        content: const Text(
                                          "They won't be able to message you, view your profile, or see your posts and comments. You will not see their content either.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel', style: TextStyle(color: AppColors.slate600)),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryRed,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Block', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && context.mounted) {
                                      final success = await modVm.blockUser(targetUserId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success ? '$displayName has been blocked.' : (modVm.errorMessage ?? 'Failed to block user.'),
                                            ),
                                            backgroundColor: success ? AppColors.slate900 : AppColors.primaryRed,
                                          ),
                                        );
                                      }
                                    }
                                  } else if (value == 'unblock') {
                                    final success = await modVm.unblockUser(targetUserId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success ? '$displayName has been unblocked.' : (modVm.errorMessage ?? 'Failed to unblock user.'),
                                          ),
                                          backgroundColor: success ? AppColors.slate900 : AppColors.primaryRed,
                                        ),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem<String>(
                                    value: 'report',
                                    child: Row(
                                      children: [
                                        Icon(Icons.flag_outlined, size: 20, color: AppColors.primaryRed),
                                        SizedBox(width: 10),
                                        Text('Report User', style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: isBlocked ? 'unblock' : 'block',
                                    child: Row(
                                      children: [
                                        Icon(
                                          isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                                          size: 20,
                                          color: AppColors.slate700,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          isBlocked ? 'Unblock User' : 'Block User',
                                          style: const TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    // Overlapping Avatar
                    Positioned(
                      bottom: -(avatarSize / 2),
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF1F5F9),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image:
                                (hasUserDetails &&
                                    avatarUrl != null &&
                                    avatarUrl.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(avatarUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              (!hasUserDetails ||
                                  avatarUrl == null ||
                                  avatarUrl.isEmpty)
                              ? Center(
                                  child: SvgPicture.asset(
                                    AppIcons.personSvg,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.slate400,
                                      BlendMode.srcIn,
                                    ),
                                    height: (avatarSize * 0.46).clamp(
                                      36.0,
                                      52.0,
                                    ),
                                    width: (avatarSize * 0.46).clamp(
                                      36.0,
                                      52.0,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),

                // Spacing for overlapped avatar
                SizedBox(height: (avatarSize / 2) + context.scaleH(12)),

                // 2. User Info Block
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.hMargin),
                  child: Column(
                    children: [
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.sp(context.isSmall ? 19 : 22),
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      SizedBox(height: context.scaleH(3)),
                      Text(
                        displaySubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.sp(context.isSmall ? 12 : 13),
                          color: AppColors.slate600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: context.scaleH(6)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.locationSvg,
                            height: infoIconSize,
                            width: infoIconSize,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate500,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              displayLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.sp(context.isSmall ? 12 : 13),
                                color: AppColors.slate600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scaleH(6)),

                      if (hasUserDetails) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.starFavoriteSvg,
                              height: infoIconSize,
                              width: infoIconSize,
                              colorFilter: const ColorFilter.mode(
                                AppColors.amber500,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: context.sp(context.isSmall ? 12 : 13),
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '(15 Reviews)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: context.sp(
                                    context.isSmall ? 11 : 12,
                                  ),
                                  color: AppColors.slate500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.scaleH(10)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scale(14).clamp(10.0, 16.0),
                            vertical: context.scaleH(5).clamp(4.0, 7.0),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Verified Member',
                            style: TextStyle(
                              color: const Color(0xFF2563EB),
                              fontSize: context.sp(context.isSmall ? 10 : 11),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scale(14).clamp(10.0, 16.0),
                            vertical: context.scaleH(5).clamp(4.0, 7.0),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'No History found',
                            style: TextStyle(
                              color: AppColors.slate500,
                              fontSize: context.sp(context.isSmall ? 10 : 11),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: context.scaleH(20)),

                // 3. Stats Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.hMargin),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatColumn(
                          context,
                          jobsCountStr,
                          'Jobs Posted',
                        ),
                      ),
                      _buildStatDivider(context),
                      Expanded(
                        child: _buildStatColumn(
                          context,
                          adsCountStr,
                          'Ads Posted',
                        ),
                      ),
                      _buildStatDivider(context),
                      Expanded(
                        child: _buildStatColumn(
                          context,
                          postsCountStr,
                          'Community Posts',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.scaleH(20)),

                // 4. Tab Bar (Overview, Jobs, Ads, Posts, Reviews)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.slate200, width: 1),
                    ),
                  ),
                  child: Row(
                    children: _tabs
                        .map(
                          (tab) => Expanded(
                            child: _buildTabItem(
                              context,
                              authVM,
                              tab,
                              activeTab,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                // 5. Dynamic Tab View Content
                Padding(
                  padding: EdgeInsets.all(context.hMargin),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (context.scaleH(250.0)).clamp(220.0, 280.0),
                    ),
                    child: _buildActiveTabContent(
                      context,
                      authVM,
                      activeTab,
                      likedPostIds,
                      hasUserDetails: hasUserDetails,
                      displayName: displayName,
                      memberSince: memberSince,
                      userProfile: userProfile,
                      liveUserJobs: liveUserJobs,
                      liveUserRooms: liveUserRooms,
                      liveUserProducts: liveUserProducts,
                      liveUserPosts: liveUserPosts,
                    ),
                  ),
                ),

                // Bottom spacer
                SizedBox(height: context.scaleH(20)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(
        context,
        hasUserDetails,
        displayName,
        userProfile,
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String val, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.sp(context.isSmall ? 16 : 18),
            fontWeight: FontWeight.w800,
            color: AppColors.slate900,
          ),
        ),
        SizedBox(height: context.scaleH(3)),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: context.sp(context.isSmall ? 11 : 12),
            color: AppColors.slate500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      height: context.scaleH(28).clamp(24.0, 32.0),
      width: 1,
      color: AppColors.slate200,
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    AuthViewModel authVM,
    String title,
    String activeTab,
  ) {
    final isSelected = activeTab == title;
    return GestureDetector(
      onTap: () => authVM.setPublicProfileActiveTab(title),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.scale(2).clamp(2.0, 6.0),
          vertical: context.scaleH(12).clamp(10.0, 14.0),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2563EB) : AppColors.slate500,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: context.sp(context.isSmall ? 12 : 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoHistoryFound(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final double iconSize = context.scale(28).clamp(24.0, 36.0);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: (context.scaleH(250.0)).clamp(220.0, 280.0),
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.scaleH(28).clamp(20.0, 36.0),
        horizontal: context.scale(20).clamp(16.0, 24.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(context.scale(14).clamp(12.0, 18.0)),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppIcons.history,
              height: iconSize,
              width: iconSize,
              colorFilter: const ColorFilter.mode(
                AppColors.slate500,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: context.sp(16),
              fontWeight: FontWeight.bold,
              color: AppColors.slate800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(13),
              color: AppColors.slate500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(
    BuildContext context,
    AuthViewModel authVM,
    String activeTab,
    Set<String> likedPostIds, {
    required bool hasUserDetails,
    required String displayName,
    required String memberSince,
    required UserModel? userProfile,
    required List<JobModel> liveUserJobs,
    required List<PropertyModel> liveUserRooms,
    required List<MarketplaceItemModel> liveUserProducts,
    required List<CommunityPostModel> liveUserPosts,
  }) {
    if (!hasUserDetails) {
      return _buildNoHistoryFound(
        context,
        title: 'No History found',
        subtitle:
            'User details and posting history are not available for this account.',
      );
    }

    switch (activeTab) {
      case 'Overview':
        return _buildOverviewTab(context, displayName, memberSince);
      case 'Jobs':
        return _buildJobsTab(context, liveUserJobs, displayName);
      case 'Ads':
        return _buildAdsTab(
          context,
          liveUserRooms,
          liveUserProducts,
          displayName,
        );
      case 'Posts':
        return _buildPostsTab(
          context,
          authVM,
          likedPostIds,
          liveUserPosts,
          displayName,
          userProfile,
        );
      case 'Reviews':
        return _buildReviewsTab(context, displayName);
      default:
        return _buildOverviewTab(context, displayName, memberSince);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TAB 1: OVERVIEW
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildOverviewTab(
    BuildContext context,
    String displayName,
    String memberSince,
  ) {
    final bio =
        owner.coverLetter != null && owner.coverLetter!.trim().isNotEmpty
        ? owner.coverLetter!
        : 'Member of Desi Connect community.';

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: (context.scaleH(250.0)).clamp(220.0, 280.0),
      ),
      padding: EdgeInsets.all(context.cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Section
          Text(
            'About $displayName',
            style: TextStyle(
              fontSize: context.sp(16),
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          SizedBox(height: context.scaleH(8)),
          Text(
            bio,
            style: TextStyle(
              fontSize: context.sp(13),
              height: 1.5,
              color: AppColors.slate600,
            ),
          ),
          SizedBox(height: context.scaleH(20)),

          // Languages Section
          Text(
            'Languages',
            style: TextStyle(
              fontSize: context.sp(14),
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          SizedBox(height: context.scaleH(10)),
          Wrap(
            spacing: context.scale(8),
            runSpacing: context.scaleH(8),
            children: [
              _buildLanguagePill(context, 'Urdu'),
              _buildLanguagePill(context, 'Hindi'),
              _buildLanguagePill(context, 'English'),
              _buildLanguagePill(context, 'Español'),
            ],
          ),
          SizedBox(height: context.scaleH(20)),

          // Member Since Section
          Text(
            'Member since',
            style: TextStyle(
              fontSize: context.sp(14),
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          SizedBox(height: context.scaleH(8)),
          Row(
            children: [
              SvgPicture.asset(
                AppIcons.calendarSvg,
                height: context.scale(15).clamp(13.0, 17.0),
                width: context.scale(15).clamp(13.0, 17.0),
                colorFilter: const ColorFilter.mode(
                  AppColors.slate500,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: context.scale(6)),
              Flexible(
                child: Text(
                  memberSince,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.sp(13),
                    color: AppColors.slate600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePill(BuildContext context, String lang) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scale(14),
        vertical: context.scaleH(6),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        lang,
        style: TextStyle(
          fontSize: context.sp(12),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TAB 2: JOBS POSTED
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildJobsTab(
    BuildContext context,
    List<JobModel> liveUserJobs,
    String displayName,
  ) {
    if (liveUserJobs.isNotEmpty) {
      return Column(
        children: liveUserJobs
            .map((job) => _buildLiveJobCard(context, job))
            .toList(),
      );
    }

    return _buildNoHistoryFound(
      context,
      title: 'No History found',
      subtitle: '$displayName has not published any jobs yet.',
    );
  }

  Widget _buildLiveJobCard(BuildContext context, JobModel job) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.jobDetail, arguments: job);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.companyName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              job.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SvgPicture.asset(
                  AppIcons.locationSvg,
                  height: context.scale(14).clamp(12.0, 16.0),
                  width: context.scale(14).clamp(12.0, 16.0),
                  colorFilter: const ColorFilter.mode(
                    AppColors.slate500,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slate600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.salary.isNotEmpty ? '€${job.salary}/mo' : '€1,800/mo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.type.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TAB 3: ADS POSTED (Rooms + Marketplace Product Ads)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildAdsTab(
    BuildContext context,
    List<PropertyModel> userRooms,
    List<MarketplaceItemModel> userProducts,
    String displayName,
  ) {
    if (userRooms.isNotEmpty || userProducts.isNotEmpty) {
      return Column(
        children: [
          ...userRooms.map((room) => _buildLivePropertyAdCard(context, room)),
          ...userProducts.map((prod) => _buildLiveProductAdCard(context, prod)),
        ],
      );
    }

    return _buildNoHistoryFound(
      context,
      title: 'No History found',
      subtitle:
          '$displayName has not published any property or marketplace ads yet.',
    );
  }

  Widget _buildLivePropertyAdCard(BuildContext context, PropertyModel room) {
    final photoUrl = room.propertyPhotos.isNotEmpty
        ? room.propertyPhotos.first.url
        : 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.roomSingleDetails,
          arguments: room,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                ImageUtils.getThumbnailUrl(photoUrl),
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.network(
                  photoUrl,
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 85,
                    height: 85,
                    color: AppColors.slate100,
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.error_imageSvg,
                        height: context.scale(22).clamp(18.0, 26.0),
                        width: context.scale(22).clamp(18.0, 26.0),
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate500,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            room.type.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationSvg,
                        height: context.scale(13).clamp(11.0, 15.0),
                        width: context.scale(13).clamp(11.0, 15.0),
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate500,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          room.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.slate500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '€${room.monthlyRent}/mo',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveProductAdCard(
    BuildContext context,
    MarketplaceItemModel prod,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.marketplaceDetail,
          arguments: prod,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                ImageUtils.getThumbnailUrl(prod.imageUrl),
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.network(
                  prod.imageUrl,
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 85,
                    height: 85,
                    color: AppColors.slate100,
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.error_imageSvg,
                        height: context.scale(22).clamp(18.0, 26.0),
                        width: context.scale(22).clamp(18.0, 26.0),
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate500,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            prod.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prod.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationSvg,
                        height: context.scale(13).clamp(11.0, 15.0),
                        width: context.scale(13).clamp(11.0, 15.0),
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate500,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          prod.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.slate500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prod.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TAB 4: COMMUNITY POSTS
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPostsTab(
    BuildContext context,
    AuthViewModel authVM,
    Set<String> likedPostIds,
    List<CommunityPostModel> liveUserPosts,
    String displayName,
    UserModel? userProfile,
  ) {
    if (liveUserPosts.isNotEmpty) {
      return Column(
        children: liveUserPosts
            .map(
              (post) => _buildLiveCommunityPostCard(
                context,
                authVM,
                likedPostIds,
                post,
                displayName,
                userProfile,
              ),
            )
            .toList(),
      );
    }

    return _buildNoHistoryFound(
      context,
      title: 'No History found',
      subtitle: '$displayName has not shared any community posts yet.',
    );
  }

  Widget _buildLiveCommunityPostCard(
    BuildContext context,
    AuthViewModel authVM,
    Set<String> likedPostIds,
    CommunityPostModel post,
    String displayName,
    UserModel? userProfile,
  ) {
    final authorPhoto = _resolveImageUrl(
      post.author?.profilePhotoUrl ??
          userProfile?.profilePhotoUrl ??
          owner.profilePhotoUrl,
    );

    final isLiked = likedPostIds.contains(post.id) || post.isLiked;
    final int likesDisplay =
        post.likesCount + (likedPostIds.contains(post.id) ? 1 : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.slate100,
                backgroundImage: authorPhoto.isNotEmpty
                    ? NetworkImage(authorPhoto)
                    : null,
                child: authorPhoto.isEmpty
                    ? Center(
                        child: SvgPicture.asset(
                          AppIcons.personSvg,
                          height: context.scale(18).clamp(15.0, 20.0),
                          width: context.scale(18).clamp(15.0, 20.0),
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate500,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    post.tag.startsWith('#') ? post.tag : '#${post.tag}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.slate800,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.slate200),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  authVM.togglePublicProfilePostLike(post.id);
                  Provider.of<CommunityViewModel>(
                    context,
                    listen: false,
                  ).toggleLike(post.id);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.favSvg,
                      height: context.scale(16).clamp(14.0, 19.0),
                      width: context.scale(16).clamp(14.0, 19.0),
                      colorFilter: ColorFilter.mode(
                        isLiked ? AppColors.primaryRed : AppColors.slate400,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likesDisplay Likes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isLiked
                            ? AppColors.primaryRed
                            : AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.chatRoundSvg,
                    height: context.scale(16).clamp(14.0, 19.0),
                    width: context.scale(16).clamp(14.0, 19.0),
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate500,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentsCount} Comments',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TAB 5: REVIEWS
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildReviewsTab(BuildContext context, String displayName) {
    return _buildNoHistoryFound(
      context,
      title: 'No History found',
      subtitle: 'No customer reviews recorded for $displayName yet.',
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FIXED BOTTOM ACTION BAR (Chat, Call)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildBottomActionBar(
    BuildContext context,
    bool hasUserDetails,
    String displayName,
    UserModel? userProfile,
  ) {
    final double maxContentWidth = context.isTablet ? 720.0 : 640.0;
    final double actionIconSize = context.scale(16).clamp(14.0, 18.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.slate200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(16).clamp(12.0, 20.0),
                vertical: context.scaleH(12).clamp(10.0, 14.0),
              ),
              child: Row(
                children: [
                  // 1. Chat Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(
                        context,
                        hasUserDetails,
                        displayName,
                        userProfile,
                      ),
                      icon: SvgPicture.asset(
                        AppIcons.chatRoundSvg,
                        height: actionIconSize,
                        width: actionIconSize,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: context.sp(context.isSmall ? 13 : 14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          vertical: context.scaleH(12).clamp(10.0, 14.0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.isSmall ? 8 : 12),

                  // 2. Call Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _makeCall(context, hasUserDetails, userProfile),
                      icon: SvgPicture.asset(
                        AppIcons.callSvg,
                        height: actionIconSize,
                        width: actionIconSize,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate900,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Call',
                          style: TextStyle(
                            fontSize: context.sp(context.isSmall ? 13 : 14),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: AppColors.slate300,
                          width: 1.5,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: context.scaleH(12).clamp(10.0, 14.0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
}
