import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/games_models.dart';

abstract class GamesRemoteDataSource {
  Future<List<SportsHouseModel>> getSportsHouses();
  Future<List<SportsCompetitionModel>> getRecentCompetitions();
  Future<void> updateHousePoints(String houseId, int points);
  Future<void> createCompetition(SportsCompetitionModel competition);
}

class GamesRemoteDataSourceImpl implements GamesRemoteDataSource {
  final FirebaseFirestore firestore;

  GamesRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<SportsHouseModel>> getSportsHouses() async {
    final snapshot = await firestore.collection('sports_houses').orderBy('totalPoints', descending: true).get();
    return snapshot.docs.map((doc) => SportsHouseModel.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<SportsCompetitionModel>> getRecentCompetitions() async {
    final snapshot = await firestore
        .collection('sports_competitions')
        .orderBy('date', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => SportsCompetitionModel.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> updateHousePoints(String houseId, int points) async {
    await firestore.collection('sports_houses').doc(houseId).update({
      'totalPoints': FieldValue.increment(points),
    });
  }

  @override
  Future<void> createCompetition(SportsCompetitionModel competition) async {
    await firestore.collection('sports_competitions').add(competition.toJson());
  }
}
