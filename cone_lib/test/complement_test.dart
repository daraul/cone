// ignore_for_file: always_specify_types

import 'package:test/test.dart';

import 'package:cone_lib/src/complement.dart' show formattedAmountHint;
import 'package:cone_lib/src/types.dart' show Posting;

void main() {
  List<Posting> expandPostings(List<List<String>> abbreviatedPostings) =>
      abbreviatedPostings
          .map(
            (List<String> abbreviatedPosting) => Posting(
              account: abbreviatedPosting[0],
              amount: abbreviatedPosting[1],
              currency: abbreviatedPosting[2],
            ),
          )
          .toList();
  group('Test amount hint', () {
    test('Test amount hint', () {
      expect(
          formattedAmountHint(
              locale: 'en_US',
              index: 1,
              postings: expandPostings([
                ['A', '1', 'USD'],
                ['B', '', 'USD'],
              ])),
          '-1.00');
    });
    test('Test amount hint', () {
      expect(
          formattedAmountHint(
              locale: 'en_US',
              index: 2,
              postings: expandPostings([
                ['A', '2', 'USD'],
                ['B', '3', 'USD'],
                ['C', '', 'USD'],
              ])),
          '-5.00');
    });
  });
  group('Test amount hint for \'de\' locale', () {
    test('Test amount hint', () {
      expect(
          formattedAmountHint(
              locale: 'de',
              index: 1,
              postings: expandPostings([
                ['A', '1', 'EUR'],
                ['B', '', 'EUR'],
              ])),
          '-1,00');
    });
    test('Test de locale with comma', () {
      expect(
          formattedAmountHint(
              locale: 'de',
              index: 1,
              postings: expandPostings([
                ['A', '17,50', 'EUR'],
                ['B', '', 'EUR'],
              ])),
          '-17,50');
    });
    test('Test de locale with period', () {
      expect(
          formattedAmountHint(
              locale: 'de',
              index: 1,
              postings: expandPostings([
                ['A', '17.50', 'EUR'],
                ['B', '', 'EUR'],
              ])),
          '-1750,00');
    });
    test('Test en locale with comma', () {
      expect(
          formattedAmountHint(
              locale: 'en',
              index: 1,
              postings: expandPostings([
                ['A', '17,50', 'USD'],
                ['B', '', 'USD'],
              ])),
          '-1750.00');
    });
    test('Test with non-matching currency', () {
      expect(
          formattedAmountHint(
              locale: 'de',
              index: 1,
              postings: expandPostings([
                ['A', '17,50', 'USD'],
                ['B', '', 'USD'],
              ])),
          '-17,50');
    });
    test('Test with de locale and JPY currency', () {
      expect(
          formattedAmountHint(
              locale: 'de',
              index: 1,
              postings: expandPostings([
                ['A', '17,50', 'JPY'],
                ['B', '', 'JPY'],
              ])),
          '-17,5');
    });
  });
}
