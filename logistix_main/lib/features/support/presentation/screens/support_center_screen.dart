import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({Key? key}) : super(key: key);

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> {
  final List<SupportCategory> _supportCategories = [
    SupportCategory(
      title: 'Help Center',
      description: 'Find answers to common questions',
      icon: Icons.help_outline,
      color: Colors.blue,
      route: '/help-center',
    ),
    SupportCategory(
      title: 'Contact Support',
      description: 'Get in touch with our support team',
      icon: Icons.support_agent,
      color: Colors.green,
      route: '/contact-support',
    ),
    SupportCategory(
      title: 'Live Chat',
      description: 'Chat with our support team in real-time',
      icon: Icons.chat,
      color: Colors.orange,
      route: '/live-chat',
    ),
    SupportCategory(
      title: 'FAQ',
      description: 'Frequently asked questions',
      icon: Icons.question_answer,
      color: Colors.purple,
      route: '/faq',
    ),
    SupportCategory(
      title: 'Report Issue',
      description: 'Report a problem or bug',
      icon: Icons.bug_report,
      color: Colors.red,
      route: '/report-issue',
    ),
    SupportCategory(
      title: 'Feedback',
      description: 'Share your feedback with us',
      icon: Icons.feedback,
      color: Colors.teal,
      route: '/feedback',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Support Center',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'How can we help?',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Choose an option below to get the help you need',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 24.h),
              
              // Quick Actions
              _buildQuickActions(),
              SizedBox(height: 24.h),
              
              // Support Categories
              Text(
                'Support Options',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 16.h),
              
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _supportCategories.length,
                  itemBuilder: (context, index) {
                    return _buildSupportCategoryCard(_supportCategories[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.phone,
                color: Theme.of(context).colorScheme.primary,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Quick Contact',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  title: 'Call Us',
                  subtitle: '1800-123-4567',
                  icon: Icons.call,
                  onTap: () {
                    // Handle call action
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickActionButton(
                  title: 'Email Us',
                  subtitle: 'support@logistix.com',
                  icon: Icons.email,
                  onTap: () {
                    // Handle email action
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20.w,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCategoryCard(SupportCategory category) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, category.route);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 24.w,
                ),
              ),
              SizedBox(height: 12.h),
              
              // Title
              Text(
                category.title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              
              // Description
              Text(
                category.description,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  SupportCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
} 