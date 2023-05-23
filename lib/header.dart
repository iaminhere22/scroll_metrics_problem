import 'package:flutter/material.dart';

import 'sizes.dart';
import 'constants.dart';
import 'model.dart';

// ignore: must_be_immutable
class PageHeader extends StatelessWidget {
  PageHeader({super.key, required this.model});

  final Model model;
  late double curHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final double headerHeight = constraints.biggest.height;
      final double monthToWeek = (Constants.maxHeight - headerHeight) / (Constants.maxHeight - Constants.minHeight);
      curHeight = Constants.mainHeight - monthToWeek * Constants.cellHeight * 5;

      return CustomMultiChildLayout(
        delegate: _CalendarLayoutDelegate(
          model: model,
          monthToWeek: monthToWeek,
        ),
        children: [
          LayoutId(id: Constants.main, child: buildMonthCalendar()),
          LayoutId(id: Constants.cell, child: buildWeekCalendar()),
          LayoutId(id: Constants.title, child: buildCalHeader(context)),
          LayoutId(id: Constants.bar, child: _buildTopBar(context)),
        ],
      );
    });
  }

  Widget buildWeekCalendar() {
    int weekCount = 5;
    int curWeekNum = 2;
    final double rowFlex = (6 - weekCount) / 6 / (weekCount - 1) * 24 + 4;
    return Visibility(
      visible: Constants.mainHeight - curHeight <=
          (Constants.mainHeight * rowFlex / 24) * curWeekNum + (curWeekNum == 0 ? 0.1 : -0.1)
          ? false
          : true,
      child: Container(
        color: Colors.redAccent,
        height: Constants.cellHeight,
      ),
    );
  }

  Widget buildMonthCalendar() {
    return Visibility(
      visible: curHeight < Constants.cellHeight ? false : true,
      child: ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: curHeight / Constants.mainHeight,
          child: Container(
            color: Colors.blueAccent,
            height: Constants.mainHeight,
          ),
        ),
      ),
    );
  }

  Widget buildCalHeader(BuildContext context) {
    return Container(
      color: Colors.yellowAccent,
      height: Constants.cellHeight / 2,
      padding: EdgeInsets.only(right: Constants.space * 2),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.pinkAccent,
      height: Sizes.topBarHeight,
    );
  }
}

class _CalendarLayoutDelegate extends MultiChildLayoutDelegate {
  _CalendarLayoutDelegate({
    required this.model,
    required this.monthToWeek,
  });

  final Model model;
  final double monthToWeek;

  Offset _interpolatePoint(Offset begin, Offset end) => Offset.lerp(begin, end, monthToWeek)!;

  Rect _interpolateRect(Rect begin, Rect end) => Rect.lerp(begin, end, monthToWeek)!;

  @override
  void performLayout(Size size) {
    Rect weekRect = Rect.fromLTWH(0, 0, Sizes.screenWidth, Constants.cellHeight);
    Rect monthRect = Rect.fromLTWH(0, 0, Sizes.screenWidth, Constants.mainHeight);

    positionChild(Constants.bar, Offset(0, Sizes.statusBarHeight));
    layoutChild(Constants.bar, BoxConstraints.loose(weekRect.size));
    positionChild(Constants.title, Offset(0, Sizes.topSumHeight));
    layoutChild(Constants.title, BoxConstraints.loose(weekRect.size));
    Offset calOffset = Offset(0, Sizes.topSumHeight + Constants.cellHeight / 2);
    positionChild(Constants.main, calOffset);
    layoutChild(Constants.main, BoxConstraints.loose(monthRect.size));
    positionChild(Constants.cell, calOffset);
    layoutChild(Constants.cell, BoxConstraints.loose(weekRect.size));
  }

  @override
  bool shouldRelayout(_CalendarLayoutDelegate oldDelegate) {
    return monthToWeek != oldDelegate.monthToWeek;
  }
}
