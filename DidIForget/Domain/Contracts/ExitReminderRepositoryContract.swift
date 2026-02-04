import Foundation

protocol ExitReminderRepositoryContract {
    func fetchAll() -> [ExitReminder]
    func save(_ reminder: ExitReminder)
    func update(_ reminder: ExitReminder)
    func delete(_ reminderId: UUID)
    func find(by id: UUID) -> ExitReminder?
}
