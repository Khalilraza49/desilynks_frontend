import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/app/theme.dart';
import 'package:desilynks/models/job_enums.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/models/need_worker_model.dart';
import 'package:desilynks/models/need_worker_enums.dart';
import 'package:desilynks/models/marketplace_item_model.dart';
import 'package:desilynks/models/business_listing_model.dart';
import 'package:desilynks/models/event_model.dart';
import 'package:desilynks/services/api/api_endpoints.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';
import 'package:desilynks/viewmodels/jobs/jobs_viewmodel.dart';
import 'package:desilynks/viewmodels/profile/my_ads_viewmodel.dart';
import 'package:desilynks/viewmodels/create_post/need_worker_viewmodel.dart';
import 'package:desilynks/viewmodels/marketplace/marketplace_viewmodel.dart';
import 'package:desilynks/viewmodels/business_listing_viewmodel.dart';
import 'package:desilynks/viewmodels/events/events_viewmodel.dart';
import 'package:desilynks/views/marketplace/marketplace_item_detail_view.dart';
import 'package:desilynks/views/create_post/product/post_product_view.dart';
import 'package:desilynks/views/create_post/jobs/post_job_view.dart';
import 'package:desilynks/views/chat/chat_view.dart';
import 'package:desilynks/views/chat/chat_detail_view.dart';
import 'package:desilynks/models/chat_model.dart';
import 'package:desilynks/viewmodels/chat/chat_viewmodel.dart';
import 'package:desilynks/widgets/coming_soon_dialog.dart';
import 'package:desilynks/core/utils/image_utils.dart';

/// Unified wrapper model for displaying Room Ads, Marketplace Ads, Need Worker Posts & Event Posts in My Ads screen
class MyAdItem {
  final PropertyModel? property;
  final JobModel? job;
  final NeedWorkerModel? needWorker;
  final MarketplaceItemModel? product;
  final BusinessListingModel? business;
  final EventModel? event;
  final DateTime createdAt;

  MyAdItem.property(this.property)
    : job = null,
      needWorker = null,
      product = null,
      business = null,
      event = null,
      createdAt = property!.createdAt;

  MyAdItem.job(this.job)
    : property = null,
      needWorker = null,
      product = null,
      business = null,
      event = null,
      createdAt = job!.createdAt;

  MyAdItem.needWorker(this.needWorker)
    : property = null,
      job = null,
      product = null,
      business = null,
      event = null,
      createdAt = needWorker!.createdAt;

  MyAdItem.product(this.product)
    : property = null,
      job = null,
      needWorker = null,
      business = null,
      event = null,
      createdAt = product!.createdAt;

  MyAdItem.business(this.business)
    : property = null,
      job = null,
      needWorker = null,
      product = null,
      event = null,
      createdAt = business!.createdAt;

  MyAdItem.event(this.event)
    : property = null,
      job = null,
      needWorker = null,
      product = null,
      business = null,
      createdAt = event!.date;

  bool get isProperty => property != null;
  bool get isJob => job != null;
  bool get isNeedWorker => needWorker != null;
  bool get isProduct => product != null;
  bool get isBusiness => business != null;
  bool get isEvent => event != null;

  String get categoryType {
    if (isProperty) return 'Room';
    if (isProduct) return 'Marketplace';
    if (isNeedWorker) return 'Worker';
    if (isEvent) return 'Event';
    if (isJob) return 'Job';
    if (isBusiness) return 'Local Business';
    return 'Ad';
  }

  String get status {
    if (isProperty && property != null) {
      final s = property!.status.toUpperCase();
      if (s == 'PUBLISHED' || s == 'ACTIVE') return 'Active';
      if (s == 'DRAFT' || s == 'PENDING') return 'Pending';
      if (s == 'RENTED') return 'Rented';
      return 'Inactive';
    } else if (isJob && job != null) {
      final s = job!.status;
      if (s == JobStatus.open) return 'Active';
      return 'Inactive';
    } else if (isProduct && product != null) {
      final s = product!.status.toUpperCase();
      if (s == 'ACTIVE' || s == 'PUBLISHED') return 'Active';
      if (s == 'PENDING' || s == 'DRAFT') return 'Pending';
      if (s == 'SOLD' || s == 'INACTIVE' || s == 'ARCHIVED') return 'Inactive';
      return 'Active';
    } else if (isNeedWorker && needWorker != null) {
      final s = needWorker!.status.toUpperCase();
      if (s == 'ACTIVE' || s == 'PUBLISHED' || s == 'OPEN') return 'Active';
      if (s == 'PENDING' || s == 'DRAFT') return 'Pending';
      if (s == 'COMPLETED' || s == 'CLOSED' || s == 'INACTIVE') {
        return 'Inactive';
      }
      return 'Active';
    } else if (isEvent && event != null) {
      // Event status: Active if upcoming/today, Inactive if past
      if (event!.date.isBefore(
        DateTime.now().subtract(const Duration(days: 1)),
      )) {
        return 'Inactive';
      }
      return 'Active';
    } else if (isBusiness && business != null) {
      final s = business!.status.toUpperCase();
      if (s == 'ACTIVE' || s == 'PUBLISHED') return 'Active';
      if (s == 'PENDING' || s == 'DRAFT') return 'Pending';
      return 'Inactive';
    } else {
      return 'Active';
    }
  }
}

class MyAdsView extends StatefulWidget {
  final String? title;

  const MyAdsView({super.key, this.title});

  @override
  State<MyAdsView> createState() => _MyAdsViewState();
}

