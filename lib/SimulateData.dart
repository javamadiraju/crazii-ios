import 'dart:math';
import 'package:intl/intl.dart';

import 'WebChartService.dart'; // Ensure this imports your MarketData class

class SimulateData {

  String generateSimulatedDowJonesData() {
    final random = Random();
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
/*
  String generateRandomDate() {
    final now = DateTime.now();
    final randomDate = now.subtract(Duration(
        days: random.nextInt(365), hours: random.nextInt(24), minutes: random.nextInt(60)));
    return dateFormat.format(randomDate);
  }
*/
    String generateRandomDate() {
      final now = DateTime.now();
      final randomDate = now.add(Duration(minutes: 1));
      return dateFormat.format(randomDate);
    }

    String generateRandomColor() {
      final colors = ['#FFFFFF', '#000000', '#FF0000', '#00FF00', '#0000FF'];
      return colors[random.nextInt(colors.length)];
    }

    String generateRandomDouble([int max = 10000]) {
      return (random.nextDouble() * max).toStringAsFixed(1);
    }

    int generateRandomInt([int max = 10000]) {
      return random.nextInt(max);
    }

    String generateRandomDouble2(double min, double max) {
      return (min + random.nextDouble() * (max - min)).toStringAsFixed(1);
    }

    List<String> data = [
      generateRandomInt(20000).toString(),
      '1',
      'DowJones.ca',
      '5',
      generateRandomDate(),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      '0',
      '0',
      '0',
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomDouble2(34000, 34200),
      generateRandomColor(),
      generateRandomDouble2(34000, 34200),
      '0',
      generateRandomDouble2(34000, 34200),
      '0',
      generateRandomDouble2(34000, 34200),
      '0',
      generateRandomDouble2(34000, 34200),
      '0',
      generateRandomDouble2(34000, 34200),
      generateRandomDate(),
      generateRandomDate(), //'1/1/70 0:00',
      generateRandomDate(),
      generateRandomDate(), //'1/1/70 0:00',
      '-${generateRandomDouble(1000)}',
      'BLUE',
      generateRandomDouble2(34000, 34200),
      generateRandomInt(200).toString(),
      generateRandomDouble(4),
      '0', 
      'GREEN',
      '|',
      generateRandomDate(),
      generateRandomDate()
    ];

    return data.join(',');
  }
}