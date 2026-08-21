// lib/screens/invigilator_dashboard.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';
import '../widgets/verification_card.dart';
import '../services/api_service.dart';
import 'package:shimmer/shimmer.dart';

class InvigilatorDashboard extends StatefulWidget {
  final String facultyName; // <-- Accepts the name from the login screen!
  const InvigilatorDashboard({super.key, required this.facultyName});

  @override
  State<InvigilatorDashboard> createState() => _InvigilatorDashboardState();
}

class _InvigilatorDashboardState extends State<InvigilatorDashboard> {
  List<Duty> _pendingVerifications = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVerifications();
  }

  Future<void> _fetchVerifications() async {
    try {
      final allDuties = await ApiService.getDutiesByDepartment('CSE');
      setState(() {
        // FILTER: Only show rooms that are COMPLETED *and* belong to this specific Professor
        _pendingVerifications = allDuties.where((d) => 
          d.status == DutyStatus.completed && 
          d.facultyName != null &&
          d.facultyName!.toLowerCase().contains(widget.facultyName.toLowerCase())
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching verifications: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyTask(String dutyId) async {
    // Optimistic UI update for a snappy feel
    setState(() => _pendingVerifications.removeWhere((duty) => duty.id == dutyId));

    try {
      // Tell MongoDB it is verified!
      await ApiService.updateStatus(dutyId, DutyStatus.verified);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Room Verified Successfully!'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      debugPrint("Verification failed: $e");
      // If it fails, refresh the list from the server
      _fetchVerifications();
    }
  }

  void _rejectTask(String dutyId) {
    final reasonController = TextEditingController();
    String? selectedReason; 
    final messenger = ScaffoldMessenger.of(context);
    
    final predefinedReasons = [
      'Dust on windows/desks',
      'Floor not mopped',
      'Trash bin not emptied',
      'Board not cleaned',
      'Others...'
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.close_rounded, color: Color(0xFFC62828))),
                        const SizedBox(width: 14),
                        const Expanded(child: Text('Reject Cleaning', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // THE NEW CHOICE CHIPS
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: predefinedReasons.map((reason) {
                        final isSelected = selectedReason == reason;
                        return ChoiceChip(
                          label: Text(
                            reason, 
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87, 
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                            )
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFC62828),
                          backgroundColor: const Color(0xFFF7F7FA),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
                          onSelected: (selected) {
                            setDialogState(() {
                              selectedReason = selected ? reason : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    // Show text box ONLY if 'Others...' is clicked
                    if (selectedReason == 'Others...') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: reasonController,
                        maxLines: 2,
                        decoration: InputDecoration(hintText: 'Type custom reason...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(16)),
                      ),
                    ],

                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: () => Navigator.pop(dialogContext), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Cancel'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              String finalReason = '';
                              if (selectedReason == 'Others...') {
                                finalReason = reasonController.text.trim();
                              } else {
                                finalReason = selectedReason ?? '';
                              }

                              if (finalReason.isEmpty) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: const Text('Please select or type a reason.'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                                return;
                              }
                              
                              Navigator.pop(dialogContext); 
                              setState(() => _pendingVerifications.removeWhere((duty) => duty.id == dutyId));
                              
                              try {
                                await ApiService.updateStatus(dutyId, DutyStatus.rejected, rejectionReason: finalReason);
                                if (!mounted) return;
                                messenger.showSnackBar(SnackBar(content: const Text('Task Rejected. Sweeper notified.'), backgroundColor: const Color(0xFFC62828), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
                              } catch (e) {
                                debugPrint("Rejection failed: $e");
                                _fetchVerifications();
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
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

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  // --- PREMIUM UX: SHIMMER LOADING EFFECT ---
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 90, // Standard card height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Verify: PROF. ${widget.facultyName.toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.black54),
            onPressed: _logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading 
          ? _buildShimmerLoading() 
          : RefreshIndicator(
              onRefresh: _fetchVerifications, 
              color: const Color(0xFF3949AB),
              backgroundColor: Colors.white,
              child: _pendingVerifications.isEmpty 
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 40),
                        _AllCaughtUpState(),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(), // <-- Added this!
                      key: const ValueKey('list'),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _pendingVerifications.length,
                      itemBuilder: (context, index) {
                        final duty = _pendingVerifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: VerificationCard(
                            duty: duty,
                            onVerify: () => _verifyTask(duty.id),
                            onReject: () => _rejectTask(duty.id),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _AllCaughtUpState extends StatelessWidget {
  const _AllCaughtUpState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green.shade200, Colors.teal.shade100],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(Icons.verified_rounded, size: 64, color: Colors.green.shade700),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'All Caught Up!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no rooms waiting for verification.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}