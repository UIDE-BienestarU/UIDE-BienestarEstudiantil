import {pool} from '../config/database.js'
// import bcrypt from "bcrypt";
export class historial_solicitudes{
    static async CrearHistorial({solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por }){
        try {
            const sql = 'INSERT INTO historial_solicitudes(solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por )' +
             'VALUES (?, ?, ?, ?, ?, ?)';
                const [result] = await pool.execute(sql, [solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por ]);
                console.log(result);
                return result.insertId;
            } catch (err) {
                console.log(err);
                return err;
            }
       }
    }
    export class listar_historial_solicitudes{
    static async ListarHistorial() {
        try {
            const sql = 'SELECT * FROM historial_solicitudes';
            const [rows] = await pool.execute(sql);
            return rows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}

    export class actualizar_historial_solicitudes{
        static async ActualizarHistorial({solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por }) {
            try {
                const sql = 'UPDATE historial_solicitudes SET estado_anterior = ?, nuevo_estado = ?, observacion = ?, fecha_cambio = ?, actualizado_por = ? WHERE solicitud_id = ?';
                const [result] = await pool.execute(sql, [estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por, solicitud_id]);
                return result.affectedRows;
            } catch (err) {
                console.error(err);
                throw err;
            }
        }
    }
    export class eliminar_historial_solicitudes{
        static async EliminarHistorial(solicitud_id) {
            try {
                const sql = 'DELETE FROM historial_solicitudes WHERE solicitud_id = ?';
                const [result] = await pool.execute(sql, [solicitud_id]);
                return result.affectedRows;
            } catch (err) {
                console.error(err);
                throw err;
            }
        }
    }

export class HistorialSolicitudes {
    static async obtenerPorSolicitudId(solicitud_id) {
        return this.#consultar('solicitud_id', solicitud_id);
    }

    static async obtenerPorUsuarioId(usuario_id) {
        return this.#consultar('usuario_id', usuario_id);
    }

    static async obtenerPorEstado(nuevo_estado) {
        return this.#consultar('nuevo_estado', nuevo_estado);
    }

    static async obtenerPorFecha(fecha_cambio) {
        return this.#consultar('fecha_cambio', fecha_cambio);
    }

    static async #consultar(campo, valor) {
        try {
            const sql = `SELECT * FROM historial_solicitudes WHERE ${campo} = ?`;
            const [rows] = await pool.execute(sql, [valor]);
            return rows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}