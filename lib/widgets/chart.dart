import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/chart_bar.dart';
import '../modals/transaction.dart';

class Chart extends StatelessWidget {
  final List<Transaction> recentTransactions;

  Chart(this.recentTransactions);

  // Chart Logic
  List<Map<String, Object>> get groupTransactionValues {
    return List.generate(7, (index) {
      /*
      weekDate is getting the current date and then subtracting the index from
      it to get the previous date of the week i.e getting the complete previous
      week.
      Like for eg if index = 1 then current date - 1 = yesterday
       */
      final weekDate = DateTime.now().subtract(Duration(days: index));
      var totalSum = 0.0;

      // Finding the transactions done on weekDate
      for (var i = 0; i < recentTransactions.length; i++) {
        if (recentTransactions[i].date.day == weekDate.day &&
            recentTransactions[i].date.month == weekDate.month &&
            recentTransactions[i].date.year == weekDate.year) {
          totalSum += recentTransactions[i].amount;
        }
      }

      return {
        'day': DateFormat.E().format(weekDate).substring(0, 1),
        'amount': totalSum,
      };
    });
  }

  double get totalSpending {
    return groupTransactionValues.fold(0.0, (sum, element) {
      return sum + element['amount'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: groupTransactionValues.map((data) {
            return Flexible(
              fit: FlexFit.tight,
              child: ChartBar(
                data['day'],
                data['amount'],
                totalSpending == 0.0
                    ? 0.0
                    : (data['amount'] as double) / totalSpending,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
