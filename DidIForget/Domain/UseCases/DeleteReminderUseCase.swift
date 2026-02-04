import Foundation

final class DeleteReminderUseCase {
    private let repository: ExitReminderRepositoryContract
    
    init(repository: ExitReminderRepositoryContract) {
        self.repository = repository
    }
    
    func execute(reminderId: UUID) {
        repository.delete(reminderId)
    }
}
