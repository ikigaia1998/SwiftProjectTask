import UIKit
import CoreData

class RegistrarTareaViewController: UIViewController {

    @IBOutlet weak var txttitulo: UITextField!
    @IBOutlet weak var txtdescripcion: UITextView!
    @IBOutlet weak var fechaVencimientoPicker: UIDatePicker!
    @IBOutlet weak var prioridadSegment: UISegmentedControl!
    
    // Referencia al contexto de Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configuración del borde
        txtdescripcion.layer.borderWidth = 1.0
        txtdescripcion.layer.borderColor = UIColor.gray.cgColor
        txtdescripcion.layer.cornerRadius = 5.0
        //txttitulo.layer.borderColor = UIColor.gray.cgColor
        txttitulo.layer.borderWidth = 1.0
        txttitulo.layer.cornerRadius = 5.0
        // Otras configuraciones (si es necesario)
        txtdescripcion.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    @IBAction func btnGuardarTarea(_ sender: UIButton) {
        guard let titulo = txttitulo.text, !titulo.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "El título de la tarea no puede estar vacío.")
            return
        }
        // Crear una nueva instancia de Tarea en Core Data
        let nuevaTarea = Tarea( context:context)
        nuevaTarea.titulo = titulo
        nuevaTarea.descripcion = txtdescripcion.text
        nuevaTarea.fechaDeVencimiento = fechaVencimientoPicker.date
        nuevaTarea.prioridad = Int32(prioridadSegment.selectedSegmentIndex)
        nuevaTarea.estado = false // Puedes establecer el valor inicial del estado
        nuevaTarea.fechaDeCreacion = Date() // Establecer la fecha actual
        // Guardar el contexto para persistir los cambios en la base de datos
        do {
            try context.save()
            mostrarAlerta(titulo: "Éxito", mensaje: "Tarea guardada correctamente.")
        } catch {
            mostrarAlerta(titulo: "Error", mensaje: "Error al guardar la tarea.")
            print("Error al guardar la tarea: \(error.localizedDescription)")
        }
    }

    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Cerrar la vista modalmente después de presionar "OK"
            self?.dismiss(animated: true) {
                // Realizar la transición de vuelta al LoginViewController después de cerrar la vista actual
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TareaRegistrada"), object: nil)
                self?.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    
}
