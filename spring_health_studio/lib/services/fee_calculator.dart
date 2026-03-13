import '../utils/constants.dart';

class FeeCalculator {
  static double? getFee(String branch, String category, String plan) {
    try {
      final fee = AppConstants.feeStructure[branch]?[category]?[plan];
      return fee == 0 ? null : fee;
    } catch (e) {
      return null;
    }
  }

  static List<String> getAvailablePlans(String branch, String category) {
    final plans = <String>[];
    final categoryFees = AppConstants.feeStructure[branch]?[category];

    if (categoryFees != null) {
      categoryFees.forEach((plan, fee) {
        if (fee > 0) {
          plans.add(plan);
        }
      });
    }

    return plans;
  }

  // Calculate final amount (totalFee - discount)
  static double calculateFinalAmount(double totalFee, double discount) {
    return totalFee - discount;
  }

  // Calculate how much was paid (finalAmount - dueAmount)
  static double calculatePaidAmount(double finalAmount, double dueAmount) {
    return finalAmount - dueAmount;
  }

  // Validate mixed payment against the paid amount
  static bool validateMixedPayment(double paidAmount, double cashAmount, double upiAmount) {
    return (cashAmount + upiAmount) == paidAmount;
  }
}
