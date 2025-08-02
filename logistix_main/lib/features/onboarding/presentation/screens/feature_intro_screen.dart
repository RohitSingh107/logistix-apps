import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureIntroScreen extends StatefulWidget {
  const FeatureIntroScreen({Key? key}) : super(key: key);

  @override
  State<FeatureIntroScreen> createState() => _FeatureIntroScreenState();
}

class _FeatureIntroScreenState extends State<FeatureIntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h),
                
                // Header
                Text(
                  'Discover Logistix',
                  style: GoogleFonts.poppins(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Everything you need for seamless logistics',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 32.h),
                
                // Features Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      return _buildFeatureCard(_features[index]);
                    },
                  ),
                ),
                
                // Action Buttons
                Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/permissions');
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          'Skip Introduction',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
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
      ),
    );
  }

  Widget _buildFeatureCard(FeatureItem feature) {
    return Container(
      decoration: BoxDecoration(
        color: feature.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: feature.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                feature.icon,
                color: feature.color,
                size: 24.w,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Title
            Text(
              feature.title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 8.h),
            
            // Description
            Text(
              feature.description,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<FeatureItem> _features = [
    FeatureItem(
      title: 'Instant Booking',
      description: 'Book deliveries in seconds with our streamlined booking process',
      icon: Icons.schedule,
      color: Colors.blue,
    ),
    FeatureItem(
      title: 'Live Tracking',
      description: 'Track your shipments in real-time with live location updates',
      icon: Icons.location_on,
      color: Colors.green,
    ),
    FeatureItem(
      title: 'Multiple Payments',
      description: 'Pay with wallet, cards, UPI, or cash on delivery',
      icon: Icons.payment,
      color: Colors.orange,
    ),
    FeatureItem(
      title: 'Order Management',
      description: 'View and manage all your orders from one place',
      icon: Icons.list_alt,
      color: Colors.purple,
    ),
    FeatureItem(
      title: 'Driver Mode',
      description: 'Switch to driver mode and earn by delivering packages',
      icon: Icons.drive_eta,
      color: Colors.red,
    ),
    FeatureItem(
      title: '24/7 Support',
      description: 'Get help anytime with our round-the-clock customer support',
      icon: Icons.support_agent,
      color: Colors.teal,
    ),
  ];
}

class FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
} 