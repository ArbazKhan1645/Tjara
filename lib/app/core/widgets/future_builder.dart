import 'package:flutter/material.dart';

class CustomFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) onData;
  final Widget Function(Object error)? onError;
  final Widget Function()? onLoading;
  final Widget Function()? onEmpty;
  final bool Function(T data)? isEmpty;
  final VoidCallback? onRetry;

  const CustomFutureBuilder({
    super.key,
    required this.future,
    required this.onData,
    this.onError,
    this.onLoading,
    this.onEmpty,
    this.isEmpty,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, AsyncSnapshot<T> snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return onError?.call(snapshot.error!) ??
              DefaultErrorWidget(
                error: snapshot.error!,
                onRetry: onRetry,
              );
        }

        // Handle loading state
        if (!snapshot.hasData) {
          return onLoading?.call() ?? const DefaultLoadingWidget();
        }

        // Handle empty state
        final data = snapshot.data as T;
        if (isEmpty?.call(data) ?? false) {
          return onEmpty?.call() ?? const DefaultEmptyWidget();
        }

        // Handle data state
        return onData(data);
      },
    );
  }
}

// Default loading widget
class DefaultLoadingWidget extends StatelessWidget {
  final String? message;

  const DefaultLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Default error widget
class DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? message;

  const DefaultErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Error: ${error.toString()}',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Default empty widget
class DefaultEmptyWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;

  const DefaultEmptyWidget({
    super.key,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'No data available',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
