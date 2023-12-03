    import UIKit
    import CoreData

    class LoginUsuarioViewController: UIViewController {

        @IBOutlet weak var txtUsuario: UITextField!
        @IBOutlet weak var txtContrasena: UITextField!
        
        // Referencia al contexto de Core Data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        override func viewDidLoad() {
            super.viewDidLoad()
            txtContrasena.isSecureTextEntry = true

            // Do any additional setup after loading the view.
        }
        
        @IBAction func btnIngresar(_ sender: UIButton) {
            guard let nombreUsuario = txtUsuario.text, let contrasena = txtContrasena.text else {
                return
            }
            let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "usuario == %@ AND contrasena == %@", nombreUsuario, contrasena)
            do {
                let usuarios = try context.fetch(fetchRequest)
                if let usuario = usuarios.first  {
                    // Las credenciales son válidas, puedes permitir el acceso.
                    print("Inicio de sesión exitoso")
                    // Almacena el nombre de usuario en UserDefaults o donde prefieras
                    UserDefaults.standard.set(usuario.nombre, forKey: "nombre")
                    
                    // Redirijimos al vista principal
                   
                    // Cerrar la vista actual (LoginUsuarioViewController)
                    //dismiss(animated: true, completion: nil)
                } else {
                    // Las credenciales son incorrectas, muestra una alerta.
                    mostrarAlerta(titulo: "Error de Inicio de Sesión", mensaje: "Credenciales incorrectas. Por favor, verifica tu usuario y contraseña.")
                }
            } catch {
                print("Error al buscar usuario en Core Data: \(error)")
            }
        }
        
        func mostrarAlerta(titulo: String, mensaje: String) {
            let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "SegueLogin", let menuPrincipalViewController = segue.destination as? MenuPrincipalViewController {
                if let nombreAlmacenado = UserDefaults.standard.string(forKey: "nombre") {
                    menuPrincipalViewController.nombreUsuario = nombreAlmacenado
                }
            }
        }

    }