class _MyAdsViewState extends State<MyAdsView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData(force: true);
      }
    });
  }

  Future<void> _loadData({bool force = false}) async {
    final adsViewModel = Provider.of<MyAdsViewModel>(context, listen: false);
    final needWorkerViewModel = Provider.of<NeedWorkerViewModel>(
      context,
      listen: false,
    );
    final marketplaceViewModel = Provider.of<MarketplaceViewModel>(
      context,
      listen: false,
    );
    final eventsViewModel = Provider.of<EventsViewModel>(
      context,
      listen: false,
    );
    final jobsViewModel = Provider.of<JobsViewModel>(context, listen: false);
    final businessViewModel = Provider.of<BusinessListingViewModel>(
      context,
      listen: false,
    );

    final List<Future> futures = [];
    if (!adsViewModel.hasFetched || force) {
      futures.add(adsViewModel.fetchUserAds(force: force).catchError((e) {
        debugPrint('Error fetching user ads: $e');
      }));
    }
    if (!needWorkerViewModel.hasFetchedMyPosts || force) {
      futures.add(needWorkerViewModel.fetchMyPosts(force: force).catchError((e) {
        debugPrint('Error fetching worker posts: $e');
      }));
    }
    if (!marketplaceViewModel.hasFetchedMyAds || force) {
      futures.add(marketplaceViewModel.fetchMyAds(force: force).catchError((e) {
        debugPrint('Error fetching marketplace ads: $e');
      }));
    }
    if (!eventsViewModel.hasFetchedMyEvents || force) {
      futures.add(eventsViewModel.fetchMyEvents(force: force).catchError((e) {
        debugPrint('Error fetching events: $e');
      }));
    }
    if (!jobsViewModel.hasFetchedUserJobs || force) {
      futures.add(jobsViewModel.fetchUserJobs(force: force).catchError((e) {
        debugPrint('Error fetching jobs: $e');
      }));
    }
    if (!businessViewModel.hasFetched || force) {
      futures.add(businessViewModel.fetchMyListings(force: force).catchError((e) {
        debugPrint('Error fetching business listings: $e');
      }));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  String _formatDate(DateTime dt) {
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
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final adsViewModel = Provider.of<MyAdsViewModel>(context);
    final jobsViewModel = Provider.of<JobsViewModel>(context);
    final needWorkerViewModel = Provider.of<NeedWorkerViewModel>(context);
    final marketplaceViewModel = Provider.of<MarketplaceViewModel>(context);
    final businessViewModel = Provider.of<BusinessListingViewModel>(context);
    final eventsViewModel = Provider.of<EventsViewModel>(context);

    // Core post ads: Room, Marketplace, Need a worker, Event Post
    final List<MyAdItem> allItems = [
      ...adsViewModel.userAds.map((p) => MyAdItem.property(p)),
      ...marketplaceViewModel.myAds.map((m) => MyAdItem.product(m)),
      ...needWorkerViewModel.myPosts.map((w) => MyAdItem.needWorker(w)),
      ...eventsViewModel.myEvents.map((e) => MyAdItem.event(e)),
    ];

    // Sort combined list by creation date descending (newest first)
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Filter by selected status tab (All, Active, Pending, Rented, Inactive)
    final filteredItems = allItems.where((item) {
      if (adsViewModel.selectedTab == 'Active') return item.status == 'Active';
      if (adsViewModel.selectedTab == 'Pending') {
        return item.status == 'Pending';
      }
      if (adsViewModel.selectedTab == 'Rented') return item.status == 'Rented';
      if (adsViewModel.selectedTab == 'Inactive') {
        return item.status == 'Inactive';
      }
      return true;
    }).toList();

    final bool isLoading =
        adsViewModel.isLoading ||
        needWorkerViewModel.isMyPostsLoading ||
        marketplaceViewModel.isMyAdsLoading ||
        eventsViewModel.isLoadingMyEvents;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: context.scale(40),
        leading: IconButton(
          padding: EdgeInsets.only(left: context.scale(12)),
          icon: SvgPicture.asset(
            AppIcons.arrowBackSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate800,
              BlendMode.srcIn,
            ),
            width: context.scale(22),
            height: context.scale(22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: context.scale(8),
        title: Text(
          widget.title ?? 'My Posts',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: context.sp(20),
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
          ),
        ),
        centerTitle: false,
        actions: [
          // My Applications button
          Padding(
            padding: EdgeInsets.only(right: context.scale(8)),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.myApplications);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(10),
                  vertical: context.scale(6),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.sendSvg,
                      width: context.scale(13),
                      height: context.scale(13),
                      colorFilter: const ColorFilter.mode(
                        AppColors.vibrantBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: context.scale(4)),
                    Text(
                      'Applications',
                      style: TextStyle(
                        fontSize: context.sp(11.5),
                        fontWeight: FontWeight.w700,
                        color: AppColors.vibrantBlue,
                        fontFamily: "Inter",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: context.scale(16)),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.createPost).then((_) {
                  if (mounted) _loadData(force: true);
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: context.scale(36),
                height: context.scale(36),
                decoration: const BoxDecoration(
                  color: AppColors.vibrantBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.plusSvg,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: context.scale(20),
                    height: context.scale(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Filter Pills (All, Active, Pending, Rented, Inactive)
              _buildStatusFilterPills(context, adsViewModel, allItems),

              // Unified List of Ads (Room + Marketplace + Need a Worker + Event Posts)
              Expanded(
                child: isLoading && allItems.isEmpty
                    ? const ListSkeleton(showTabs: false)
                    : filteredItems.isEmpty
                    ? _buildEmptyState(
                        'No posts found in ${adsViewModel.selectedTab}.',
                      )
                    : RefreshIndicator(
                        backgroundColor: AppColors.backgroundOffWhite,
                        color: AppColors.vibrantBlue,
                        onRefresh: () async {
                          await Future.wait([
                            adsViewModel.fetchUserAds(force: true),
                            needWorkerViewModel.fetchMyPosts(force: true),
                            marketplaceViewModel.fetchMyAds(force: true),
                            eventsViewModel.fetchMyEvents(force: true),
                          ]);
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.all(context.hMargin),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return _buildUnifiedAdCard(
                              context,
                              filteredItems[index],
                              adsViewModel,
                              jobsViewModel,
                              marketplaceViewModel,
                              businessViewModel,
                              eventsViewModel,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Status Filter Pills (All, Active, Pending, Rented, Inactive)
  Widget _buildStatusFilterPills(
    BuildContext context,
    MyAdsViewModel adsViewModel,
    List<MyAdItem> items,
  ) {
    final int allCount = items.length;
    final int activeCount = items.where((i) => i.status == 'Active').length;
    final int pendingCount = items.where((i) => i.status == 'Pending').length;
    final int rentedCount = items.where((i) => i.status == 'Rented').length;
    final int inactiveCount = items.where((i) => i.status == 'Inactive').length;

    final tabs = [
      {'label': 'All', 'count': allCount},
      {'label': 'Active', 'count': activeCount},
      {'label': 'Pending', 'count': pendingCount},
      {'label': 'Rented', 'count': rentedCount},
      {'label': 'Inactive', 'count': inactiveCount},
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: context.scaleH(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.hMargin),
        child: Row(
          children: tabs.map((tab) {
            final String label = tab['label'] as String;
            final int count = tab['count'] as int;
            final String tabText = '$label ($count)';
            final bool isActive = adsViewModel.selectedTab == label;

            return Padding(
              padding: EdgeInsets.only(right: context.scale(8)),
              child: InkWell(
                onTap: () => adsViewModel.setSelectedTab(label),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scale(16),
                    vertical: context.scaleH(7),
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.vibrantBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isActive
                        ? null
                        : Border.all(color: AppColors.slate200, width: 1.0),
                  ),
                  child: Text(
                    tabText,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.slate600,
                      fontSize: context.sp(13),
                      fontFamily: "Inter",
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Unified Ad Card for Room, Marketplace, Need a Worker & Event Posts
  Widget _buildUnifiedAdCard(
    BuildContext context,
    MyAdItem item,
    MyAdsViewModel adsViewModel,
    JobsViewModel jobsViewModel,
    MarketplaceViewModel marketplaceViewModel,
    BusinessListingViewModel businessViewModel,
    EventsViewModel eventsViewModel,
  ) {
    final bool isProperty = item.isProperty && item.property != null;
    final bool isJob = item.isJob && item.job != null;
    final bool isNeedWorker = item.isNeedWorker && item.needWorker != null;
    final bool isProduct = item.isProduct && item.product != null;
    final bool isBusiness = item.isBusiness && item.business != null;
    final bool isEvent = item.isEvent && item.event != null;
    final PropertyModel? ad = item.property;
    final JobModel? job = item.job;
    final NeedWorkerModel? nw = item.needWorker;
    final MarketplaceItemModel? prod = item.product;
    final BusinessListingModel? biz = item.business;
    final EventModel? evt = item.event;

    final String title = isProperty && ad != null
        ? ad.title
        : (isNeedWorker && nw != null
              ? 'Worker: ${WorkerTypeX.fromString(nw.workerType).displayName}'
              : (isProduct && prod != null
                    ? prod.title
                    : (isEvent && evt != null
                          ? evt.title
                          : (isJob && job != null
                                ? job.title
                                : (isBusiness && biz != null
                                      ? biz.name
                                      : 'Post')))));

    final String price = isProperty && ad != null
        ? (double.tryParse(ad.monthlyRent) != null &&
                  double.parse(ad.monthlyRent) > 0
              ? "€${double.parse(ad.monthlyRent).toStringAsFixed(0)} /month"
              : "€${ad.monthlyRent}")
        : (isNeedWorker && nw != null
              ? "€${nw.budget} (${BudgetTypeX.fromString(nw.budgetType).displayName})"
              : (isProduct && prod != null
                    ? prod.price
                    : (isEvent && evt != null
                          ? evt.price
                          : (isJob && job != null
                                ? "€${job.salary}/${job.salaryPeriod.displayName.toLowerCase().replaceAll('per ', '')}"
                                : (isBusiness && biz != null
                                      ? biz.category
                                      : '')))));
    final String dateStr = _formatDate(item.createdAt);

    String statusText = item.status;
    Color statusBgColor = const Color(0xFFD1FAE5); // Light green pill
    Color statusTextColor = const Color(0xFF059669); // Emerald text

    if (statusText == 'Pending') {
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
    } else if (statusText == 'Rented') {
      statusBgColor = const Color(0xFFFFFBEB);
      statusTextColor = const Color(0xFFD97706);
    } else if (statusText == 'Inactive') {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
    }

    // Image URL or Fallback Icon
    String? imageUrl;
    if (isProperty && ad != null && ad.propertyPhotos.isNotEmpty) {
      imageUrl = ad.propertyPhotos.first.url;
    } else if (isNeedWorker && nw != null && nw.referencePhotos.isNotEmpty) {
      imageUrl = nw.referencePhotos.first.url;
    } else if (isProduct && prod != null && prod.imageUrl.isNotEmpty) {
      imageUrl = prod.imageUrl;
    } else if (isEvent && evt != null && evt.imageUrl.isNotEmpty) {
      imageUrl = evt.imageUrl;
    } else if (isBusiness && biz != null) {
      if (biz.coverPhoto != null && biz.coverPhoto!.url.isNotEmpty) {
        imageUrl = biz.coverPhoto!.url;
      } else if (biz.logo != null && biz.logo!.url.isNotEmpty) {
        imageUrl = biz.logo!.url;
      } else if (biz.businessGalleries.isNotEmpty) {
        imageUrl = biz.businessGalleries.first.url;
      }
    }
    if (imageUrl != null && imageUrl.startsWith('/')) {
      imageUrl = '${ApiEndpoints.baseUrl}$imageUrl';
    }

    // Stats calculation from live API models
    final int viewsCount = isProperty && ad != null
        ? ad.viewsCount
        : (isNeedWorker && nw != null
              ? nw.viewsCount
              : (isProduct && prod != null
                    ? prod.viewsCount
                    : (isEvent && evt != null
                          ? evt.attendeesCount
                          : (isBusiness && biz != null ? biz.viewsCount : 0))));

    final int offersCount = isProduct && prod != null
        ? (prod.offersCount > 0
              ? prod.offersCount
              : marketplaceViewModel.getOfferCountForAd(prod.id))
        : (isNeedWorker && nw != null
              ? nw.applicationCount
              : (isProperty && ad != null
                    ? (ad.offersCount > 0 ? ad.offersCount : ad.likesCount)
                    : (isEvent && evt != null
                          ? evt.attendeesCount
                          : (isBusiness && biz != null ? biz.clicks : 0))));

    final int chatsCount = isProperty && ad != null
        ? ad.chatsCount
        : (isNeedWorker && nw != null
              ? nw.chatsCount
              : (isProduct && prod != null ? prod.chatsCount : 0));

    // Badge styling for post type
    final Color badgeBgColor = isProperty
        ? const Color(0xFFDCFCE7)
        : isProduct
        ? const Color(0xFFF3E8FF)
        : isNeedWorker
        ? const Color(0xFFFFEDD5)
        : isEvent
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFEFF6FF);

    final Color badgeTextColor = isProperty
        ? const Color(0xFF16A34A)
        : isProduct
        ? const Color(0xFF9333EA)
        : isNeedWorker
        ? const Color(0xFFEA580C)
        : isEvent
        ? const Color(0xFF059669)
        : const Color(0xFF2563EB);

    return Container(
      margin: EdgeInsets.only(bottom: context.scaleH(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Top Section: Image/Icon, Category Badge, Title, Price, Date & Status Chip
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () async {
              if (isProperty && ad != null) {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.roomSingleDetails,
                  arguments: ad,
                );
              } else if (isNeedWorker && nw != null) {
                await _showNeedWorkerDetailSheet(context, nw);
              } else if (isProduct && prod != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MarketplaceItemDetailView(item: prod),
                  ),
                );
              } else if (isEvent && evt != null) {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.eventDetail,
                  arguments: evt,
                );
              } else if (isJob && job != null) {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.jobDetail,
                  arguments: job,
                );
              } else if (isBusiness && biz != null) {
                await _showBusinessDetailSheet(context, biz);
              }
              if (mounted) {
                _loadData(force: true);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(context.cardPad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null
                        ? Image.network(
                            ImageUtils.getThumbnailUrl(imageUrl),
                            width: context.scale(72),
                            height: context.scale(72),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.network(
                                  imageUrl!,
                                  width: context.scale(72),
                                  height: context.scale(72),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: context.scale(72),
                                        height: context.scale(72),
                                        color: const Color(0xFFF3F4F6),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            isEvent
                                                ? AppIcons.calendarSvg
                                                : isProperty
                                                ? AppIcons.homeSvg
                                                : AppIcons.shopingSvg,
                                            colorFilter: const ColorFilter.mode(
                                              Color(0xFF9CA3AF),
                                              BlendMode.srcIn,
                                            ),
                                            width: context.scale(32),
                                            height: context.scale(32),
                                          ),
                                        ),
                                      ),
                                ),
                          )
                        : Container(
                            width: context.scale(72),
                            height: context.scale(72),
                            decoration: BoxDecoration(
                              color: isNeedWorker
                                  ? const Color(0xFFFFF7ED)
                                  : isBusiness
                                  ? const Color(0xFFFDF2F8)
                                  : isProduct
                                  ? const Color(0xFFF3E8FF)
                                  : isEvent
                                  ? const Color(0xFFECFDF5)
                                  : isProperty
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              isNeedWorker
                                  ? AppIcons.workerSvg
                                  : isBusiness
                                  ? AppIcons.shopSvg
                                  : isProduct
                                  ? AppIcons.shopingSvg
                                  : isEvent
                                  ? AppIcons.calendarSvg
                                  : isProperty
                                  ? AppIcons.homeSvg
                                  : AppIcons.briefcaseSvg,
                              colorFilter: ColorFilter.mode(
                                isNeedWorker
                                    ? const Color(0xFFF97316)
                                    : isBusiness
                                    ? const Color(0xFFEC4899)
                                    : isProduct
                                    ? const Color(0xFF9333EA)
                                    : isEvent
                                    ? const Color(0xFF059669)
                                    : isProperty
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF2563EB),
                                BlendMode.srcIn,
                              ),
                              width: context.scale(32),
                              height: context.scale(32),
                            ),
                          ),
                  ),
                  SizedBox(width: context.scale(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.categoryType.toUpperCase(),
                            style: TextStyle(
                              color: badgeTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              fontFamily: "Inter",
                            ),
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            fontFamily: "Inter",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                            fontFamily: "Inter",
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.calendarSvg,
                              width: 13,
                              height: 13,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF6B7280),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                isEvent ? "Date: $dateStr" : "Posted: $dateStr",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontFamily: "Inter",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Inter",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // 2. Middle Stats Row (Views: Black, Offers/RSVP: Red, Chats: Green)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _loadData(force: true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Text(
                            '$viewsCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF111827),
                              fontFamily: "Inter",
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppIcons.eyeSvg,
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF6B7280),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Views',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final marketplaceVM = context
                          .read<MarketplaceViewModel>();
                      if (isProduct && prod != null) {
                        await _showProductOffersSheet(context, prod, marketplaceVM);
                      } else if (isJob && job != null) {
                        await _showApplicantsSheet(context, job, jobsViewModel);
                      } else if (isNeedWorker && nw != null) {
                        await _showNeedWorkerDetailSheet(context, nw);
                      } else if (isEvent && evt != null) {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.eventDetail,
                          arguments: evt,
                        );
                      } else if (isBusiness && biz != null) {
                        await _showBusinessDetailSheet(context, biz);
                      }
                      if (mounted) {
                        _loadData(force: true);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Text(
                            '$offersCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFEF4444),
                              fontFamily: "Inter",
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                isProperty
                                    ? (ad != null && ad.offersCount > 0
                                          ? AppIcons.shopingSvg
                                          : AppIcons.favSvg)
                                    : isEvent
                                    ? AppIcons.personSvg
                                    : isBusiness
                                    ? AppIcons.analyticsSvg
                                    : (isProduct
                                          ? AppIcons.shopingSvg
                                          : AppIcons.workerSvg),
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF6B7280),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isProperty
                                    ? (ad != null && ad.offersCount > 0
                                          ? 'Offers'
                                          : 'Saved')
                                    : isEvent
                                    ? 'RSVPs'
                                    : isBusiness
                                    ? 'Clicks'
                                    : (isProduct ? 'Offers' : 'Requests'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatView()),
                      );
                      if (mounted) {
                        _loadData(force: true);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Text(
                            '$chatsCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF10B981),
                              fontFamily: "Inter",
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppIcons.chatRoundSvg,
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF6B7280),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Chats',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pending Alert Banner
          if (statusText == 'Pending')
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.TimerSvg,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFD97706),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Under review — usually takes 24 hours',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w500,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // 3. Action Buttons Row (View, Edit, Boost, Del)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildActionButton(
                  context,
                  label: 'View',
                  svgIcon: AppIcons.eyeSvg,
                  bgColor: const Color(0xFFEFF6FF),
                  textColor: const Color(0xFF2563EB),
                  onTap: () async {
                    if (isProperty && ad != null) {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.roomSingleDetails,
                        arguments: ad,
                      );
                    } else if (isNeedWorker && nw != null) {
                      await _showNeedWorkerDetailSheet(context, nw);
                    } else if (isProduct && prod != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MarketplaceItemDetailView(item: prod),
                        ),
                      );
                    } else if (isEvent && evt != null) {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.eventDetail,
                        arguments: evt,
                      );
                    } else if (isJob && job != null) {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.jobDetail,
                        arguments: job,
                      );
                    } else if (isBusiness && biz != null) {
                      await _showBusinessDetailSheet(context, biz);
                    }
                    if (mounted) {
                      _loadData(force: true);
                    }
                  },
                ),
                if (isNeedWorker && nw != null) ...[
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    label: 'Requests (${nw.applicationCount})',
                    svgIcon: AppIcons.workerSvg,
                    bgColor: const Color(0xFFFEF3C7),
                    textColor: const Color(0xFFD97706),
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.workerRequests,
                        arguments: nw,
                      );
                      if (mounted) _loadData(force: true);
                    },
                  ),
                ],
                if (isJob && job != null) ...[
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    label: 'Applicants',
                    svgIcon: AppIcons.dashboardSvg,
                    bgColor: const Color(0xFFF3E8FF),
                    textColor: const Color(0xFF7C3AED),
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.applicants,
                        arguments: job,
                      );
                      if (mounted) _loadData(force: true);
                    },
                  ),
                ],
                const SizedBox(width: 8),
                _buildActionButton(
                  context,
                  label: 'Edit',
                  svgIcon: AppIcons.editSvg,
                  bgColor: const Color(0xFFECFDF5),
                  textColor: const Color(0xFF10B981),
                  onTap: () async {
                    if (isProperty && ad != null) {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.editAd,
                        arguments: ad,
                      );
                    } else if (isNeedWorker && nw != null) {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.postNeedWorker,
                        arguments: nw,
                      );
                    } else if (isProduct && prod != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostProductView(productToEdit: prod),
                        ),
                      );
                    } else if (isEvent && evt != null) {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.postEvent,
                        arguments: evt,
                      );
                    } else if (isJob && job != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostJobView(job: job),
                        ),
                      );
                    } else if (isBusiness && biz != null) {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.editAd,
                        arguments: biz,
                      );
                    }
                    if (mounted) {
                      _loadData(force: true);
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  context,
                  label: 'Boost',
                  svgIcon: AppIcons.crownSvg,
                  bgColor: const Color(0xFFFFF7ED),
                  textColor: const Color(0xFFF97316),
                  onTap: () {
                    ComingSoonDialog.show(
                      context,
                      title: 'Coming Soon',
                      featureName: 'Ad Boost',
                      svgIcon: AppIcons.crownSvg,
                      badgeColor: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFF97316),
                      message:
                          'Ad Boost is currently under development. Soon you will be able to boost your posts to gain higher visibility and reach more people!',
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  context,
                  label: 'Del',
                  svgIcon: AppIcons.deleteSvg,
                  bgColor: const Color(0xFFFEF2F2),
                  textColor: const Color(0xFFEF4444),
                  onTap: () async {
                    final needWorkerVM = context.read<NeedWorkerViewModel>();
                    final marketplaceVM = context.read<MarketplaceViewModel>();
                    final confirm = await _showDeleteConfirmDialog(
                      context: context,
                      isProperty: isProperty,
                      itemType: isProperty
                          ? 'Room Ad'
                          : (isProduct
                                ? 'Product Ad'
                                : (isNeedWorker
                                      ? 'Need Worker Post'
                                      : (isEvent ? 'Event' : 'Post'))),
                    );

                    if (confirm == true) {
                      final bool success;
                      if (isProperty && ad != null) {
                        success = await adsViewModel.deleteAd(ad.id);
                      } else if (isNeedWorker && nw != null) {
                        success = await needWorkerVM.deletePost(nw.id);
                      } else if (isProduct && prod != null) {
                        success = await marketplaceVM.deleteProductAd(prod.id);
                      } else if (isEvent && evt != null) {
                        success = await eventsViewModel.deleteEvent(evt.id);
                      } else if (isJob && job != null) {
                        success = await jobsViewModel.deleteJob(job.id);
                      } else if (isBusiness && biz != null) {
                        success = await businessViewModel.deleteListing(biz.id);
                      } else {
                        success = false;
                      }

                      // Fetch latest data from the backend first, then the UI updates
                      if (mounted) {
                        await _loadData(force: true);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Deleted successfully!'
                                  : 'Failed to delete post',
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Soft Button Helper
  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required String svgIcon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: context.scaleH(8),
            horizontal: context.scale(2),
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  svgIcon,
                  width: context.scale(14),
                  height: context.scale(14),
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                ),
                SizedBox(width: context.scale(4)),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNeedWorkerDetailSheet(BuildContext context, NeedWorkerModel post) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      AppIcons.workerSvg,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFF97316),
                        BlendMode.srcIn,
                      ),
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need ${WorkerTypeX.fromString(post.workerType).displayName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        Text(
                          'Budget: €${post.budget} (${BudgetTypeX.fromString(post.budgetType).displayName})',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.vibrantBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Location & Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.locationSvg,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate500,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.location,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slate800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.TimerSvg,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.slate500,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.startTime} - ${post.endTime}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slate800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.slate600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Urgent Request: ${post.isUrgentRequest ? "YES" : "NO"}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Applications: ${post.applicationCount}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.vibrantBlue,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.workerRequests,
                      arguments: post,
                    );
                    if (mounted) {
                      _loadData(force: true);
                    }
                  },
                  icon: SvgPicture.asset(
                    AppIcons.workerSvg,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: 18,
                    height: 18,
                  ),
                  label: Text(
                    'View Incoming Requests (${post.applicationCount})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.postNeedWorker,
                      arguments: post,
                    );
                    if (mounted) {
                      _loadData(force: true);
                    }
                  },
                  icon: SvgPicture.asset(
                    AppIcons.editSvg,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: 18,
                    height: 18,
                  ),
                  label: const Text(
                    'Edit Request Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showBusinessDetailSheet(
    BuildContext context,
    BusinessListingModel biz,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      AppIcons.shopSvg,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFEC4899),
                        BlendMode.srcIn,
                      ),
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          biz.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        Text(
                          biz.category,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.vibrantBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (biz.address.isNotEmpty) ...[
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.locationSvg,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate500,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        biz.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.slate700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (biz.phone.isNotEmpty) ...[
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.callSvg,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate500,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        biz.phone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.slate700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (biz.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  biz.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.slate600,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.editAd,
                      arguments: biz,
                    );
                    if (mounted) {
                      _loadData(force: true);
                    }
                  },
                  icon: SvgPicture.asset(
                    AppIcons.editSvg,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: 18,
                    height: 18,
                  ),
                  label: const Text(
                    'Edit Business Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showApplicantsSheet(
    BuildContext context,
    JobModel job,
    JobsViewModel jobsViewModel,
  ) {
    jobsViewModel.fetchJobApplications(job.id);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<JobsViewModel>(
          builder: (context, vm, child) {
            final applications = vm.jobApplications;
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.slate300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Applicants for ${job.title}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Applications: ${applications.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slate500,
                    ),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : applications.isEmpty
                        ? const Center(
                            child: Text('No applications received yet.'),
                          )
                        : ListView.builder(
                            itemCount: applications.length,
                            itemBuilder: (context, index) {
                              final app = applications[index];
                              final applicant = app.applicant;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        applicant?.profilePhotoUrl != null
                                        ? NetworkImage(
                                            applicant!.profilePhotoUrl!,
                                          )
                                        : null,
                                    child: applicant?.profilePhotoUrl == null
                                        ? SvgPicture.asset(
                                            AppIcons.personSvg,
                                            width: 24,
                                            height: 24,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.slate500,
                                              BlendMode.srcIn,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    applicant?.fullName ?? 'Applicant',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (applicant?.email != null)
                                        Text(
                                          applicant!.email,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      if (app.coverLetter != null &&
                                          app.coverLetter!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            '"${app.coverLetter}"',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: AppColors.slate600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing:
                                      PopupMenuButton<JobApplicationStatus>(
                                        initialValue: app.status,
                                        onSelected: (newStatus) async {
                                          await vm.updateApplicationStatus(
                                            app.id,
                                            newStatus,
                                          );
                                        },
                                        itemBuilder: (ctx) =>
                                            JobApplicationStatus.values
                                                .map(
                                                  (s) => PopupMenuItem(
                                                    value: s,
                                                    child: Text(s.displayName),
                                                  ),
                                                )
                                                .toList(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.vibrantBlue
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            app.status.displayName,
                                            style: const TextStyle(
                                              color: AppColors.vibrantBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showProductOffersSheet(
    BuildContext context,
    MarketplaceItemModel product,
    MarketplaceViewModel marketplaceViewModel,
  ) {
    marketplaceViewModel.fetchOffersOnMyAd(product.id);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<MarketplaceViewModel>(
          builder: (context, vm, child) {
            final offers = vm.offersOnMyAd;
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.slate300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Purchase Applicants / Offers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Ad: ${product.title}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.slate500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.vibrantBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${offers.length} Offers',
                          style: const TextStyle(
                            color: AppColors.vibrantBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : offers.isEmpty
                        ? const Center(
                            child: Text(
                              'No purchase offers received for this product yet.',
                            ),
                          )
                        : ListView.builder(
                            itemCount: offers.length,
                            itemBuilder: (context, index) {
                              final offer = offers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                offer.buyerAvatar.isNotEmpty
                                                ? NetworkImage(
                                                    offer.buyerAvatar,
                                                  )
                                                : null,
                                            child: offer.buyerAvatar.isEmpty
                                                ? SvgPicture.asset(
                                                    AppIcons.personSvg,
                                                    width: 20,
                                                    height: 20,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                          AppColors.slate500,
                                                          BlendMode.srcIn,
                                                        ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  offer.buyerName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  offer.timeAgo,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.slate500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            offer.offerPrice,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.vibrantBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (offer.message != null &&
                                          offer.message!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          '"${offer.message}"',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.slate600,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: offer.isAccepted
                                                  ? const Color(0xFFDCFCE7)
                                                  : (offer.isRejected
                                                        ? const Color(
                                                            0xFFFEE2E2,
                                                          )
                                                        : const Color(
                                                            0xFFFEF3C7,
                                                          )),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              offer.statusDisplay,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: offer.isAccepted
                                                    ? const Color(0xFF10B981)
                                                    : (offer.isRejected
                                                          ? const Color(
                                                              0xFFEF4444,
                                                            )
                                                          : const Color(
                                                              0xFFD97706,
                                                            )),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (offer.isPending) ...[
                                            OutlinedButton(
                                              onPressed: () async {
                                                final success = await vm
                                                    .rejectOffer(offer.id);
                                                if (success &&
                                                    context.mounted) {
                                                  final chatVM = context
                                                      .read<ChatViewModel>();
                                                  chatVM.sendMessage(
                                                    '',
                                                    offer.buyerId,
                                                    "Hi ${offer.buyerName}, your offer of ${offer.offerPrice} for '${product.title}' was REJECTED by the seller.",
                                                  );
                                                  if (context.mounted) {
                                                    Navigator.pop(ctx);
                                                    final conv = ChatConversationModel(
                                                      id: '',
                                                      otherParticipant:
                                                          ChatParticipantModel(
                                                            id: offer.buyerId,
                                                            firstName:
                                                                offer.buyerName,
                                                            lastName: '',
                                                            profilePhotoUrl:
                                                                offer
                                                                    .buyerAvatar
                                                                    .isNotEmpty
                                                                ? offer
                                                                      .buyerAvatar
                                                                : null,
                                                          ),
                                                      updatedAt: DateTime.now(),
                                                      createdAt: DateTime.now(),
                                                    );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ChatDetailView(
                                                              conversation:
                                                                  conv,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(
                                                  color: Colors.red,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                              ),
                                              child: const Text(
                                                'Reject',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final success = await vm
                                                    .acceptOffer(offer.id);
                                                if (success &&
                                                    context.mounted) {
                                                  final chatVM = context
                                                      .read<ChatViewModel>();
                                                  chatVM.sendMessage(
                                                    '',
                                                    offer.buyerId,
                                                    "Hi ${offer.buyerName}, your offer of ${offer.offerPrice} for '${product.title}' was ACCEPTED by the seller!",
                                                  );
                                                  if (context.mounted) {
                                                    Navigator.pop(ctx);
                                                    final conv = ChatConversationModel(
                                                      id: '',
                                                      otherParticipant:
                                                          ChatParticipantModel(
                                                            id: offer.buyerId,
                                                            firstName:
                                                                offer.buyerName,
                                                            lastName: '',
                                                            profilePhotoUrl:
                                                                offer
                                                                    .buyerAvatar
                                                                    .isNotEmpty
                                                                ? offer
                                                                      .buyerAvatar
                                                                : null,
                                                          ),
                                                      updatedAt: DateTime.now(),
                                                      createdAt: DateTime.now(),
                                                    );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ChatDetailView(
                                                              conversation:
                                                                  conv,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.vibrantBlue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                              ),
                                              child: const Text(
                                                'Accept',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              final conv =
                                                  ChatConversationModel(
                                                    id: '',
                                                    otherParticipant:
                                                        ChatParticipantModel(
                                                          id: offer.buyerId,
                                                          firstName:
                                                              offer.buyerName,
                                                          lastName: '',
                                                          profilePhotoUrl:
                                                              offer
                                                                  .buyerAvatar
                                                                  .isNotEmpty
                                                              ? offer
                                                                    .buyerAvatar
                                                              : null,
                                                        ),
                                                    updatedAt: DateTime.now(),
                                                    createdAt: DateTime.now(),
                                                  );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ChatDetailView(
                                                        conversation: conv,
                                                      ),
                                                ),
                                              );
                                            },
                                            icon: SvgPicture.asset(
                                              AppIcons.chatRoundSvg,
                                              width: 14,
                                              height: 14,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    Colors.white,
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                            label: const Text(
                                              'Chat',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF0F172A,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: const TextStyle(color: AppColors.slate500, fontSize: 14),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog({
    required BuildContext context,
    required bool isProperty,
    String? itemType,
  }) {
    final String typeName = itemType ?? (isProperty ? 'Ad' : 'Post');
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isSmall = ctx.isSmall;
        final isTablet = ctx.isTablet;

        final double iconBoxSize =
            (isSmall ? 60.0 : ctx.scale(72.0)).clamp(56.0, 72.0);
        final double iconSize =
            (isSmall ? 30.0 : ctx.scale(36.0)).clamp(28.0, 36.0);
        final double buttonHeight =
            (isSmall ? 44.0 : ctx.scaleH(48.0)).clamp(44.0, 50.0);
        final double titleFontSize =
            (isSmall ? 18.0 : ctx.sp(20.0)).clamp(17.0, 21.0);
        final double descFontSize =
            (isSmall ? 13.0 : ctx.sp(14.0)).clamp(12.5, 14.5);
        final double btnFontSize =
            (isSmall ? 14.0 : ctx.sp(15.0)).clamp(13.5, 15.5);

        final double horizontalPadding =
            isSmall ? 18.0 : ctx.scale(24.0).clamp(20.0, 26.0);
        final double verticalPadding =
            isSmall ? 20.0 : ctx.scale(28.0).clamp(22.0, 28.0);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmall ? 20 : 24),
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 80.0 : (isSmall ? 16.0 : 24.0),
            vertical: isSmall ? 16.0 : 24.0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 420.0 : 400.0,
              maxHeight: ctx.screenHeight * 0.9,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: iconBoxSize,
                      height: iconBoxSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppIcons.deleteSvg,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFEF4444),
                            BlendMode.srcIn,
                          ),
                          width: iconSize,
                          height: iconSize,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 16 : 20),
                    Text(
                      'Delete This $typeName?',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    Text(
                      isProperty
                          ? 'All information including pictures will be permanently deleted. This cannot be undone.'
                          : 'All post details and associated data will be permanently deleted. This cannot be undone.',
                      style: TextStyle(
                        fontSize: descFontSize,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmall ? 18 : 24),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(ctx, true),
                        icon: SvgPicture.asset(
                          AppIcons.deleteSvg,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: isSmall ? 16 : 18,
                          height: isSmall ? 16 : 18,
                        ),
                        label: Text(
                          'Yes, Delete $typeName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: btnFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: const Color(0xFF374151),
                            fontSize: btnFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ignore: unused_element
  void _showEditProductSheet(
    BuildContext context,
    MarketplaceItemModel product,
    MarketplaceViewModel marketplaceViewModel,
  ) {
    final titleController = TextEditingController(text: product.title);
    final priceController = TextEditingController(
      text: product.price.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    final brandController = TextEditingController(text: product.brand ?? '');
    final locationController = TextEditingController(text: product.location);
    final descController = TextEditingController(text: product.description);

    String selectedCategory = product.category;
    if (![
      'Phones',
      'Cars',
      'Electronics',
      'Furniture',
      'Clothes',
      'Books',
      'Kids',
      'Other',
    ].contains(selectedCategory)) {
      selectedCategory = 'Other';
    }

    String selectedCondition = product.condition ?? 'New';
    if (![
      'New',
      'Like New',
      'Good',
      'Fair',
      'For Parts',
    ].contains(selectedCondition)) {
      selectedCondition = 'New';
    }

    bool isNegotiable = product.isNegotiable;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Product Ad',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            AppIcons.crossSmallSvg,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate500,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Product Title',
                        filled: true,
                        fillColor: AppColors.slate50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.slate200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price (€)',
                              filled: true,
                              fillColor: AppColors.slate50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.slate200,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              filled: true,
                              fillColor: AppColors.slate50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.slate200,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Phones',
                                child: Text('Phones'),
                              ),
                              DropdownMenuItem(
                                value: 'Cars',
                                child: Text('Cars'),
                              ),
                              DropdownMenuItem(
                                value: 'Electronics',
                                child: Text('Electronics'),
                              ),
                              DropdownMenuItem(
                                value: 'Furniture',
                                child: Text('Furniture'),
                              ),
                              DropdownMenuItem(
                                value: 'Clothes',
                                child: Text('Clothes'),
                              ),
                              DropdownMenuItem(
                                value: 'Books',
                                child: Text('Books'),
                              ),
                              DropdownMenuItem(
                                value: 'Kids',
                                child: Text('Kids'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() => selectedCategory = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCondition,
                            decoration: InputDecoration(
                              labelText: 'Condition',
                              filled: true,
                              fillColor: AppColors.slate50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.slate200,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'New',
                                child: Text('New'),
                              ),
                              DropdownMenuItem(
                                value: 'Like New',
                                child: Text('Like New'),
                              ),
                              DropdownMenuItem(
                                value: 'Good',
                                child: Text('Good'),
                              ),
                              DropdownMenuItem(
                                value: 'Fair',
                                child: Text('Fair'),
                              ),
                              DropdownMenuItem(
                                value: 'For Parts',
                                child: Text('For Parts'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() => selectedCondition = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: brandController,
                            decoration: InputDecoration(
                              labelText: 'Brand (Optional)',
                              filled: true,
                              fillColor: AppColors.slate50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.slate200,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        filled: true,
                        fillColor: AppColors.slate50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.slate200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        filled: true,
                        fillColor: AppColors.slate50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.slate200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price Negotiable'),
                        Switch(
                          value: isNegotiable,
                          onChanged: (val) {
                            setSheetState(() => isNegotiable = val);
                          },
                          activeThumbColor: AppColors.vibrantBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                setSheetState(() => isSaving = true);
                                final result = await marketplaceViewModel
                                    .updateProductAd(
                                      product.id,
                                      title: titleController.text.trim(),
                                      price: priceController.text.trim(),
                                      category: selectedCategory,
                                      condition: selectedCondition,
                                      brand: brandController.text.trim(),
                                      location: locationController.text.trim(),
                                      description: descController.text.trim(),
                                      negotiable: isNegotiable,
                                    );
                                setSheetState(() => isSaving = false);
                                if (!context.mounted) return;
                                Navigator.pop(ctx);
                                if (result != null) {
                                  marketplaceViewModel.fetchMyAds();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ad updated successfully!'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        marketplaceViewModel.errorMessage ??
                                            'Failed to update ad',
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vibrantBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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
      },
    );
  }
}
