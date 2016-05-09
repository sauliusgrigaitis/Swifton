struct FilterCollection {

    private struct FilterOption {

        let name: String
        var onlyForActions = [String]()
        var exceptForActions = [String]()

        init(name: String) {
            self.name = name
        }

        init(name: String, onlyForActions: [String]) {
            self.name = name
            self.onlyForActions = onlyForActions
        }

        init(name: String, exceptForActions: [String]) {
            self.name = name
            self.exceptForActions = exceptForActions
        }

        func shouldRunFor(action: String) -> Bool {
            guard onlyForActions.isEmpty else {
                return onlyForActions.contains(action)
            }

            guard exceptForActions.isEmpty else {
                return !exceptForActions.contains(action)
            }

            return true
        }

    }

    private var filterOptions = [FilterOption]()

    mutating func set(filter filterName: String) {
        append(FilterOption(name: filterName))
    }

    mutating func set(filter filterName: String, onlyForActions actions: [String]) {
        append(FilterOption(name: filterName, onlyForActions: actions))
    }

    mutating func set(filter filterName: String, exceptForActions actions: [String]) {
        append(FilterOption(name: filterName, exceptForActions: actions))
    }

    func forAction(_ action: String) -> [String] {
        return filterOptions.filter({ $0.shouldRunFor(action: action) }).map { $0.name }
    }

    private mutating func append(_ filterOption: FilterOption) {
        if let index = filterOptions.index(where: { $0.name == filterOption.name }) {
            filterOptions.remove(at: index)
        }

        filterOptions.append(filterOption)
    }

}
