import UIKit
import CoreData

class MenuPrincipalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblusuario: UILabel!
    @IBOutlet weak var btnAnadirTarea: UIButton!
    @IBOutlet weak var TablaTareas: UITableView!
    @IBOutlet weak var TipoTareaSegment: UISegmentedControl!
    @IBOutlet weak var PrioridadTareaSegment: UISegmentedControl!
    
    var nombreUsuario: String?
    var tareas: [Tarea] = []

    // Referencia al contexto de Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBAction func CerrarAplication(_ sender: UIBarButtonItem) {
        // Crear una alerta de confirmación
        let alerta = UIAlertController(title: "Cerrar Sesión", message: "¿Estás seguro de que quieres cerrar la sesión?", preferredStyle: .alert)

        // Añadir acciones a la alerta
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alerta.addAction(accionCancelar)

        let accionCerrar = UIAlertAction(title: "Cerrar", style: .destructive) { (_) in
            // Cerrar la aplicación
            exit(0)
        }
        alerta.addAction(accionCerrar)

        // Presentar la alerta
        present(alerta, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        btnAnadirTarea.layer.cornerRadius = 5.0
        TablaTareas.delegate = self
        TablaTareas.dataSource = self
  	

        cargarTodasLasTareas()

        if let nombreUsuario = nombreUsuario {
            print("Valor de nombreUsuario: \(nombreUsuario)")
            lblusuario?.text = "¡Hola, \(nombreUsuario)!"
        } else {
            print("Error: nombreUsuario es nil")
        }

        // Ocultar el botón de retroceso en la barra de navegación
        navigationItem.hidesBackButton = true
    }

    
    @IBAction func ReiniciarFiltros(_ sender: UIButton) {
        cargarTodasLasTareas()
    }
    
    @IBAction func TipoTareaSegment(_ sender: UISegmentedControl) {
        let prioridadIndex = PrioridadTareaSegment.selectedSegmentIndex
        print("TipoTareaSegment - tipoIndex: \(sender.selectedSegmentIndex), prioridadIndex: \(prioridadIndex)")
        cargarTodasLasTareas()
        cargarTareasFiltradas(tipoIndex: sender.selectedSegmentIndex, prioridadIndex: prioridadIndex)
    }

    @IBAction func PrioridadTareaSegment(_ sender: UISegmentedControl) {
        let tipoIndex = TipoTareaSegment.selectedSegmentIndex
        print("PrioridadTareaSegment - tipoIndex: \(tipoIndex), prioridadIndex: \(sender.selectedSegmentIndex)")
        cargarTodasLasTareas()
        cargarTareasFiltradas(tipoIndex: tipoIndex, prioridadIndex: sender.selectedSegmentIndex)
    }
  
    func cargarTodasLasTareas() {
       /* guard let usuarioActual = obtenerUsuarioActual() else {
            return
        }*/
        do {
            let fetchRequest: NSFetchRequest<Tarea> = Tarea.fetchRequest()
            // Modifica la solicitud para que incluya solo las tareas asociadas con el usuario actual
           // fetchRequest.predicate = NSPredicate(format: "usuario == %@", usuarioActual)
            tareas = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.TablaTareas.reloadData()
            }
        } catch let error as NSError {
            print("Error al cargar todas las tareas: \(error.localizedDescription)")
        }
    }

    // Función para obtener el usuario actual
    func obtenerUsuarioActual() -> Usuario? {
        // Implementa la lógica para obtener el usuario actual, por ejemplo, desde Core Data
        guard let nombreUsuario = UserDefaults.standard.string(forKey: "nombre") else {
            return nil
        }
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nombre == %@", nombreUsuario)

        do {
            let usuarios = try context.fetch(fetchRequest)
            return usuarios.first
        } catch {
            print("Error al obtener el usuario actual: \(error.localizedDescription)")
            return nil
        }
    }
    

    func cargarTareasFiltradas(tipoIndex: Int, prioridadIndex: Int) {
        print("tipoIndex: \(tipoIndex), prioridadIndex: \(prioridadIndex)")

        var tareasFiltradas = tareas

         if tipoIndex == 0 {
            // Caso No Completado
            tareasFiltradas = tareasFiltradas.filter { !$0.estado }
        } else if tipoIndex == 1 {
            // Caso Completado
            tareasFiltradas = tareasFiltradas.filter { $0.estado }
        }

        if prioridadIndex != UISegmentedControl.noSegment {
            tareasFiltradas = tareasFiltradas.filter { $0.prioridad == prioridadIndex }
        }

        DispatchQueue.main.async {
            self.tareas = tareasFiltradas
            self.TablaTareas.reloadData()
        }
    }

    // MARK: - UITableView Delegate and DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tareas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        let tarea = tareas[indexPath.row]
        celda.textLabel?.text = tarea.titulo
        celda.detailTextLabel?.text = tarea.descripcion
        // Configurar el checkmark si la tarea está completada
        if tarea.estado {
            celda.accessoryType = .checkmark
        } else {
            celda.accessoryType = .none
        }
        return celda
    }

    // MARK: - Swipe Actions

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completarAction = UIContextualAction(style: .normal, title: "Completar") { [weak self] (_, _, completion) in
            self?.completarTarea(at: indexPath)
            completion(true)
        }
        completarAction.backgroundColor = UIColor.systemGreen

        let completarConfiguration = UISwipeActionsConfiguration(actions: [completarAction])
        completarConfiguration.performsFirstActionWithFullSwipe = false

        return completarConfiguration
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let eliminarAction = UIContextualAction(style: .destructive, title: "Eliminar") { [weak self] (_, _, completion) in
            self?.eliminarTarea(at: indexPath)
            completion(true)
        }
        eliminarAction.backgroundColor = UIColor.systemRed
        let eliminarConfiguration = UISwipeActionsConfiguration(actions: [eliminarAction])
        eliminarConfiguration.performsFirstActionWithFullSwipe = false

        return eliminarConfiguration
    }

    // MARK: - Helper Methods

    func completarTarea(at indexPath: IndexPath) {
        let tarea = self.tareas[indexPath.row]

        // Cambiar el estado de la tarea a completado
        tarea.estado = true

        // Guardar el contexto para persistir los cambios en la base de datos
        do {
            try context.save()
            // Actualizar la celda para reflejar el cambio en el estado de la tarea
            TablaTareas.reloadRows(at: [indexPath], with: .automatic)
            cargarTodasLasTareas()
            
        } catch {
            print("Error al completar la tarea: \(error)")
        }
    }

    func eliminarTarea(at indexPath: IndexPath) {
        let tarea = tareas[indexPath.row]

        let alerta = UIAlertController(title: "Eliminar Tarea", message: "¿Estás seguro de que quieres eliminar esta tarea?", preferredStyle: .alert)

        let accionCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)

        let accionEliminar = UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            // Eliminar la tarea de Core Data
            self?.eliminarTareaDeCoreData(tarea: tarea)
        }

        alerta.addAction(accionCancelar)
        alerta.addAction(accionEliminar)

        present(alerta, animated: true, completion: nil)
    }

    func eliminarTareaDeCoreData(tarea: Tarea) {
        // Implementa el código para eliminar la tarea de tu modelo de datos (Core Data)
        do {
            context.delete(tarea)
            try context.save()

            // Eliminar la tarea del array local
            tareas.removeAll { $0 == tarea }

            // Actualizar la tabla
            TablaTareas.reloadData()
        } catch let error as NSError {
            print("Error al eliminar la tarea de Core Data: \(error.localizedDescription)")
        }
    }

    // MARK : User Modify
    @IBAction func ModificaUsuario(_ sender: UIButton) {
        // Obtener el nombre de usuario actual
        guard let nombreUsuario = UserDefaults.standard.string(forKey: "nombre") else { return }
        // Intentar realizar la transición a la vista de modificación
        do {
            try performSegue(withIdentifier: "PrincipalToModifyUser", sender: nombreUsuario)
        } catch {
            print("Error al realizar segue: \(error)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PrincipalToModifyUser", let destino = segue.destination as? ModificarUsuarioViewController {
            // Pasar el nombre de usuario a la vista de modificación
            destino.nombreUsuarioModificar = sender as? String
            if let nombreAlmacenado = UserDefaults.standard.string(forKey: "nombre") {
                destino.nombreUsuarioModificar = nombreAlmacenado
            }

            if let contrasenaAlmacenado = UserDefaults.standard.string(forKey: "contrasena") {
                destino.contrasenaUsuarioModifcar = contrasenaAlmacenado
            }
        }
        
        print("Preparing for segue...Task")
        if segue.identifier == "PrincipalToModifyTask", let destino = segue.destination as? ModificarTareaViewController, let tareaSeleccionada = sender as? Tarea {
            // Pasar la tarea seleccionada a la vista de modificación de tarea
            destino.tareaAEditar = tareaSeleccionada
            print("Envio Datos al ModificarTarea...")
        }
    }
    
    
    
    @IBAction func ModificarTarea(_ sender: UIButton) {
        // Obtener el índice de la celda seleccionada
        if let indexPath = TablaTareas.indexPathForSelectedRow {
            // Obtener la tarea seleccionada
            let tareaSeleccionada = tareas[indexPath.row]
            
            // Intentar realizar la transición a la vista de modificación de tarea
            do {
                try performSegue(withIdentifier: "PrincipalToModifyTask", sender: tareaSeleccionada)
            } catch {
                print("Error al realizar segue: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Observar la notificación para actualizar la lista de tareas
        NotificationCenter.default.addObserver(self, selector: #selector(actualizarListaTareas), name: NSNotification.Name(rawValue: "TareaModificada"), object: nil)
        
        // Observar la notificación para actualizar la lista de tareas
        NotificationCenter.default.addObserver(self, selector: #selector(actualizarListaTareas), name: NSNotification.Name(rawValue: "TareaRegistrada"), object: nil)
    }

    @objc func actualizarListaTareas() {
        // Aquí puedes recargar la lista de tareas
        cargarTodasLasTareas()
    }




    
    
}
