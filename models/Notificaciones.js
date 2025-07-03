import {pool} from '../config/database.js'
// import bcrypt from "bcrypt";
export class notificaciones{
    static async CrearNotificacion({usuario_id , mensaje, leido, fecha}){
        try {
            const sql = 'INSERT INTO notificaciones(usuario_id , mensaje, leido, fecha) ' +
             'VALUES (?, ?, ?, ?)';
                const [result] = await pool.execute(sql, [usuario_id , mensaje, leido, fecha]);
                console.log(result);
                return result.insertId;
            } catch (err) {
                console.log(err);
                return err;
            }
       }
    }
export class Listar_notificaciones {
    static async ListarNotificaciones() {
        try {
            const sql = 'SELECT * FROM notificaciones';
            const [rows] = await pool.execute(sql);
            return rows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}
export class Actualizar_notificaciones {
    static async ActualizarNotificacion({id, usuario_id , mensaje, leido, fecha }) {
        try {
            const sql = 'UPDATE notificaciones SET usuario_id  = ?, mensaje = ?, leido = ?, fecha = ? WHERE id = ?';
            const [result] = await pool.execute(sql, [usuario_id , mensaje, leido, fecha, id]);
            return result.affectedRows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}
export class Eliminar_notificaciones {
    static async EliminarNotificacion(id) {
        try {
            const sql = 'DELETE FROM notificaciones WHERE id = ?';
            const [result] = await pool.execute(sql, [id]);
            return result.affectedRows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}


