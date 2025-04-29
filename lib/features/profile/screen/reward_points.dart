import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/core/constant/colors.dart';
import 'package:gzresturent/features/auth/controller/auth_controller.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  static const routeName = '/reward-screen';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Apptheme.logoInsideColor,
        title: Text("Rewards", style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.yellow,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: "Earn"),
            //  Tab(text: "Redeem"),
            //  Tab(text: "Offers"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarnTab(user!.loyaltyPoints),
          // Center(child: Text("Redeem Page")),
          // Center(child: Text("Offers Page")),
        ],
      ),
    );
  }

  Widget _buildEarnTab(int points) {
    int nextRewardThreshold = ((points / 100).ceil()) * 100;
    int pointsToNextReward = nextRewardThreshold - points;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Points Card
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
                  Text(
                    points.toString(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "GK POINTS®",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  /// 🟡 Dynamic Progress Bar to Next 100
                  LinearProgressIndicator(
                    value: (points % 100) / 100,
                    backgroundColor: Colors.white38,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),

                  SizedBox(height: 8),

                  /// 🟡 Dynamic Message
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

          // Earn Points with Receipt
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
                    Text(
                      "ALREADY PLACED AN ORDER?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {},
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
