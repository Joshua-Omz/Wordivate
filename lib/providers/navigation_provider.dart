
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the currently selected navigation index
final navigationProvider = StateProvider<int>((ref) => 0);