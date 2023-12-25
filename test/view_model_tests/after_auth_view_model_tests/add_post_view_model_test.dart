// ignore_for_file: talawa_api_doc, avoid_dynamic_calls
// ignore_for_file: talawa_good_doc_comments

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/services/third_party_service/multi_media_pick_service.dart';
import 'package:talawa/utils/post_queries.dart';
import 'package:talawa/view_model/after_auth_view_models/add_post_view_models/add_post_view_model.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/test_locator.dart';

/// Mocks MockCallbackFunction.
class MockCallbackFunction extends Mock {
  /// Mock Call Function.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  ///   None
  void call();
}

void main() {
  testSetupLocator();
  setUp(() {
    registerServices();
  });
  group("AddPostViewModel Test - ", () {
    test("Check if it's initialized correctly", () {
      final model = AddPostViewModel();
      model.initialise();

      expect(model.imageFile, null);
      expect(model.orgName, userConfig.currentOrg.name);
      expect(
        model.userName,
        userConfig.currentUser.firstName! + userConfig.currentUser.lastName!,
      );
    });
    test("Check if getImageFromGallery() is working fine", () async {
      final model = AddPostViewModel();
      model.initialise();

      when(locator<MultiMediaPickerService>().getPhotoFromGallery())
          .thenAnswer((_) async {
        return null;
      });

      await model.getImageFromGallery();
      verify(locator<MultiMediaPickerService>().getPhotoFromGallery());
      expect(model.imageFile, null);
    });
    test("Check if getImageFromGallery() is working fine (camera is true)",
        () async {
      final notifyListenerCallback = MockCallbackFunction();
      final model = AddPostViewModel()..addListener(notifyListenerCallback);
      model.initialise();

      final file = File('fakePath');
      when(locator<MultiMediaPickerService>().getPhotoFromGallery(camera: true))
          .thenAnswer((_) async {
        return file;
      });

      await model.getImageFromGallery(camera: true);

      verify(
        locator<MultiMediaPickerService>().getPhotoFromGallery(camera: true),
      );
      verify(
        locator<NavigationService>().showTalawaErrorSnackBar(
          "Image is added",
          MessageType.info,
        ),
      );

      expect(model.imageFile, file);

      verify(notifyListenerCallback());
    });
    test("Check if upload post works correctly", () async {
      final notifyListenerCallback = MockCallbackFunction();
      final model = AddPostViewModel()..addListener(notifyListenerCallback);
      model.initialise();

      await model.uploadPost();
      verify(
        locator<NavigationService>().showTalawaErrorSnackBar(
          "Post is uploaded",
          MessageType.info,
        ),
      );
      // verify(
      //   locator<DataBaseMutationFunctions>().gqlAuthMutation(
      //     query,
      //     variables: {
      //       "text": "",
      //       "organizationId": "XYZ",
      //       "title": "",
      //       "file":"",
      //     },
      //   ),
      // );
      verify(notifyListenerCallback());
    });
    test('uploadPost with _imageFile != null and throws no exception',
        () async {
      final viewModel = AddPostViewModel();
      viewModel.initialise();
      final mockImageFile = File(
        'path/to/mockImage.png',
      );
      viewModel.setImageFile(mockImageFile);

      await viewModel.setImageInBase64(mockImageFile);

      viewModel.controller.text = "Some post content";
      viewModel.textHashTagController.text = "hashtag";
      viewModel.titleController.text = "Post Title";

      await viewModel.uploadPost();
      verify(
        locator<NavigationService>().showTalawaErrorSnackBar(
          "Post is uploaded",
          MessageType.info,
        ),
      ).called(1);
    });
    test('uploadPost with _imageFile == null', () async {
      final viewModel = AddPostViewModel();
      viewModel.initialise();
      viewModel.controller.text = "Some post content";
      viewModel.textHashTagController.text = "hashtag";
      viewModel.titleController.text = "Post Title";
      when(
        locator<DataBaseMutationFunctions>().gqlAuthMutation(
          PostQueries().uploadPost(),
          variables: anyNamed('variables'),
        ),
      ).thenThrow(Exception("exception"));

      await viewModel.uploadPost();
      verify(
        locator<NavigationService>().showTalawaErrorSnackBar(
          "Something went wrong",
          MessageType.error,
        ),
      ).called(1);
    });
    test('uploadPost with _imageFile != null', () async {
      final viewModel = AddPostViewModel();
      viewModel.initialise();
      final mockImageFile = File(
        'path/to/mockImage.png',
      );
      viewModel.setImageFile(mockImageFile);

      await viewModel.setImageInBase64(mockImageFile);
      viewModel.controller.text = "Some post content";
      viewModel.textHashTagController.text = "hashtag";
      viewModel.titleController.text = "Post Title";
      when(
        locator<DataBaseMutationFunctions>().gqlAuthMutation(
          PostQueries().uploadPost(),
          variables: anyNamed('variables'),
        ),
      ).thenThrow(Exception("exception"));

      await viewModel.uploadPost();
      verify(
        locator<NavigationService>().showTalawaErrorSnackBar(
          "Something went wrong",
          MessageType.error,
        ),
      ).called(1);
    });
    test("Check if remove_image method works correctly", () async {
      final notifyListenerCallback = MockCallbackFunction();
      final model = AddPostViewModel()..addListener(notifyListenerCallback);

      model.initialise();

      final file = File('fakePath');
      when(locator<MultiMediaPickerService>().getPhotoFromGallery(camera: true))
          .thenAnswer((_) async {
        return file;
      });

      await model.getImageFromGallery(camera: true);
      model.removeImage();
      expect(model.imageFile, null);
    });
    test('convertToBase64 converts file to base64 string', () async {
      final notifyListenerCallback = MockCallbackFunction();
      final model = AddPostViewModel()..addListener(notifyListenerCallback);
      model.initialise();
      //using this asset as the test asset
      final file = File('assets/images/Group 8948.png');
      final fileString = await model.convertToBase64(file);
      expect(model.imageInBase64, fileString);
    });

    test(
        'Check if convertToBase64 is working even if wrong file path is provided',
        () async {
      final notifyListenerCallback = MockCallbackFunction();
      final model = AddPostViewModel()..addListener(notifyListenerCallback);
      model.initialise();
      final file = File('fakePath');
      final fileString = await model.convertToBase64(file);
      expect('', fileString);
    });
  });
}
