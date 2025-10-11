/// booking_details_screen.dart - Booking Details Display
/// 
/// Purpose:
/// - Displays detailed information about booking requests and confirmations
/// - Provides booking management and modification capabilities
/// - Handles booking status updates and user actions
/// 
/// Key Logic:
/// - Comprehensive booking information display (locations, timing, pricing)
/// - Booking status tracking (pending, confirmed, assigned, completed)
/// - Driver assignment information and contact details
/// - Vehicle details and estimated arrival times
/// - Booking modification options (reschedule, cancel, update details)
/// - Payment information and transaction history
/// - Integration with booking repository for data retrieval
/// - Real-time updates via WebSocket or polling mechanisms

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/services/map_service_interface.dart';
import '../../../../core/models/booking_model.dart' as core;
import '../../../vehicle_estimation/data/models/vehicle_estimate_response.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../wallet/presentation/widgets/add_balance_modal.dart';
import '../../data/models/booking_request.dart' as data_models;
import '../../data/models/stop_point.dart';
import '../../data/services/booking_service.dart';
import '../../domain/repositories/booking_repository.dart';
import '../bloc/booking_bloc.dart';
import '../widgets/insufficient_balance_modal.dart';
import '../../../../core/di/service_locator.dart';
import 'driver_search_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final MapLatLng pickupLocation;
  final MapLatLng dropLocation;
  final String pickupAddress;
  final String dropAddress;
  final VehicleEstimateResponse selectedVehicle;

  const BookingDetailsScreen({
    Key? key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupAddress,
    required this.dropAddress,
    required this.selectedVehicle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BookingBloc(
            serviceLocator<BookingRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => WalletBloc(serviceLocator<WalletRepository>()),
        ),
      ],
      child: _BookingDetailsContent(
        pickupLocation: pickupLocation,
        dropLocation: dropLocation,
        pickupAddress: pickupAddress,
        dropAddress: dropAddress,
        selectedVehicle: selectedVehicle,
      ),
    );
  }
}

class _BookingDetailsContent extends StatefulWidget {
  final MapLatLng pickupLocation;
  final MapLatLng dropLocation;
  final String pickupAddress;
  final String dropAddress;
  final VehicleEstimateResponse selectedVehicle;

  const _BookingDetailsContent({
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupAddress,
    required this.dropAddress,
    required this.selectedVehicle,
  });

  @override
  State<_BookingDetailsContent> createState() => _BookingDetailsContentState();
}

