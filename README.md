# otel_doppler

Dartastic OpenTelemetry bridge for Doppler (secrets manager).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_doppler/otel_doppler.dart';

await tracedDoppler<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return DopplerCallResult(value: r, result: DopplerResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutDopplerInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
