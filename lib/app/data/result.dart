sealed class Result<S, E> {
  const Result();
}

final class Success<S, E> extends Result<S, E> {
  const Success(this.value);

  final S value;
}

final class FailureResult<S, E> extends Result<S, E> {
  const FailureResult(this.failure);

  final E failure;
}

extension ResultOps<S, E> on Result<S, E> {
  T fold<T>(T Function(S value) onSuccess, T Function(E failure) onFailure) {
    return switch (this) {
      Success(value: final value) => onSuccess(value),
      FailureResult(failure: final failure) => onFailure(failure),
    };
  }
}
