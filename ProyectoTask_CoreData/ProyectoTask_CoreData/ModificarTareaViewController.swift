import UIKit
import CoreData

class ModificarTareaViewController: UIViewController {

    @IBOutlet weak var txtTitulo: UITextField!
    @IBOutlet weak var txtDescripcion: UITextView!
    @IBOutlet weak var fechaVencimientoPicker: UIDatePicker!
    @IBOutlet weak var prioridadSegment: UISegmentedControl!

    var tareaAEditar: Tarea?

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuración inicial de la vista con los datos de la tarea existente
        if let tarea = tareaAEditar {
            txtTitulo.text = tarea.titulo
            txtDescripcion.text = tarea.descripcion
            fechaVencimientoPicker.date = tarea.fechaDeVencimiento ?? Date()
            prioridadSegment.selectedSegmentIndex = Int(tarea.prioridad)
        }
    }

    @IBAction func btnGuardarModificacion(_ sender: UIButton) {
        guard let tarea = tareaAEditar else {
            // Manejar el caso donde la tarea a editar es nula
            return
        }

        // Actualizar los datos de la tarea existente
        tarea.titulo = txtTitulo.text
        tarea.descripcion = txtDescripcion.text
        tarea.fechaDeVencimiento = fechaVencimientoPicker.date
        tarea.prioridad = Int32(prioridadSegment.selectedSegmentIndex)

        // Guardar el contexto para persistir los cambios en la base de datos
        do {
            try context.save()
            mostrarAlerta(titulo: "Éxito", mensaje: "Tarea modificada correctamente.")
        } catch {
            mostrarAlerta(titulo: "Error", mensaje: "Error al modificar la tarea.")
            print("Error al modificar la tarea: \(error.localizedDescription)")
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Cerrar la vista modalmente después de presionar "OK"
            self?.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TareaModificada"), object: nil)
                self?.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}
