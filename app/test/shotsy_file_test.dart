import 'package:aloft/data/database.dart';
import 'package:aloft/dose/injection_sites.dart';
import 'package:aloft/import/shotsy_file.dart';
import 'package:flutter_test/flutter_test.dart';

/// Made-up data in Shotsy's format (docs/shotsy-import.md). Never real exports.
const shotsyHeader =
    'Date,Shot,Time,Site,Shot Notes,Pain Level,Recorded Weight (lbs),Calories,Protein,Water,Day Notes,'
    'Nausea,Heartburn,Food Noise,Suppressed Appetite,Constipation,Diarrhea,Belching,Injection Site Reaction,'
    'Mood Swings,Indigestion,Metallic Taste,Stomach Pain,Hair Loss,Fatigue,Migraine';

String shotsyRow(
  String date, {
  String shot = '',
  String time = '',
  String site = '',
  String shotNote = '',
  String pain = '',
  String weight = '',
  String calories = '',
  String dayNote = '',
  String nausea = '',
  String fatigue = '',
  String migraine = '',
}) =>
    '"$date","$shot","$time","$site","$shotNote","$pain","$weight","$calories","","","$dayNote",'
    '$nausea,,,,,,,,,,,,,$fatigue,$migraine';

final sampleShotsy = [
  shotsyHeader,
  shotsyRow('2025-01-06', shot: 'Tirzepatide 2.5 mg', time: '19:00', site: 'Right Arm', pain: '0', weight: '210.00'),
  shotsyRow('2025-01-08', weight: '209.20', dayNote: 'felt great today '),
  shotsyRow(
    '2025-01-13',
    shot: 'Tirzepatide 2.5 mg',
    time: '19:05',
    site: 'Stomach - Upper Mid',
    pain: '2',
    nausea: '3',
  ),
  shotsyRow(
    '2025-01-20',
    shot: 'Tirzepatide 5.0 mg',
    time: '20:40',
    site: 'Left Thigh',
    shotNote: 'stung, a bit',
    weight: '206.40',
  ),
  shotsyRow('2025-01-21', calories: '1500', fatigue: '4', migraine: '7'),
  '',
].join('\n');

void main() {
  test('reads shots, weights, notes and symptoms from the made-up sample', () {
    final file = parseShotsy(sampleShotsy)!;
    expect((file.shotCount, file.weightCount, file.noteCount, file.effectCount, file.foodDays), (3, 3, 1, 3, 1));
    expect(file.medications, ['Tirzepatide']);

    final first = file.days.first;
    expect((first.shot!.mg, first.shot!.at, first.shot!.site), (2.5, DateTime(2025, 1, 6, 19), InjectionSite.armRight));
    expect(first.weightLb, 210.0);

    expect(file.days[1].notes, ['felt great today']);
    final second = file.days[2];
    expect((second.shot!.site, second.shot!.pain), (InjectionSite.abdomenUpperMiddle, 2));
    expect(second.effects, {SideEffectType.nausea: 3});
    expect((file.days[3].shot!.mg, file.days[3].shot!.note), (5.0, 'stung, a bit'));
    expect(file.days[4].effects, {SideEffectType.fatigue: 4, SideEffectType.headache: 7});
  });

  test('anything that is not a Shotsy export is turned away', () {
    expect(parseShotsy('Date,Weight\n2025-01-01,200'), isNull);
    expect(parseShotsy(''), isNull);
    expect(parseShotsy('hello world'), isNull);
  });

  test('copes with a byte-order mark, Windows line endings, unquoted fields and short rows', () {
    final text =
        '﻿$shotsyHeader\r\n2025-02-03,Semaglutide 0.5 mg,08:15,Left Arm,,,\r\n"2025-02-04","","","","","","199.5"\r\n';
    final file = parseShotsy(text)!;
    expect((file.shotCount, file.weightCount), (1, 1));
    expect((file.shots.single.medication, file.shots.single.mg), ('Semaglutide', 0.5));
  });

  test('doses written "5 mg", "5.0 mg" and "7,5 mg" are all read; brand names with spaces too', () {
    final file = parseShotsy(
      [
        shotsyHeader,
        shotsyRow('2025-03-01', shot: 'Zepbound 5 mg', time: '09:00'),
        shotsyRow('2025-03-08', shot: 'Zepbound 5.0 mg', time: '09:00'),
        shotsyRow('2025-03-15', shot: 'Compounded Tirzepatide 7,5 mg', time: '09:00'),
      ].join('\n'),
    )!;
    expect([for (final s in file.shots) s.mg], [5, 5, 7.5]);
    expect(file.medications, ['Zepbound', 'Compounded Tirzepatide']);
  });

  test('what cannot be understood becomes a note, never an error or a guess', () {
    final file = parseShotsy(
      [
        shotsyHeader,
        shotsyRow('2025-03-01', shot: 'Something odd', time: '09:00'),
        shotsyRow('2025-03-02', shot: 'Tirzepatide 5 mg', time: '', site: 'Left Buttock'),
        shotsyRow('2025-03-03', nausea: '12'),
        shotsyRow('2025-03-04', nausea: 'mild'),
        shotsyRow('not a date', weight: '200'),
      ].join('\n'),
    )!;
    expect(file.days[0].shot, isNull);
    expect(file.days[0].notes, ['Shot (from Shotsy): Something odd']);
    final shot = file.days[1].shot!;
    expect((shot.site, shot.siteText, shot.at), (null, 'Left Buttock', DateTime(2025, 3, 2, 12)));
    expect(file.days[2].notes, ['nausea (from Shotsy): 12']);
    expect(file.days[3].notes, ['nausea (from Shotsy): mild']);
    expect(file.effectCount, 0);
    expect(file.days.length, 4);
  });

  test('quoted commas, doubled quotes and line breaks inside a note survive', () {
    final rows = parseCsv('a,"b, c","say ""hi""","two\nlines"\n\n1,2,3,4\n');
    expect(rows, [
      ['a', 'b, c', 'say "hi"', 'two\nlines'],
      ['1', '2', '3', '4'],
    ]);
  });
}
