import 'package:memo_granja/models/card_pair.dart';

enum MemoryCardStatus { hidden, revealed, matched }

class MemoryCard {
  const MemoryCard({
    required this.instanceId,
    required this.pair,
    this.status = MemoryCardStatus.hidden,
  });

  final String instanceId;
  final CardPair pair;
  final MemoryCardStatus status;

  MemoryCard copyWith({MemoryCardStatus? status}) {
    return MemoryCard(
      instanceId: instanceId,
      pair: pair,
      status: status ?? this.status,
    );
  }
}
