import Foundation

final class FetchRemindersUseCase {
    private let repository: ExitReminderRepositoryContract
    
    init(repository: ExitReminderRepositoryContract) {
        self.repository = repository
    }
    
    func execute() -> [ExitReminder] {
        repository.fetchAll()
    }
}
