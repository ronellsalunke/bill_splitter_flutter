abstract class UpdateEvent {}

class CheckForUpdate extends UpdateEvent {}

class DismissUpdateBanner extends UpdateEvent {}

class AcknowledgeUpdateChangelog extends UpdateEvent {}
