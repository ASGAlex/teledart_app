part of application;

typedef AsyncErrorHandlerFunction = void Function(
    Object exception, dynamic trace, dynamic additionalData);

mixin AsyncErrorHandler {
  Future catchAsyncError(dynamic functionResult, {dynamic additionalData}) {
    if (functionResult is Future) {
      return functionResult.catchError((exception, trace) {
        if (asyncErrorHandler != null) {
          asyncErrorHandler!(exception, trace, additionalData);
        }
      });
    }
    return Future.value(null);
  }

  AsyncErrorHandlerFunction? asyncErrorHandler;
}
