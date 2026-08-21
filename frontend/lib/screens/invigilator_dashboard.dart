// lib/screens/invigilator_dashboard.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';
import '../widgets/verification_card.dart';
import '../services/api_service.dart';

class InvigilatorDashboard extends StatefulWidget {
  const InvigilatorDashboard({super.key});

  @override
  State<InvigilatorDashboard> createState() => _InvigilatorDashboardState();
}

class _InvigilatorDashboardState extends State<InvigilatorDashboard> {
  // --- STATE VARIABLES ---
  List<Duty> _pendingVerifications = []; // Starts empty!
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVerifications();
  }

  // --- API FUNCTIONS ---
  Future<void> _fetchVerifications() async {
    try {
      // Fetch all CSE duties
      final allDuties = await ApiService.getDutiesByDepartment('CSE');
      setState(() {
        // The Faculty ONLY cares about rooms the Sweeper has marked as 'completed'
        _pendingVerifications = allDuties.where((d) => d.status == DutyStatus.completed).toList();
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

    showDialog(
      context: context,
      builder: (context) {
        // ... (Keep your exact same Dialog UI code here!) ...
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
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: 'e.g., Dust on windows', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(16)),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Cancel'))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Reason is required to reject.'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                            return;
                          }
                          Navigator.pop(context); // Close dialog immediately
                          
                          final reason = reasonController.text.trim();
                          
                          // Optimistic UI removal
                          setState(() => _pendingVerifications.removeWhere((duty) => duty.id == dutyId));
                          
                          try {
                            // Tell MongoDB it is rejected and pass the reason!
                            await ApiService.updateStatus(dutyId, DutyStatus.rejected, rejectionReason: reason);
                            
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Task Rejected. Sweeper notified.'), backgroundColor: const Color(0xFFC62828), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
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
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Pending Verifications',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 20),
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3949AB)))
          : AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _pendingVerifications.isEmpty
            ? const _AllCaughtUpState(key: ValueKey('empty'))
            : ListView.builder(
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
  const _AllCaughtUpState({super.key});

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
                      color: Colors.green.withValues(alpha:0.25),
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