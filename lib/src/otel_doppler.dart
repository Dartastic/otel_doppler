// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_doppler_suppression.dart';

class DopplerResult {
  const DopplerResult({
    this.workplace,
    this.project,
    this.config,
    this.environment,
    this.secretName,
    this.secretsCount,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? workplace;
  final String? project;
  final String? config;
  final String? environment;
  final String? secretName;
  final int? secretsCount;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class DopplerCallResult<T> {
  const DopplerCallResult({required this.value, this.result});
  final T value;
  final DopplerResult? result;
}

Future<T> tracedDoppler<T>({
  required String operation,
  required Future<DopplerCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (dopplerInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_doppler');
  final span = t.startSpan('doppler $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'doppler')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.workplace != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('doppler.workplace', res.workplace!)]));
      }
      if (res.project != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('doppler.project', res.project!)]));
      }
      if (res.config != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('doppler.config', res.config!)]));
      }
      if (res.environment != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('doppler.environment', res.environment!)]));
      }
      if (res.secretName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('doppler.secret.name', res.secretName!)]));
      }
      if (res.secretsCount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('doppler.secrets.count', res.secretsCount!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('doppler.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'doppler.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
