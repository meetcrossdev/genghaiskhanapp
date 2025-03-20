import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/features/onboarding/driveads.dart';
import 'package:gzresturent/features/onboarding/empowerads.dart';
import 'package:gzresturent/features/onboarding/rideads.dart';


class OnStartingScreen extends ConsumerStatefulWidget {
  const OnStartingScreen({super.key});
 static const routeName = '/onstarting-screen';
  static const List<Tab> tabs = [
    Tab(
      text: 'Driving',
    ),
    Tab(
      text: 'Empower',
    ),
    Tab(
      text: 'Ride',
    ),
  ];

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnStartingScreenState();
}

class _OnStartingScreenState extends ConsumerState<OnStartingScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: OnStartingScreen.tabs.length,
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {}
          });
          return Scaffold(
            body: TabBarView(children: [
              DriveAdsScreen(
                tabController: tabController,
              ),
              EmpowerAdsScreen(
                tabController: tabController,
              ),
              RideadsScreen(
                tabController: tabController,
              ),
            ]),
          );
        },
      ),
    );
  }
}
