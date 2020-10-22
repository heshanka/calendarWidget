import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

//list of rows, activerow,
//add collapse
//offset + currentday

class CustomCalendar extends StatefulWidget {
  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar>
    with TickerProviderStateMixin {
  //func is "a * (w-v) + v"
  // v is base value
  // w is final value

  bool _expanded;
  double collapsedHeightFactor;
  double activeRowYPosition;
  DateTime displayDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime showDate;
  int activeRow;
  List<Widget> calList;
  PageController pageController = PageController(initialPage: 0);

  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeInOut);

  AnimationController _controller;
  Animation<double> _anim;
  Animation<Color> _arrowColor;
  Animation<double> _iconTurns;
  Animation<Color> _monthColor;
  AnimationController _monthController;

  static const Duration _kExpand = Duration(milliseconds: 300);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  ValueChanged<bool> onExpansionChanged;
  Animatable<Color> _arrowColorTween =
      ColorTween(begin: Color(0x00FFA68A), end: Color(0xffFFA68A));
  Animatable<Color> _monthColorTween =
      ColorTween(begin: Color(0xffEC520B), end: Color(0x00EC520B));

  //TODO generate the row list only once please!!
  @override
  void initState() {
    _expanded = false;
    showDate = displayDate;
    List<Widget> rowListReturned = returnRowList(DateTime(displayDate.year, displayDate.month, 1));
    collapsedHeightFactor = 1 / rowListReturned.length;
    activeRowYPosition = ((2 / (rowListReturned.length - 1)) * getActiveRow()) - 1;
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _monthController = AnimationController(duration: _kExpand, vsync: this);
    _anim = _controller.drive(_easeInTween);
    _arrowColor = _controller.drive(_arrowColorTween.chain(_easeInTween));
    //icon stuff
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _monthColor = _monthController.drive(_monthColorTween.chain(_easeInTween));

    //initial value = false
    _expanded = PageStorage.of(context)?.readState(context) ?? false;
    if (_expanded) _controller.value = 1.0;
    calList = [
      Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: rowListReturned)
    ];
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double calendarWidth = MediaQuery.of(context).size.width * 0.85;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 13, bottom: 8, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          enableFeedback: _expanded,
                          splashRadius: _expanded ? 15.0 : 0.001,
                          icon: AnimatedBuilder(
                            animation: _arrowColor,
                            builder: (BuildContext context, Widget child) =>
                                SvgPicture.asset(
                              'images/leftArrow.svg',
                              color: _arrowColor.value,
                            ),
                          ),
                          onPressed: () {
                            if (_expanded) {
                              DateTime curr = showDate;
                              setState(() {
                                calList = [
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: returnRowList(DateTime(
                                          showDate.year,
                                          showDate.month - 1,
                                          1))),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: returnRowList(DateTime(
                                          showDate.year, showDate.month, 1))),
                                ];
                                print(calList.length);
                                showDate = DateTime(
                                    showDate.year, showDate.month - 1, 1);
                              });
                              if (areMonthsSame(curr, DateTime.now())) {
                                _monthController.forward();
                                Future.delayed(Duration(milliseconds: 1), () {
                                  setState(() {});
                                });
                              } else if (areMonthsSame(
                                  showDate, DateTime.now())) {
                                _monthController.reverse();
                                Future.delayed(_kExpand, () {
                                  setState(() {});
                                });
                              }
                              pageController.jumpToPage(1);

