import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Spring Health Studio';
  static const String gymName = 'Spring Health Studio - Gym Management Pro';
  
  // Branches
  static const List<String> branches = ['Hanamkonda', 'Warangal'];
  
  // Categories
  static const List<String> categories = ['Cardio', 'Strength', 'Personal Training'];
  
  // Plans
  static const List<String> plans = ['1 Day', '1 Month', '3 Months', '6 Months', '1 Year'];
  
  // Payment Modes
  static const List<String> paymentModes = ['Cash', 'UPI', 'Mixed'];
  
  // Gender Options
  static const List<String> genders = ['Male', 'Female', 'Other'];
  
  // User Roles
  static const String roleOwner = 'Owner';
  static const String roleReceptionist = 'Receptionist';
  
  // Expiry Warning (days)
  static const int nearExpiryDays = 7;
  
  // Fee Structure
  static const Map<String, Map<String, Map<String, double>>> feeStructure = {
    'Hanamkonda': {
      'Cardio': {
        '1 Day': 150,
        '1 Month': 1700,
        '3 Months': 4500,
        '6 Months': 0,
        '1 Year': 0,
      },
      'Strength': {
        '1 Day': 100,
        '1 Month': 1200,
        '3 Months': 3000,
        '6 Months': 0,
        '1 Year': 0,
      },
      'Personal Training': {
        '1 Day': 0,
        '1 Month': 5000,
        '3 Months': 0,
        '6 Months': 0,
        '1 Year': 0,
      },
    },
    'Warangal': {
      'Cardio': {
        '1 Day': 200,
        '1 Month': 2000,
        '3 Months': 5000,
        '6 Months': 9000,
        '1 Year': 16000,
      },
      'Strength': {
        '1 Day': 150,
        '1 Month': 1500,
        '3 Months': 3600,
        '6 Months': 6000,
        '1 Year': 10000,
      },
      'Personal Training': {
        '1 Day': 0,
        '1 Month': 6000,
        '3 Months': 15000,
        '6 Months': 0,
        '1 Year': 0,
      },
    },
  };
  
  // Colors
  // Colors - Changed from const to static final
  static final List<Color> gradientColors = [
    const Color(0xFF6366F1),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];
}
