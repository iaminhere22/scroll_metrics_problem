import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'header.dart';
import 'sizes.dart';
import 'constants.dart';
import 'model.dart';

const Duration _kScrollDuration = const Duration(milliseconds: 400);
const Curve _kScrollCurve = Curves.fastOutSlowIn;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final PageController _headingPageController = PageController();
  final PageController _detailsPageController = PageController();
  late Model model;
  ScrollPhysics _headingScrollPhysics = const NeverScrollableScrollPhysics();
  ValueNotifier<double> selectedIndex = ValueNotifier<double>(0.0);
  bool _expanded = false;

  double get appBarMaxHeight => Constants.maxHeight;

  @override
  void initState() {
    model = Provider.of(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double designWidth = 1080; // 1080 x 1920
    final double designHeight = size.height * 1080 / size.width;
    ScreenUtil.init(
      context,
      designSize: Size(designWidth, designHeight),
      minTextAdapt: true,
    );
    return Scaffold(
      body: Builder(
        // Insert an element so that _buildBody can find the PrimaryScrollController.
        builder: buildNestedView,
      ),
    );
  }

  Widget buildNestedView(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      // onNotification: (ScrollNotification notification) {
      //   return _handleScrollNotification(notification, appBarMinScrollOffset);
      // },
      child: NestedScrollView(
        physics: _SnappingScrollPhysics(model: model, maxHeight: Constants.maxHeight, minHeight: Constants.minHeight),
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: Constants.minHeight,
                maxHeight: Constants.maxHeight,
                child: NotificationListener<ScrollNotification>(
                  // onNotification: (ScrollNotification notification) {
                  //   return _handlePageNotification(notification, _headingPageController, _detailsPageController);
                  // },
                  child: PageHeader(
                    model: model,
                  ),
                ),
              ),
            )
          ];
        },
        body: NotificationListener<ScrollNotification>(
          // onNotification: (ScrollNotification notification) {
          //   return _handlePageNotification(notification, _detailsPageController, _headingPageController);
          // },
          child: PageView(
            controller: _detailsPageController,
            children: [Container()].map((w) {
              return Container(
                color: Colors.white10,
                padding: EdgeInsets.only(top: Sizes.statusBarHeight),
                child: ListView.builder(
                  itemCount: 16,
                  padding: EdgeInsets.only(top: Sizes.topBarHeight),
                  itemBuilder: (ctx, index) {
                    return Container(
                      height: Sizes.screenHeight / 10,
                      alignment: Alignment.centerLeft,
                      child: Text("Item $index"),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SnappingScrollPhysics extends ClampingScrollPhysics {
  const _SnappingScrollPhysics({super.parent, required this.model, required this.maxHeight, required this.minHeight});

  final Model model;
  final double maxHeight;
  final double minHeight;

  double get maxScrollOffset => maxHeight - minHeight;

  @override
  ClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnappingScrollPhysics(
      parent: buildParent(ancestor),
      model: model,
      maxHeight: maxHeight,
      minHeight: minHeight,
    );
  }

  Simulation _toMaxScrollOffsetSimulation(double offset, double dragVelocity) {
    final double velocity = math.max(dragVelocity, minFlingVelocity);
    print("toMax: offset: $offset, velocity: $velocity");
    return ScrollSpringSimulation(spring, offset, maxScrollOffset, velocity, tolerance: tolerance);
  }

  Simulation _toZeroScrollOffsetSimulation(double offset, double dragVelocity) {
    final double velocity = math.min(dragVelocity, minFlingVelocity);
    print("toZero: offset: $offset, velocity: $velocity");
    return ScrollSpringSimulation(spring, offset, 0, velocity, tolerance: tolerance);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double dragVelocity) {
    print("ScrollMetrics: $position");
    print("ScrollMetrics direction: ${position.axisDirection}");
    Simulation? simulation = super.createBallisticSimulation(position, dragVelocity);
    final double offset = position.pixels;
    print("dragVelocity: $dragVelocity");

    if (simulation != null) {
      final double simulationEnd = simulation.x(double.infinity);
      if (dragVelocity > 0.0) {
        print("dragVelocity > 0.0");
        simulation = _toMaxScrollOffsetSimulation(offset, dragVelocity);
      }
      if (dragVelocity < 0.0) {
        print("dragVelocity < 0.0");
        simulation = _toZeroScrollOffsetSimulation(offset, dragVelocity);
      }
    } else {
      final double snapThreshold = maxScrollOffset / 8;
      final double dist = model.oldSimulation - offset;
      if (offset >= snapThreshold && dist < 0) {
        print("offset >= snapThreshold && dist < 0");
        simulation = _toMaxScrollOffsetSimulation(offset, dragVelocity);
      } else if (offset <= maxScrollOffset - snapThreshold) {
        print("offset <= maxScrollOffset - snapThreshold");
        simulation = _toZeroScrollOffsetSimulation(offset, dragVelocity);
      }
    }
    model.oldSimulation = simulation?.x(double.infinity) ?? model.oldSimulation;
    print("simulation.x: ${simulation?.x(double.infinity)}");
    return simulation;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.minHeight, required this.maxHeight, required this.child});

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }

  @override
  String toString() => '_SliverAppBarDelegate';
}
