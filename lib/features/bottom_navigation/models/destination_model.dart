import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class Destination extends Equatable {

  const Destination({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  List<Object?> get props => [label, icon];
}
