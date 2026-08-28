import 'package:equatable/equatable.dart';

class ArpEntry extends Equatable {
  const ArpEntry({required this.ip, required this.mac});

  final String ip;
  final String mac;

  @override
  List<Object?> get props => [ip, mac];
}
