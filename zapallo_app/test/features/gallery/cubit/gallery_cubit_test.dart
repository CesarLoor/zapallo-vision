import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zapallo_app/core/database/app_database.dart';
import 'package:zapallo_app/core/repositories/gallery_repository.dart';
import 'package:zapallo_app/features/gallery/cubit/gallery_cubit.dart';
import 'package:zapallo_app/features/gallery/cubit/gallery_state.dart';

class _MockGalleryRepository extends Mock implements GalleryRepository {}

void main() {
  late GalleryRepository repository;
  late GalleryCubit cubit;

  setUp(() {
    repository = _MockGalleryRepository();
    cubit = GalleryCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('GalleryCubit', () {
    test('initial state is GalleryLoading', () {
      expect(cubit.state, const GalleryLoading());
    });

    test('loadImages emits loading then loaded with images', () async {
      final images = <LeafImage>[];
      when(() => repository.countImages()).thenAnswer((_) async => 0);
      when(() => repository.getImagesPage(limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => images);

      final expectedStates = [
        const GalleryLoading(),
        GalleryLoaded(images, totalCount: 0),
      ];

      expectLater(
        cubit.stream,
        emitsInOrder(expectedStates),
      );

      await cubit.loadImages();
    });

    test('loadImages emits GalleryError on failure', () async {
      when(() => repository.countImages()).thenThrow(Exception('DB error'));

      final expectedStates = [
        const GalleryLoading(),
        const GalleryError('Error al cargar las imágenes.'),
      ];

      expectLater(
        cubit.stream,
        emitsInOrder(expectedStates),
      );

      await cubit.loadImages();
    });

    test('loadMore appends images when hasMore is true', () async {
      final page1 = List.generate(20, (i) => _createTestImage('id_$i'));
      final page2 = List.generate(5, (i) => _createTestImage('more_$i'));

      when(() => repository.countImages()).thenAnswer((_) async => 25);
      when(() => repository.getImagesPage(limit: 20, offset: 0))
          .thenAnswer((_) async => page1);
      when(() => repository.getImagesPage(limit: 20, offset: 20))
          .thenAnswer((_) async => page2);

      await cubit.loadImages();
      final state1 = cubit.state as GalleryLoaded;
      expect(state1.images.length, 20);
      expect(state1.hasMore, isTrue);

      await cubit.loadMore();
      final state2 = cubit.state as GalleryLoaded;
      expect(state2.images.length, 25);
      expect(state2.hasMore, isFalse);
    });

    test('deleteImage removes image and reloads', () async {
      final images = [_createTestImage('id_1')];

      when(() => repository.countImages()).thenAnswer((_) async => 1);
      when(() => repository.getImagesPage(limit: 20, offset: 0))
          .thenAnswer((_) async => images);
      when(() => repository.deleteImage(images[0]))
          .thenAnswer((_) async => true);

      await cubit.loadImages();
      expect(cubit.state is GalleryLoaded, isTrue);

      await cubit.deleteImage(images[0]);
      expect(cubit.state is GalleryLoaded, isTrue);
    });
  });
}

LeafImage _createTestImage(String id) {
  return LeafImage(
    id: id,
    filePath: '/tmp/$id.jpg',
    capturedAt: DateTime.now(),
    fileSize: 1024,
    width: 1920,
    height: 1080,
  );
}
