// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'container_hand.dart';
import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}


class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;


  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor: Color.fromARGB(255, 244, 200, 200),
            highlightColor: Color.fromARGB(255, 180, 155, 235),
            accentColor: Color.fromARGB(255, 252, 133, 120),
            backgroundColor: Color.fromARGB(205, 25, 15, 75),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color.fromARGB(245, 15, 155, 165),
            highlightColor: Color.fromARGB(255, 220, 122, 125),
            accentColor: Color.fromARGB(255, 225, 105, 125),
            backgroundColor: Color.fromARGB(155, 32, 35, 115),
          );
    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = DefaultTextStyle(
      style: TextStyle(
          color: Color.fromARGB(255, 180, 190, 200),
          fontFamily: "QuickSand",
          fontSize: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_condition),
          Text(_location),
        ],
      ),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Stack(
          children: [
            ContainerHand(
              color: Colors.transparent,
              size: 0.9,
              angleRadians: _now.minute * radiansPerTick,
              child: Transform.translate(
                offset: Offset(0.0, -100.0),
                child: Container(
                  width: 12,
                  height: 150,
                  decoration: BoxDecoration(
                    color: customTheme.highlightColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ), //Minute hand
            ContainerHand(
              color: Colors.transparent,
              size: 0.8,
              angleRadians: _now.hour * radiansPerHour +
                  (_now.minute / 60) * radiansPerHour,
              child: Transform.translate(
                offset: Offset(0.0, -80.0),
                child: Container(
                  width: 12,
                  height: 80,
                  decoration: BoxDecoration(
                    color: customTheme.primaryColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
            ContainerHand(
              color: Colors.transparent,
              size: 1,
              angleRadians: _now.second * radiansPerTick,
              child: Transform.translate(
                offset: Offset(0.0, -180.0),
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: customTheme.accentColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ), //Second hand
            Positioned(
              left: 22,
              bottom: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: weatherInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
