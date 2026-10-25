// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_doppler/otel_doppler.dart';

/// Traces Doppler calls with OpenTelemetry.
///
/// `otel_doppler` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Doppler call in
/// [tracedDoppler]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'doppler-example');

  // Traces a Doppler call.
  final dopplerId = await tracedDoppler<String>(
    operation: 'create',
    invoke: () async {
      // Make the Doppler call here, then report what it returned.
      const id = 'doppler_8f3a2c';
      return const DopplerCallResult(
          value: id,
          result: DopplerResult(
              workplace: 'example',
              project: 'example',
              config: 'example',
              environment: 'example',
              secretName: 'example',
              secretsCount: 3,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedDoppler create returned $dopplerId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutDopplerInstrumentationAsync.
  await runWithoutDopplerInstrumentationAsync(
    () => tracedDoppler<String>(
      operation: 'create',
      invoke: () async {
        const id = 'doppler_8f3a2c';
        return const DopplerCallResult(
            value: id,
            result: DopplerResult(
                workplace: 'example',
                project: 'example',
                config: 'example',
                environment: 'example',
                secretName: 'example',
                secretsCount: 3,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
