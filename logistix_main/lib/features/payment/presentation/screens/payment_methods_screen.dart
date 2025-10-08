import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/payment_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/repositories/payment_repository.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedPaymentMethod = 'wallet';

  final List<PaymentMethodData> _paymentMethods = [
    PaymentMethodData(
      id: 'wallet',
      name: 'Wallet',
      description: 'Pay using your Logistix wallet balance',
      icon: Icons.account_balance_wallet,
      color: Colors.blue,
      isDefault: true,
    ),
    PaymentMethodData(
      id: 'card',
      name: 'Credit/Debit Card',
      description: 'Pay using your credit or debit card',
      icon: Icons.credit_card,
      color: Colors.green,
      isDefault: false,
    ),
    PaymentMethodData(
      id: 'upi',
      name: 'UPI',
      description: 'Pay using UPI apps like Google Pay, PhonePe',
      icon: Icons.payment,
      color: Colors.purple,
      isDefault: false,
    ),
    PaymentMethodData(
      id: 'netbanking',
      name: 'Net Banking',
      description: 'Pay using your bank\'s net banking',
      icon: Icons.account_balance,
      color: Colors.orange,
      isDefault: false,
    ),
    PaymentMethodData(
      id: 'cod',
      name: 'Cash on Delivery',
      description: 'Pay in cash when package is delivered',
      icon: Icons.money,
      color: Colors.red,
      isDefault: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(LoadPaymentMethods());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(
        serviceLocator<PaymentRepository>(),
      ),
      child: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              title: Text(
                'Payment Methods',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-payment-method');
                  },
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Choose Payment Method',
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Select your preferred payment option',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // Payment Methods List
                    Expanded(
                      child: state is PaymentLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _paymentMethods.length,
                              itemBuilder: (context, index) {
                                return _buildPaymentMethodCard(_paymentMethods[index]);
                              },
                            ),
                    ),
                    
                    // Action Buttons
                    Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: state is PaymentLoading ? null : _proceedToPayment,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: state is PaymentLoading
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Continue',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
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
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodData method) {
    final isSelected = _selectedPaymentMethod == method.id;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isSelected 
            ? method.color.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected 
              ? method.color
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method.id;
          });
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: method.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  method.icon,
                  color: method.color,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (method.isDefault) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Default',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      method.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Radio Button
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? method.color : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected ? method.color : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 12.w,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _proceedToPayment() {
    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamed(
        context,
        '/payment-confirmation',
        arguments: {
          'paymentMethod': _selectedPaymentMethod,
          'amount': 250.0, // This would come from booking details
        },
      );
    });
  }
}

class PaymentMethodData {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isDefault;

  PaymentMethodData({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isDefault,
  });
} 