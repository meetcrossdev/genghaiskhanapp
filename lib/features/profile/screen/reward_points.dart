import 'package:flutter/material.dart';
import 'package:gzresturent/core/constant/colors.dart';

class RewardsScreen extends StatefulWidget {
  static const routeName = '/reward-screen';

  const RewardsScreen({super.key});
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
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
          tabs: [Tab(text: "Earn"), Tab(text: "Redeem"), Tab(text: "Offers")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarnTab(),
          Center(child: Text("Redeem Page")),
          Center(child: Text("Offers Page")),
        ],
      ),
    );
  }

  Widget _buildEarnTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Panda Points Card
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
                    "148",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "PANDA POINTS®",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 148 / 200,
                    backgroundColor: Colors.white38,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "52 points to your next reward",
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
          // Locked Reward Section
        ],
      ),
    );
  }
}
