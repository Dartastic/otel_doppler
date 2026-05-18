// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_doppler/otel_doppler.dart';
import 'package:test/test.dart';

void main() {
  group('otel_doppler', () {
    test('suppression toggles in zone', () async {
      expect(dopplerInstrumentationSuppressed(), isFalse);
      await runWithoutDopplerInstrumentationAsync(() async {
        expect(dopplerInstrumentationSuppressed(), isTrue);
      });
      expect(dopplerInstrumentationSuppressed(), isFalse);
    });

    test('DopplerResult fields default null', () {
      const r = DopplerResult();
      expect(r.statusCode, isNull);
    });
  });
}