class _BookingDetailsContentState extends State<_BookingDetailsContent> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _goodsTypeController = TextEditingController();
  final _goodsQuantityController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  // Form state
  bool _sameAsReceiver = false;
  String _selectedPaymentMode = 'CASH';
  DateTime _selectedPickupTime = DateTime.now().add(const Duration(minutes: 30));
  
  final List<String> _paymentModes = ['CASH', 'WALLET'];
  final List<String> _goodsTypes = [
    'Electronics',
    'Furniture',
    'Groceries',
    'Clothes',
    'Books',
    'Others'
  ];

  late final BookingService _bookingService;

  @override
  void initState() {
    super.initState();
    _bookingService = BookingService(serviceLocator());
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _goodsTypeController.dispose();
    _goodsQuantityController.dispose();
    _instructionsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSameAsReceiver(bool? value) {
    setState(() {
      _sameAsReceiver = value ?? false;
      if (_sameAsReceiver) {
        _receiverNameController.text = _senderNameController.text;
        _receiverPhoneController.text = _senderPhoneController.text;
      } else {
        _receiverNameController.clear();
        _receiverPhoneController.clear();
      }
    });
  }

  void _onSenderDetailsChanged() {
    if (_sameAsReceiver) {
      _receiverNameController.text = _senderNameController.text;
      _receiverPhoneController.text = _senderPhoneController.text;
    }
  }

  Future<void> _selectPickupTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedPickupTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedPickupTime),
      );

      if (time != null) {
        setState(() {
          _selectedPickupTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check wallet balance if wallet payment is selected
    if (_selectedPaymentMode == 'WALLET') {
      if (mounted) {
        context.read<BookingBloc>().add(
          CheckWalletBalance(widget.selectedVehicle.estimatedFare)
        );
      }
      return;
    }

    // Proceed with booking creation for cash payment
    _createBooking();
  }

  void _createBooking() {
    final bookingData = {
      'sender_name': _senderNameController.text.trim(),
      'receiver_name': _receiverNameController.text.trim(),
      'sender_phone': _senderPhoneController.text.trim(),
      'receiver_phone': _receiverPhoneController.text.trim(),
      'pickup_time': _selectedPickupTime.toIso8601String(),
      'vehicle_type_id': widget.selectedVehicle.vehicleType,
      'goods_type': _goodsTypeController.text.trim(),
      'goods_quantity': _goodsQuantityController.text.trim(),
      'payment_mode': _selectedPaymentMode,
      'stop_points': [
        {
          'latitude': widget.pickupLocation.lat,
          'longitude': widget.pickupLocation.lng,
          'address': widget.pickupAddress,
          'stop_order': 0,
        },
        {
          'latitude': widget.dropLocation.lat,
          'longitude': widget.dropLocation.lng,
          'address': widget.dropAddress,
          'stop_order': 1,
        },
      ],
    };

    // Debug: Print the booking data being sent

    context.read<BookingBloc>().add(
      CreateBookingEvent(bookingData),
    );
  }

  void _showInsufficientBalanceModal(BuildContext context, WalletBalanceInsufficient state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (modalContext) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: InsufficientBalanceModal(
          currentBalance: state.balance,
          requiredAmount: state.requiredAmount,
          shortfall: state.shortfall,
          onAddBalance: () {
            Navigator.pop(modalContext);
            _showAddBalanceModalWithAmount(context, state.shortfall);
          },
          onCancel: () {
            Navigator.pop(modalContext);
            context.read<BookingBloc>().add(const ResetBookingState());
          },
        ),
      ),
    );
  }

  void _showAddBalanceModalWithAmount(BuildContext context, double suggestedAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (modalContext) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: AddBalanceModal(suggestedAmount: suggestedAmount),
      ),
    );
  }

  void _navigateToDriverSearch(core.BookingRequest booking) {
    // Convert BookingRequestModel to BookingResponse
    final bookingResponse = data_models.BookingResponse(
      id: booking.id,
      tripId: booking.tripId,
      senderName: booking.senderName,
      receiverName: booking.receiverName,
      senderPhone: booking.senderPhone,
      receiverPhone: booking.receiverPhone,
      pickupTime: booking.pickupTime,
      goodsType: booking.goodsType,
      goodsQuantity: booking.goodsQuantity,
      paymentMode: booking.paymentMode.toString().split('.').last.toUpperCase(),
      estimatedFare: booking.estimatedFare,
      status: booking.status.toString().split('.').last.toUpperCase(),
      instructions: '', // Default empty instructions
      stopPoints: [
        // Create a default pickup stop point
        StopPoint(
          id: 0,
          location: 'POINT (0 0)',
          address: booking.pickupAddress,
          stopOrder: 0,
          stopType: 'PICKUP',
          contactName: '',
          contactPhone: '',
          notes: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Create a default dropoff stop point
        StopPoint(
          id: 1,
          location: 'POINT (0 0)',
          address: booking.dropoffAddress,
          stopOrder: 1,
          stopType: 'DROPOFF',
          contactName: '',
          contactPhone: '',
          notes: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );

    // Navigate to driver search screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverSearchScreen(
            bookingDetails: bookingResponse,
            selectedVehicle: widget.selectedVehicle,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MultiBlocListener(
      listeners: [
        BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is WalletBalanceSufficient) {
              // Proceed with booking creation
              _createBooking();
            } else if (state is BookingRequestCreated) {
              // Navigate to driver search screen
              _navigateToDriverSearch(state.bookingRequest);
            } else if (state is BookingSuccess) {
              // Navigate to driver search screen
              _navigateToDriverSearch(state.booking);
            } else if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
        BlocListener<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state is AddBalanceSuccess) {
              // Re-check wallet balance after successful top-up
              context.read<BookingBloc>().add(
                CheckWalletBalance(widget.selectedVehicle.estimatedFare)
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Booking Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip summary
                      _buildTripSummary(theme),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Sender details
                      _buildSectionTitle(theme, 'Sender Details'),
                      const SizedBox(height: AppSpacing.md),
                      _buildSenderForm(theme),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Same as receiver option
                      _buildSameAsReceiverOption(theme),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Receiver details
                      _buildSectionTitle(theme, 'Receiver Details'),
                      const SizedBox(height: AppSpacing.md),
                      _buildReceiverForm(theme),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Goods details
                      _buildSectionTitle(theme, 'Goods Information'),
                      const SizedBox(height: AppSpacing.md),
                      _buildGoodsForm(theme),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Pickup time
                      _buildSectionTitle(theme, 'Pickup Time'),
                      const SizedBox(height: AppSpacing.md),
                      _buildPickupTimeSelector(theme),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Payment mode
                      _buildSectionTitle(theme, 'Payment Method'),
                      const SizedBox(height: AppSpacing.md),
                      _buildPaymentModeSelector(theme),
                      
                      // Bottom padding for fixed button
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
            top: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  final isLoading = state is BookingLoading || 
                                   state is WalletBalanceChecking;
                  
                  return ElevatedButton(
                    onPressed: isLoading ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                state is WalletBalanceChecking 
                                    ? 'Checking Balance...' 
                                    : 'Creating Booking...',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Confirm Booking • ₹${widget.selectedVehicle.estimatedFare.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.selectedVehicle.vehicleIcon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.selectedVehicle.vehicleTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '₹${widget.selectedVehicle.estimatedFare.toStringAsFixed(0)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildAddressRow(
            theme,
            Icons.trip_origin,
            Colors.green,
            'From',
            widget.pickupAddress,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildAddressRow(
            theme,
            Icons.location_on,
            Colors.red,
            'To',
            widget.dropAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(
    ThemeData theme,
    IconData icon,
    Color color,
    String label,
    String address,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            address,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildSenderForm(ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          controller: _senderNameController,
          decoration: const InputDecoration(
            labelText: 'Sender Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter sender name';
            }
            return null;
          },
          onChanged: (_) => _onSenderDetailsChanged(),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _senderPhoneController,
          decoration: const InputDecoration(
            labelText: 'Sender Phone',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter sender phone number';
            }
            if (value.trim().length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
          onChanged: (_) => _onSenderDetailsChanged(),
        ),
      ],
    );
  }

  Widget _buildSameAsReceiverOption(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Sender and Receiver are the same person',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Switch(
            value: _sameAsReceiver,
            onChanged: _toggleSameAsReceiver,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverForm(ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          controller: _receiverNameController,
          enabled: !_sameAsReceiver,
          decoration: InputDecoration(
            labelText: 'Receiver Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: const OutlineInputBorder(),
            filled: _sameAsReceiver,
            fillColor: _sameAsReceiver 
                ? theme.colorScheme.onSurface.withOpacity(0.1) 
                : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter receiver name';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _receiverPhoneController,
          enabled: !_sameAsReceiver,
          decoration: InputDecoration(
            labelText: 'Receiver Phone',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: const OutlineInputBorder(),
            filled: _sameAsReceiver,
            fillColor: _sameAsReceiver 
                ? theme.colorScheme.onSurface.withOpacity(0.1) 
                : null,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter receiver phone number';
            }
            if (value.trim().length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGoodsForm(ThemeData theme) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _goodsTypeController.text.isEmpty ? null : _goodsTypeController.text,
          decoration: const InputDecoration(
            labelText: 'Goods Type',
            prefixIcon: Icon(Icons.inventory_2),
            border: OutlineInputBorder(),
          ),
          items: _goodsTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _goodsTypeController.text = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select goods type';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _goodsQuantityController,
          decoration: const InputDecoration(
            labelText: 'Goods Quantity/Description',
            prefixIcon: Icon(Icons.format_list_numbered),
            border: OutlineInputBorder(),
            hintText: 'e.g., 2 boxes, 1 sofa, etc.',
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter goods quantity or description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPickupTimeSelector(ThemeData theme) {
    return InkWell(
      onTap: _selectPickupTime,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup Date & Time',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '${_selectedPickupTime.day}/${_selectedPickupTime.month}/${_selectedPickupTime.year} at ${_selectedPickupTime.hour.toString().padLeft(2, '0')}:${_selectedPickupTime.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentModeSelector(ThemeData theme) {
    return Column(
      children: _paymentModes.map((mode) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: RadioListTile<String>(
            title: Text(mode),
            value: mode,
            groupValue: _selectedPaymentMode,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMode = value!;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
            ),
          ),
        );
      }).toList(),
    );
  }
} 