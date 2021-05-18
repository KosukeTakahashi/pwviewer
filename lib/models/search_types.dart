enum SearchTypes {
  users,
  statuses,
  hashtags,
}

extension SearchTypeNames on SearchTypes {
  String get name {
    switch (this) {
      case SearchTypes.users:
        return 'accounts';
      case SearchTypes.statuses:
        return 'statuses';
      case SearchTypes.hashtags:
        return 'hashtags';
    }
  }
}
