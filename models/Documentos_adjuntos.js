import {pool} from '../config/database.js'
// import bcrypt from "bcrypt";
export class Documentos_adjuntos{
    static async CrearDocumnetos({solicitud_id, nombre_archivo, url_archivo, fecha_subida}){
        try {
            const sql = 'INSERT INTO documentos_adjuntos(solicitud_id, nombre_archivo, url_archivo, fecha_subida )' +
             'VALUES (?, ?, ?, ?)';
                const [result] = await pool.execute(sql, [solicitud_id, nombre_archivo, url_archivo, fecha_subida ]);
                console.log(result);
                return result.insertId;
            } catch (err) {
                console.log(err);
                return err;
            }
       }
    }
export class Listar_documentos {
    static async ListarDocumentos() {
        try {
            const sql = 'SELECT * FROM documentos_adjuntos';
            const [rows] = await pool.execute(sql);
            return rows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}
export class Actualizar_documentos {
    static async ActualizarDocumento({id, solicitud_id, nombre_archivo, url_archivo, fecha_subida }) {
        try {
            const sql = 'UPDATE documentos_adjuntos SET solicitud_id = ?, nombre_archivo = ?, url_archivo = ?, fecha_subida = ? WHERE id = ?';
            const [result] = await pool.execute(sql, [solicitud_id, nombre_archivo, url_archivo, fecha_subida, id]);
            return result.affectedRows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}
export class Eliminar_documentos {
    static async EliminarDocumento(id) {
        try {
            const sql = 'DELETE FROM documentos_adjuntos WHERE id = ?';
            const [result] = await pool.execute(sql, [id]);
            return result.affectedRows;
        } catch (err) {
            console.error(err);
            throw err;
        }
    }
}
