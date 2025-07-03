import {pool} from '../config/database.js'
import bcrypt from "bcrypt";
export class User{
    static async CreateUser({correo, contrasena, rol }){
        try {
            const hashPassword = await bcrypt.hash(contrasena, 10);
            const sql = 'INSERT INTO usuarios(correo, contrasena, rol )' +
             'VALUES (?, ?, ?)';
                const [result] = await pool.execute(sql, [correo, hashPassword, rol ]);
                console.log(result);
                return result.insertId;
            } catch (err) {
                console.log(err);
                return err;
            }
       }
    }
 
export class Listar_usuarios {
    static async ListarUsuarios() {
        try {
            const sql = 'SELECT * FROM usuarios';
            const [rows] = await pool.execute(sql);
            return rows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}
export class Actualizar_usuarios {
    static async ActualizarUsuario({id, correo, contrasena, rol }) {
        try {
            const hashPassword = await bcrypt.hash(contrasena, 10);
            const sql = 'UPDATE usuarios SET correo = ?, contrasena = ?, rol = ? WHERE id = ?';
            const [result] = await pool.execute(sql, [correo, hashPassword, rol, id]);
            return result.affectedRows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}
export class Eliminar_usuarios {
    static async EliminarUsuario(id) {
        try {
            const sql = 'DELETE FROM usuarios WHERE id = ?';
            const [result] = await pool.execute(sql, [id]);
            return result.affectedRows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}


