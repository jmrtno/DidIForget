import Foundation

final class CreateReminderUseCase {
    private let repository: ExitReminderRepositoryContract
    
    init(repository: ExitReminderRepositoryContract) {
        self.repository = repository
    }
    
    func execute(_ reminder: ExitReminder) {
        repository.save(reminder)
    }
}