                              pageController.previousPage(
                                  duration: _kExpand, curve: Curves.easeInOut);
                            }
                          },
                        ),
                      ),
                      Text(formatDate(showDate),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          enableFeedback: _expanded,
                          splashRadius: _expanded ? 15.0 : 0.001,
                          icon: AnimatedBuilder(
                            animation: _arrowColor,
                            builder: (BuildContext context, Widget child) =>
                                SvgPicture.asset(
                              'images/rightArrow.svg',
                              color: _arrowColor.value,
                            ),
                          ),
                          onPressed: () {
                            if (_expanded) {
                              DateTime curr = showDate;
                              setState(() {
                                calList = [
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: returnRowList(DateTime(
                                          showDate.year, showDate.month, 1))),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: returnRowList(DateTime(
                                          showDate.year,
                                          showDate.month + 1,
                                          1))),
                                ];
                                print(calList.length);
                                showDate = DateTime(
                                    showDate.year, showDate.month + 1, 1);
                              });

                              if (areMonthsSame(curr, DateTime.now())) {
                                _monthController.forward();
                                Future.delayed(Duration(milliseconds: 1), () {
                                  setState(() {});
                                });
                              } else if (areMonthsSame(
                                  showDate, DateTime.now())) {
                                _monthController.reverse();
                                Future.delayed(_kExpand, () {
                                  setState(() {});
                                });
                              }
                              pageController.jumpToPage(0);
                              pageController.nextPage(
                                  duration: _kExpand, curve: Curves.easeInOut);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller.view,
                builder: (BuildContext context, Widget child) => Container(
                    child: ClipRect(
                  child: Align(
                    alignment: Alignment(0.5, activeRowYPosition),
                    heightFactor: _anim.value * (1 - collapsedHeightFactor) +
                        collapsedHeightFactor,
                    child: Container(
                      width: calendarWidth,
                      height: calendarWidth * 0.76,
                      child: PageView(
                        controller: pageController,
                        scrollDirection: Axis.horizontal,
                        children: calList,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                    ),
                  ),
                )),
              )
            ],
          ),
        ),
        IconButton(
          splashRadius: _monthController.view.value == 0.0 ? 18.0 : 0.001,
          onPressed: _monthController.view.value == 0.0 ? _handleTap : null,
          enableFeedback: _monthController.view.value == 0.0,
          icon: AnimatedBuilder(
            animation: _monthColor,
            builder: (BuildContext context, Widget child) =>
                RotationTransition(
              turns: _iconTurns,
              child: Icon(
                Icons.expand_more,
                size: 35,
                color: _monthColor.value,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String formatDate(DateTime date) => new DateFormat("MMMM yyyy").format(date);

  void _handleTap() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _expanded);
    });
    if (onExpansionChanged != null) onExpansionChanged(_expanded);
  }

  int getActiveRow() {
    List<List<int>> rowValueList =
        generateCurrentMonth(DateTime(displayDate.year, displayDate.month, 1));
    for (int i = 0; i < rowValueList.length; i++) {
      if (displayDate.month == DateTime.now().month &&
          rowValueList[i].contains(DateTime.now().day)) {
        activeRow = i + 1;
      }
    }
    return activeRow;
  }

  List<List<int>> generateCurrentMonth(DateTime firstOfMonth) {
    //int numDaysCurrentMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    List<List<int>> rowValueList = [];

    //DateTime firstOfMonth =  DateTime(displayyDate.year, displayyDate.month, 1);

    //Adding the first week
    DateTime endWeek =
        firstOfMonth.add(Duration(days: 7 - firstOfMonth.weekday));
    DateTime startWeek = endWeek.subtract(Duration(days: 6));
    List<int> first = [];
    for (DateTime j = startWeek;
        j.compareTo(endWeek) <= 0;
        j = j.add(Duration(days: 1))) {
      first.add(j.day);
    }
    rowValueList.add(first);

    //Moving the counters
    int i = endWeek.day + 1;
    endWeek = endWeek.add(Duration(days: 7));

    //Looping to add the other weeks inside the month
    while (endWeek.month == firstOfMonth.month) {
      List<int> temp = [];
      for (int j = i; j <= endWeek.day; j++) {
        temp.add(j);
      }
      rowValueList.add(temp);
      i = 1 + endWeek.day;
      endWeek = endWeek.add(Duration(days: 7));
    }

    //Adding the last week
    List<int> last = [];
    startWeek = endWeek.subtract(Duration(days: 6));
    for (DateTime j = startWeek;
        j.compareTo(endWeek) <= 0;
        j = j.add(Duration(days: 1))) {
      last.add(j.day);
    }
    rowValueList.add(last);
    //print(rowValueList);
    return rowValueList;
  }

  List<Widget> returnRowList(DateTime start) {
    List<Widget> rowList = <Widget>[
      Padding(
        //do not change this padding
        padding: const EdgeInsets.only(bottom: 22, left: 36, right: 36),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            calendarWeekday('Mon'),
            calendarWeekday('Tue'),
            calendarWeekday('Wed'),
            calendarWeekday('Thu'),
            calendarWeekday('Fri'),
            calendarWeekday('Sat'),
            calendarWeekday('Sun'),
          ],
        ),
      ),
    ];
    List<List<int>> rowValueList = generateCurrentMonth(start);
    for (int i = 0; i < rowValueList.length; i++) {
      List<Widget> itemList = [];
      for (int j = 0; j < rowValueList[i].length; j++) {
        itemList.add(Expanded(
          child: Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rowValueList[i][j] == DateTime.now().day &&
                          start.month == DateTime.now().month &&
                          start.year == DateTime.now().year
                      ? Color(0xffFFA68A)
                      : Colors.transparent),
              child: Center(
                child: Text(
                  rowValueList[i][j].toString(),
                  style: (rowValueList[i][j] == DateTime.now().day &&
                          start.month == DateTime.now().month &&
                          start.year == DateTime.now().year)
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                        )
                      : TextStyle(
                          fontWeight: FontWeight.normal,
                          color: ((i == 0 && rowValueList[i][j] > 7) ||
                                  (i >= 4 && rowValueList[i][j] < 7))
                              ? Colors.grey
                              : Colors.black),
                  textAlign: TextAlign.center,
                ),
              )),
        ));
      }
      Widget temp = Padding(
          //this padding seems important
          padding: EdgeInsets.only(bottom: 12, left: 36, right: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: itemList,
          ));
      rowList.add(temp);
    }
    return rowList;
  }

  Widget calendarWeekday(String day) {
    return Text(
      day,
      style: TextStyle(fontSize: 11, color: Color(0xff828282)),
    );
  }

  bool areDaysSame(DateTime a, DateTime b) {
    return areMonthsSame(a, b) && a.day == b.day;
  }

  bool areMonthsSame(DateTime a, DateTime b) {
    return areYearsSame(a, b) && a.month == b.month;
  }

  bool areYearsSame(DateTime a, DateTime b) {
    return a.year == b.year;
  }
}
