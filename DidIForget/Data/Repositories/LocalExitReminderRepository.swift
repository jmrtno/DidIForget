import Foundation

final class LocalExitReminderRepository: ExitReminderRepositoryContract {
    private let storageKey = "exit_reminders"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func fetchAll() -> [ExitReminder] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }
        
        do {
            let reminders = try JSONDecoder().decode([ExitReminder].self, from: data)
            return reminders.sorted { $0.createdAt > $1.createdAt }
        } catch {
            return []
        }
    }
    
    func save(_ reminder: ExitReminder) {
        var reminders = fetchAll()
        reminders.append(reminder)
        persist(reminders)
    }
    
    func update(_ reminder: ExitReminder) {
        var reminders = fetchAll()
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            persist(reminders)
        }
    }
    
    func delete(_ reminderId: UUID) {
        var reminders = fetchAll()
        reminders.removeAll { $0.id == reminderId }
        persist(reminders)
    }
    
    func find(by id: UUID) -> ExitReminder? {
        fetchAll().first { $0.id == id }
    }
    
    private func persist(_ reminders: [ExitReminder]) {
        do {
            let data = try JSONEncoder().encode(reminders)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            // Silent fail - in production, consider logging
        }
    }
}
