import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class Destination extends Equatable {
  final String label;
  final IconData icon;

  const Destination({required this.label, required this.icon});

  @override
  List<Object?> get props => [label, icon];
}
