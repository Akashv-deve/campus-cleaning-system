// lib/screens/sweeper_dashboard.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';
import '../widgets/room_card.dart';
import '../services/api_service.dart';

class SweeperDashboard extends StatefulWidget {
  final String sweeperName; // <-- Accepts the name from the login screen!
  const SweeperDashboard({super.key, required this.sweeperName});

  @override
  State<SweeperDashboard> createState() => _SweeperDashboardState();
}

class _SweeperDashboardState extends State<SweeperDashboard> {
  bool _isTamil = false;
  List<Duty> duties = []; 
  bool isLoading = true;  

  @override
  void initState() {
    super.initState();
    _fetchDuties();
  }

  Future<void> _fetchDuties() async {
    try {
      final fetchedDuties = await ApiService.getDutiesByDepartment('CSE');
      setState(() {
        // FILTER: Only show duties where the sweeperName matches the logged-in user!
        duties = fetchedDuties.where((d) => 
          d.sweeperName != null && d.sweeperName!.toLowerCase() == widget.sweeperName.toLowerCase()
        ).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  Future<void> _markAsCompleted(Duty duty) async {
    try {
      setState(() => duty.status = DutyStatus.completed);
      await ApiService.updateStatus(duty.id, DutyStatus.completed);
    } catch (e) {
      setState(() => duty.status = DutyStatus.pending);
      debugPrint("Failed to update: $e");
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    // Now using our live 'duties' list instead of the mock list!
    final int totalDuties = duties.length;
    final int completedDuties = duties.where((d) => d.status == DutyStatus.completed || d.status == DutyStatus.verified).length;
    final double progress = totalDuties == 0 ? 0 : completedDuties / totalDuties;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isTamil ? '${widget.sweeperName.toUpperCase()} வேலைகள்' : "${widget.sweeperName.toUpperCase()}'s Duties",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), 
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isTamil = !_isTamil),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              _isTamil ? 'EN' : 'தமிழ்',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            iconSize: 28,
            tooltip: _isTamil ? 'வெளியேறு' : 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
        ],
      ),
      // THE LOADING CHECK: Show spinner if fetching, otherwise show the UI
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEF6C00)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeader(completedDuties, totalDuties, progress),
                Expanded(
                  child: duties.isEmpty // Check live data
                      ? _EmptyState(isTamil: _isTamil)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          itemCount: duties.length, // Check live data
                          itemBuilder: (context, index) {
                            final duty = duties[index]; // Get live data
                            return RoomCard(
                              duty: duty,
                              onComplete: () => _markAsCompleted(duty),
                              isTamil: _isTamil,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressHeader(int completed, int total, double progress) {
    final bool allDone = total > 0 && completed == total;
    
    final String message;
    if (allDone) {
      message = _isTamil ? "🎉 அருமை! எல்லாம் முடிந்தது!" : "🎉 Amazing! All rooms done!";
    } else if (completed == 0) {
      message = _isTamil ? "வேலையை தொடங்குவோம்!" : "Let's get started!";
    } else {
      message = _isTamil ? "சிறப்பு — தொடர்ந்து செய்யுங்கள்!" : "Great work — keep going!";
    }

    final String progressText = _isTamil ? '$completed / $total முடிந்தது' : '$completed of $total rooms done';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 84, height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress), duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic,
                      builder: (context, value, _) => CircularProgressIndicator(value: value, strokeWidth: 10, backgroundColor: Colors.white.withValues(alpha: 0.25), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA5D6A7))),
                    ),
                    Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(progressText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress), duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic,
                        builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 14, backgroundColor: Colors.white.withValues(alpha: 0.25), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA5D6A7))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isTamil;
  const _EmptyState({required this.isTamil});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_rounded, size: 96, color: Colors.amber.shade600),
            const SizedBox(height: 20),
            Text(
              isTamil ? 'இன்று வேலைகள் இல்லை.' : 'No duties assigned yet.',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isTamil ? 'உங்கள் வேலைகள் இங்கே வரும்.' : 'Check back soon — your rooms will show up here.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}