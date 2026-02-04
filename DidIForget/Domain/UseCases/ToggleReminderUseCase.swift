import Foundation

final class ToggleReminderUseCase {
    private let repository: ExitReminderRepositoryContract
    
    init(repository: ExitReminderRepositoryContract) {
        self.repository = repository
    }
    
    func execute(reminderId: UUID, isEnabled: Bool) {
        guard var reminder = repository.find(by: reminderId) else { return }
        reminder.isEnabled = isEnabled
        repository.update(reminder)
    }
}
