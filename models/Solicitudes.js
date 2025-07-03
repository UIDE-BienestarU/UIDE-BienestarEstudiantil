import {pool} from '../config/database.js'
// import bcrypt from "bcrypt";
export class solicitudes{
    static async CrearSolicitud({usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud }){
        try {
            const sql = 'INSERT INTO solicitudes(usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud )' +
             'VALUES (?, ?, ?, ?, ?, ?)';
                const [result] = await pool.execute(sql, [usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud ]);
                console.log(result);
                return result.insertId;
            } catch (err) {
                console.log(err);
                return err;
            }
       }
    }
export class Listar_solicitudes {
    static async ListarSolicitudes() {
        try {
            const sql = 'SELECT * FROM solicitudes';
            const [rows] = await pool.execute(sql);
            return rows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}
export class Actualizar_solicitudes {
    static async ActualizarSolicitud({id, usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud }) {
        try {
            const sql = 'UPDATE solicitudes SET usuario_id = ?, carrera = ?, tipo_solicitud = ?, descripcion = ?, estado = ?, fecha_solicitud = ? WHERE id = ?';
            const [result] = await pool.execute(sql, [usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud, id]);
            return result.affectedRows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}
export class Eliminar_solicitudes {
    static async EliminarSolicitud(id) {
        try {
            const sql = 'DELETE FROM solicitudes WHERE id = ?';
            const [result] = await pool.execute(sql, [id]);
            return result.affectedRows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}