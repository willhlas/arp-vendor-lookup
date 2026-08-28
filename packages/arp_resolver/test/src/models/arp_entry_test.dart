import 'package:arp_resolver/arp_resolver.dart';
import 'package:test/test.dart';

void main() {
  group(ArpEntry, () {
    test('supports value equality when ip and mac match', () {
      const a = ArpEntry(ip: '192.168.1.1', mac: '5c:35:fc:e1:ee:94');
      const b = ArpEntry(ip: '192.168.1.1', mac: '5c:35:fc:e1:ee:94');

      expect(a, equals(b));
    });

    test('is not equal when mac differs', () {
      const a = ArpEntry(ip: '192.168.1.1', mac: '5c:35:fc:e1:ee:94');
      const b = ArpEntry(ip: '192.168.1.1', mac: '00:00:00:00:00:00');

      expect(a, isNot(equals(b)));
    });
  });
}
