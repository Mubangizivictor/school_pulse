import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/games_state.dart';

abstract class GamesRemoteDataSource {
  Future<List<SportsFixture>> getUpcomingFixtures();
  Future<Map<String, dynamic>> getGamesStats();
}

class GamesRemoteDataSourceImpl implements GamesRemoteDataSource {
  final FirebaseFirestore firestore;

  GamesRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<SportsFixture>> getUpcomingFixtures() async {
    final snapshot = await firestore
        .collection('sports_fixtures')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('timestamp')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SportsFixture(
        sport: data['sport'] ?? '',
        opponent: data['opponent'] ?? '',
        date: data['date'] ?? '',
        venue: data['venue'] ?? '',
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getGamesStats() async {
    final doc = await firestore.collection('stats').doc('games_summary').get();
    return doc.data() ?? {};
  }
}
