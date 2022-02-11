library jazzicon;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:jazzicon/color_hsl.dart';
import 'package:jazzicon/jazziconshape.dart';
import 'package:jazzicon/mersennetwister19937.dart';

const List<Color> colors = [
  Color(0x01888C), // teal             '#01888C', // teal
  Color(0xFC7500), // bright orange    '#FC7500', // bright orange
  Color(0x034F5D), // dark teal        '#034F5D', // dark teal
  Color(0xF73F01), // orangered        '#F73F01', // orangered
  Color(0xFC1960), // magenta          '#FC1960', // magenta
  Color(0xC7144C), // raspberry        '#C7144C', // raspberry
  Color(0xF3C100), // goldenrod        '#F3C100', // goldenrod
  Color(0x1598F2), // lightning blue   '#1598F2', // lightning blue
  Color(0x2465E1), // sail blue        '#2465E1', // sail blue
  Color(0xF19E02), // gold             '#F19E02', // gold
];

const int wobble = 30;

const int shapeCount = 4;


class Jazzicon {

  static JazziconData getJazziconData(double diameter, {int? seed, String? address}) {
    if (address != null && address
        .trim()
        .length > 0) {
      address = address.toLowerCase();
      if (address.startsWith("0x")) {
        String sub = address.substring(2, 10);
        seed = int.tryParse(sub, radix: 16);
        seed = MersenneTwister19937.unsigned32(seed! & 0xffffffff);
      }
    }
    print("seed=$seed");
    MersenneTwister19937 generator = MersenneTwister19937();
    generator.init_genrand(seed);

    List<Color> remainingColors = _hueShift(colors, generator);

    Color background = _genColor(remainingColors, generator);

    List<JazziconShape> shapelist = [];
    for (var i = 0; i < shapeCount - 1; i++) {
      JazziconShape shape = _genShape(remainingColors, diameter, i, shapeCount - 1, generator);
      print(shape);
      shapelist.add(shape);
    }

    JazziconData jd = JazziconData(size: diameter, background: background, shapelist: shapelist);
    return jd;
  }

  static List<Color> _hueShift(List<Color> colors, MersenneTwister19937 generator) {
    double amount = (generator.random() * 30) - (wobble / 2);
    List<Color> _colors = colors.map((color) {
      return colorRotate(color, amount);
    }).toList();
    return _colors;
  }

  static Color _genColor(List<Color> colors, MersenneTwister19937 generator) {
    double rand = generator.random();
    double r1 = generator.random();
    int idx = (colors.length * r1).floor();
    Color color = colors[idx];
    colors.removeAt(idx);
    return color;
  }

  static JazziconShape _genShape(List<Color> remainingColors, double diameter, int i, int total,
      MersenneTwister19937 generator) {
    double center = diameter / 2;


    double firstRot = generator.random();
    double angle = pi * 2 * firstRot;
    double velocity = diameter / total * generator.random() + (i * diameter / total);

    double tx = cos(angle) * velocity;
    double ty = sin(angle) * velocity;

    double secondRot = generator.random();
    double rot = (firstRot * 360) + secondRot * 180;
    Color fill = _genColor(remainingColors, generator);

    return JazziconShape(center: center,
        tx: tx,
        ty: ty,
        rotate: double.parse(rot.toStringAsFixed(1)),
        fill: fill);
  }

  static Widget getIconWidget(JazziconData jd, {double? size}) {
    double scale = 1;
    if (size != null) {
      scale = size / jd.size;
    }

    return StatefulBuilder(
      builder: (context, setState) {
        Widget view = ClipOval(
          child: Container(
            width: size ?? jd.size,
            height: size ?? jd.size,
            color: jd.background,
            child: Stack(
              children: jd.shapelist.map((shape) {
                Widget sp = Container(
                  width: size ?? jd.size,
                  height: size ?? jd.size,
                  color: shape.fill,
                );

                Widget sp_r = Transform.rotate(
                  angle: shape.rotate / 360 * 2 * pi,
                  // origin: Offset(shape.center, shape.center),
                  child: sp,
                );
                Widget sp_t = Transform.translate(
                  offset: Offset(shape.tx * scale, shape.ty * scale),
                  child: sp_r,
                );
                return Positioned(left: 0, right: 0, child: sp_t);
              }).toList(),
            ),
          ),
        );
        return view;
      },
    );
  }
}
