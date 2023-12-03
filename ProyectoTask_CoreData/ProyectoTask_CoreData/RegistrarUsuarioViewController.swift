import UIKit
import CoreData

class RegistrarUsuarioViewController: UIViewController {

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    
    // Referencia al contexto de Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func btnRegistrar(_ sender: UIButton) {
        guard let nombre = txtNombre.text, let usuario = txtUsuario.text, let contrasena = txtContrasena.text else {
            return
        }
        // Validar que los campos tengan al menos 3 caracteres
        if nombre.count < 3 || usuario.count < 3 || contrasena.count < 3 {
            mostrarAlerta(titulo: "Error", mensaje: "Todos los campos deben tener al menos 3 caracteres.")
            return
        }
        // Crear un nuevo objeto de Usuario en Core Data
        let nuevoUsuario = Usuario(context: context)
        nuevoUsuario.nombre = nombre
        nuevoUsuario.usuario = usuario
        nuevoUsuario.contrasena = contrasena
        
        // Guardar el contexto para persistir los cambios en la base de datos
        do {
            try context.save()
            //print("Usuario registrado con éxito")
            
            mostrarAlerta(titulo: "Registro Exitoso", mensaje: "Usuario Registrado con Éxito")
            
            // Regresar a la vista anterior (LoginViewController) dentro del navigationController
            //navigationController?.popViewController(animated: true)
            
        }  catch {
            print("Error al registrar usuario: \(error)")
            mostrarAlerta(titulo: "Error", mensaje: "Error al registrar : \(error.localizedDescription)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Cerrar la vista modalmente después de presionar "OK"
            self?.dismiss(animated: true) {
                // Realizar la transición de vuelta al LoginViewController después de cerrar la vista actual
                self?.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
