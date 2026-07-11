import 'package:flutter_test/flutter_test.dart';
import 'package:leloms_app/providers/sanctuary_provider.dart';

void main() {
  late SanctuaryProvider provider;

  setUp(() {
    provider = SanctuaryProvider();
  });

  group('SanctuaryProvider', () {
    test('initial values are correct', () {
      expect(provider.totalXp, 0);
      expect(provider.petCount, 0);
      expect(provider.feedCount, 0);
      expect(provider.playCount, 0);
      expect(provider.catMood, CatMood.idle);
      expect(provider.isTreeWatered, false);
    });

    group('treeStage', () {
      test('starts at seed', () {
        expect(provider.treeStage, TreeStage.seed);
      });

      test('becomes sprout at 100 XP', () {
        provider.addXp(100);
        expect(provider.treeStage, TreeStage.sprout);
      });

      test('becomes sapling at 300 XP', () {
        provider.addXp(300);
        expect(provider.treeStage, TreeStage.sapling);
      });

      test('becomes young at 600 XP', () {
        provider.addXp(600);
        expect(provider.treeStage, TreeStage.young);
      });

      test('becomes mature at 1000 XP', () {
        provider.addXp(1000);
        expect(provider.treeStage, TreeStage.mature);
      });

      test('becomes ancient at 2000 XP', () {
        provider.addXp(2000);
        expect(provider.treeStage, TreeStage.ancient);
      });
    });

    group('treeStageName', () {
      test('returns correct name for each stage', () {
        expect(provider.treeStageName, 'Semilla');
        provider.addXp(100);
        expect(provider.treeStageName, 'Brote');
        provider.addXp(200);
        expect(provider.treeStageName, 'Árbol Joven');
        provider.addXp(300);
        expect(provider.treeStageName, 'Árbol en Crecimiento');
        provider.addXp(400);
        expect(provider.treeStageName, 'Árbol Maduro');
        provider.addXp(1000);
        expect(provider.treeStageName, 'Árbol Ancestral');
      });
    });

    group('treeProgress', () {
      test('returns 0 for seed', () {
        expect(provider.treeProgress, 0.0);
      });

      test('returns correct progress within a stage', () {
        provider.addXp(50);
        expect(provider.treeProgress, 0.5);
      });

      test('returns 1.0 for ancient', () {
        provider.addXp(2000);
        expect(provider.treeProgress, 1.0);
      });
    });

    group('cat interactions', () {
      test('petCat increments count and sets mood', () {
        provider.petCat();
        expect(provider.petCount, 1);
        expect(provider.catMood, CatMood.happy);
      });

      test('feedCat increments count and sets mood', () {
        provider.feedCat();
        expect(provider.feedCount, 1);
        expect(provider.catMood, CatMood.eating);
      });

      test('playWithCat increments count and sets mood', () {
        provider.playWithCat();
        expect(provider.playCount, 1);
        expect(provider.catMood, CatMood.playing);
      });
    });

    test('waterTree sets isTreeWatered to true', () {
      provider.waterTree();
      expect(provider.isTreeWatered, true);
    });

    test('addStudyXp adds 5x minutes to totalXp', () {
      provider.addStudyXp(30);
      expect(provider.totalXp, 150);
    });
  });
}
