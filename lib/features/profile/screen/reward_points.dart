import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';
// A stateful widget with Riverpod's Consumer capabilities for watching state
class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  static const routeName = '/reward-screen';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RewardsScreenState();
}

// State class for RewardsScreen, including tab controller mixin
class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initializing tab controller with one tab (Earn tab)
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // Watching userProvider to get current user state
    var user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Apptheme.logoInsideColor,
        title: Text("Rewards", style: TextStyle(color: Colors.white)),

        // TabBar showing the tabs (currently only "Earn" is used)
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.yellow,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: "Earn"),
            // Future tabs can be added here (e.g., Redeem, Offers)
          ],
        ),
      ),

      // Tab view for each tab; right now only Earn tab is active
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarnTab(user!.loyaltyPoints),
        ],
      ),
    );
  }

  /// Builds the content of the "Earn" tab
  Widget _buildEarnTab(int points) {
    // Calculate how many points are needed to reach the next reward threshold
    int nextRewardThreshold = ((points / 100).ceil()) * 100;
    int pointsToNextReward = nextRewardThreshold - points;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Card displaying current user's points and progress
          Card(
            color: Apptheme.logoOutsideColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Displaying total GK Points
                  Text(
                    points.toString(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // Label below points
                  Text(
                    "GK POINTS®",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Progress bar indicating progress to next reward (out of 100)
                  LinearProgressIndicator(
                    value: (points % 100) / 100,
                    backgroundColor: Colors.white38,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),

                  SizedBox(height: 8),

                  // Message showing how many points left to next reward
                  Text(
                    "$pointsToNextReward points to your next reward",
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Card that allows user to claim points using a receipt
          SizedBox(
            width: double.infinity,
            child: Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Prompt text
                    Text(
                      "ALREADY PLACED AN ORDER?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    // Button to trigger receipt-based point earning (feature not implemented yet)
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement receipt upload or entry
                      },
                      icon: Icon(Icons.receipt, color: Colors.red),
                      label: Text(
                        "EARN POINTS WITH RECEIPT",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
