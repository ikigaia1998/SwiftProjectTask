//
//  ModificarUsuarioViewController.swift
//  ProyectoTask_CoreData
//
//  Created by DAMII on 28/11/23.
//

import UIKit
import CoreData


class ModificarUsuarioViewController: UIViewController {
 
    //@IBOutlet weak var txtNombreUsuario: UITextField!
    @IBOutlet weak var txtNombreUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    var nombreUsuarioModificar: String?
    var contrasenaUsuarioModifcar:String?
    // Referencia al contexto de Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Si hay un nombre de usuario para modificar, realiza las acciones necesarias
        if let nombreUsuario = nombreUsuarioModificar {
            cargarDatosUsuario(nombreUsuario)
        }
    }
    // Método para cargar los datos del usuario actual si se está modificando
    func cargarDatosUsuario(_ nombreUsuario: String) {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nombre == %@", nombreUsuario)
        do {
        let usuarios = try context.fetch(fetchRequest)
            if let usuario = usuarios.first {
                // Cargar datos del usuario en los campos de texto
                txtNombreUsuario.text = usuario.nombre
                txtContrasena.text = usuario.contrasena
            }
        } catch {
            print("Error al cargar datos del usuario: \(error)")
        }
    }

    @IBAction func BtnModificar(_ sender: UIButton) {
        guard let nombre = txtNombreUsuario.text, let contrasena = txtContrasena.text else {return}
        context.performAndWait {
            do {
                if let nombreUsuarioModificar = nombreUsuarioModificar {
                    // Modificar el usuario existente
                    try modificarUsuarioExistente(nombreUsuarioModificar, nombre, contrasena)
                } else {
                    // Crear un nuevo objeto de Usuario en Core Data
                    let nuevoUsuario = Usuario(context: context)
                    nuevoUsuario.nombre = nombre
                    nuevoUsuario.contrasena = contrasena
                }
                // Guardar el contexto para persistir los cambios en la base de datos
                try context.save()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.mostrarAlerta(titulo: "Registro Modificado", mensaje: "Usuario Modificado con Éxito")
                    // Realizar la redirección a la vista de inicio de sesión usando el segue
                    //self.performSegue(withIdentifier: "Login", sender: self)
                }
            } catch {
                print("Error al registrar/modificar usuario: \(error)")
                mostrarAlerta(titulo: "Error", mensaje: "Error al registrar/modificar usuario: \(error.localizedDescription)")
            }
        }
    }
        // Método para modificar un usuario existente
    // Método para modificar un usuario existente
    func modificarUsuarioExistente(_ nombreUsuario: String, _ nombre: String, _ contrasena: String) throws {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nombre == %@", nombreUsuario)
        do {
            let usuarios = try context.fetch(fetchRequest)
            if let usuarioExistente = usuarios.first {
                // Modificar los datos del usuario existente
                usuarioExistente.nombre = nombre
                usuarioExistente.contrasena = contrasena
            }
        } catch {
            print("Error al buscar usuario existente: \(error)")
            throw error
        }
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
