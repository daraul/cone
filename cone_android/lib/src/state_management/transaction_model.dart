import 'package:cone_lib/cone_lib.dart' as lib
    show formattedAmountHint, Posting;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:cone/src/state_management/posting_model.dart' show PostingModel;

class TransactionModel {
  TextEditingController dateController;
  TextEditingController descriptionController;
  FocusNode dateFocus;
  FocusNode descriptionFocus;
  SuggestionsBoxController suggestionsBoxController;
  List<PostingModel> postingModels;

  //
  // Check if transaction is valid, before allowing to save
  //

  bool get transactionIsNotValid =>
      dateController.text.isEmpty ||
      descriptionController.text.isEmpty ||
      amountWithNoAccount ||
      numberOfAccounts < 2 ||
      (numberOfAccounts - numberOfAmounts > 1);
  bool get amountWithNoAccount =>
      postingModels.any((PostingModel postingModel) =>
          postingModel.accountController.text.isEmpty &&
          postingModel.amountController.text.isNotEmpty);
  int get numberOfAccounts => postingModels
      .where((PostingModel postingModel) =>
          postingModel.accountController.text.isNotEmpty)
      .length;
  int get numberOfAmounts => postingModels
      .where((PostingModel postingModel) =>
          postingModel.amountController.text.isNotEmpty)
      .length;

  //
  // Not closing suggestions can cause exceptions
  //

  void closeSuggestionBoxControllers() {
    suggestionsBoxController?.close();
    for (final PostingModel postingModel in postingModels) {
      postingModel.suggestionsBoxController.close();
    }
  }

  //
  // Method to reset form widgets
  //

  void reset({
    @required void Function() notifyListeners,
    @required String defaultCurrency,
    @required String dateFormat,
  }) {
    dateController = TextEditingController(
      text: DateFormat(dateFormat).format(DateTime.now()),
    );
    descriptionController = TextEditingController();
    dateFocus = FocusNode();
    descriptionFocus = FocusNode();
    suggestionsBoxController = SuggestionsBoxController();
    postingModels = <PostingModel>[
      PostingModel(
        currencyControllerText: defaultCurrency,
      ),
      PostingModel(
        currencyControllerText: defaultCurrency,
      ),
    ];
    dateController.addListener(notifyListeners);
    descriptionController.addListener(notifyListeners);
    for (final PostingModel postingModel in postingModels) {
      postingModel
        ..accountController.addListener(notifyListeners)
        ..amountController.addListener(notifyListeners)
        ..currencyController.addListener(notifyListeners);
    }
  }

  //
  // Remove a posting and notify
  //

  void removeAtAndNotifyListeners({
    @required int index,
    @required void Function() notifyListeners,
  }) {
    postingModels[index]
      ..accountFocus.dispose()
      ..accountController.dispose()
      ..amountFocus.dispose()
      ..amountController.dispose()
      ..currencyFocus.dispose()
      ..currencyController.dispose();
    postingModels.removeAt(index);
    notifyListeners();
  }

  //
  // Check if a new posting row is needed
  //

  void ensurePostingsAreNotFull({
    @required String defaultCurrency,
    @required void Function() notifyListeners,
  }) {
    if (postingModels.every((PostingModel postingModel) =>
        postingModel.accountController.text.isNotEmpty)) {
      postingModels.add(PostingModel(currencyControllerText: defaultCurrency)
        ..accountController.addListener(notifyListeners)
        ..amountController.addListener(notifyListeners)
        ..currencyController.addListener(notifyListeners));
      notifyListeners();
    }
  }

  //
  // Provide amount hint
  //

  String formattedAmountHint({
    @required String locale,
    @required int index,
  }) =>
      lib.formattedAmountHint(
        locale: locale,
        index: index,
        postings: postingModels.map(
          (PostingModel postingModel) {
            return lib.Posting(
              account: postingModel.accountController.text,
              amount: postingModel.amountController.text,
              currency: postingModel.currencyController.text,
            );
          },
        ).toList(),
      );
}
