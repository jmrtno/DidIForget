import Foundation
import Combine

/// ViewModel para la pantalla de creación de nuevos reminders
/// Responsabilidades:
/// - Gestionar el estado del formulario de creación
/// - Validar datos de entrada del usuario
/// - Coordinar la creación de reminders con los use cases
/// - Interactuar con GeofenceService para ubicación actual
final class CreateReminderViewModel: ObservableObject {
    // MARK: - Propiedades del Formulario (@Published)
    
    /// Título del reminder ingresado por el usuario
    /// @Published: La UI actualiza el TextField en tiempo real
    @Published var title: String = ""
    
    /// Latitud ingresada manualmente o obtenida por GPS
    /// @Published: La UI actualiza el TextField cuando cambia
    @Published var latitude: String = ""
    
    /// Longitud ingresada manualmente o obtenida por GPS
    /// @Published: La UI actualiza el TextField cuando cambia
    @Published var longitude: String = ""
    
    /// Radio del geofence en metros
    /// @Published: La UI actualiza el Slider y muestra el valor
    @Published var radius: Double = 100
    
    /// Tipo de lugar predefinido (home, work, etc.)
    /// @Published: La UI actualiza el selector y muestra ícono correspondiente
    @Published var placeType: PlaceType = .home
    
    // MARK: - Propiedades de Estado de la UI (@Published)
    
    /// Controla la visibilidad del alert de validación
    /// @Published: La UI muestra/oculta el alert automáticamente
    @Published var showValidationError: Bool = false
    
    /// Mensaje de error específico para la validación
    /// @Published: La UI actualiza el contenido del alert dinámicamente
    @Published var validationErrorMessage: String = ""
    
    /// Controla la visibilidad del mensaje de éxito
    /// @Published: La UI muestra/oculta el indicador de éxito
    @Published var showSuccessMessage: Bool = false
    
    // MARK: - Dependencias
    
    /// Use case para crear nuevos reminders en el repositorio
    private let createReminderUseCase: CreateReminderUseCase
    
    /// Servicio de geofences para obtener ubicación actual y comenzar monitoreo
    private let geofenceService: GeofenceServiceContract
    
    /// Propiedad computada para validación del formulario
    /// Combina múltiples validaciones en una sola propiedad
    /// La UI la usa para habilitar/deshabilitar el botón de creación
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(latitude) != nil &&
        Double(longitude) != nil
    }
    
    /// Propiedad computada para mostrar el radio en formato legible
    /// Convierte el valor numérico a texto con unidades para la UI
    var radiusText: String {
        "\(Int(radius)) meters"
    }
    
    init(
        createReminderUseCase: CreateReminderUseCase,
        geofenceService: GeofenceServiceContract
    ) {
        self.createReminderUseCase = createReminderUseCase
        self.geofenceService = geofenceService
    }
    
    /// Solicita la ubicación actual al sistema
    /// Se llama al aparecer la vista para tener datos listos
    func onAppear() {
        geofenceService.requestCurrentLocation()
    }
    
    /// Obtiene las coordenadas GPS actuales y las asigna al formulario
    /// Maneja el caso de error mostrando un alert informativo
    /// Formatea las coordenadas a 6 decimales para precisión
    func useCurrentLocation() {
        if let lat = geofenceService.getCurrentLatitude(),
           let lon = geofenceService.getCurrentLongitude() {
            latitude = String(format: "%.6f", lat)
            longitude = String(format: "%.6f", lon)
        } else {
            validationErrorMessage = "Unable to get current location. Please ensure location permission is granted."
            showValidationError = true
        }
    }
    
    /// Crea un nuevo reminder con validación completa
    /// Flujo: Validación → Creación → Monitoreo → Confirmación
    /// Retorna true si tuvo éxito, false si hubo error de validación
    func createReminder() -> Bool {
        guard let lat = Double(latitude),
              let lon = Double(longitude) else {
            validationErrorMessage = "Please enter valid latitude and longitude values."
            showValidationError = true
            return false
        }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationErrorMessage = "Please enter a reminder title."
            showValidationError = true
            return false
        }
        
        guard lat >= -90 && lat <= 90 else {
            validationErrorMessage = "Latitude must be between -90 and 90."
            showValidationError = true
            return false
        }
        
        guard lon >= -180 && lon <= 180 else {
            validationErrorMessage = "Longitude must be between -180 and 180."
            showValidationError = true
            return false
        }
        
        let reminder = ExitReminder(
            title: trimmedTitle,
            latitude: lat,
            longitude: lon,
            radius: radius,
            placeType: placeType,
            isEnabled: true
        )
        
        createReminderUseCase.execute(reminder)
        geofenceService.startMonitoring(reminder: reminder)
        
        return true
    }
}
