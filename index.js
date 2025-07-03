import express from 'express';
import {User, Listar_usuarios, Actualizar_usuarios, Eliminar_usuarios } from './models/User.js'
import {solicitudes, Listar_solicitudes, Actualizar_solicitudes, Eliminar_solicitudes} from './models/Solicitudes.js'
import {historial_solicitudes, listar_historial_solicitudes, actualizar_historial_solicitudes, eliminar_historial_solicitudes} from './models/Historial_solicitudes.js'
import { notificaciones, Listar_notificaciones, Actualizar_notificaciones, Eliminar_notificaciones} from './models/Notificaciones.js'
import { Documentos_adjuntos, Listar_documentos, Actualizar_documentos, Eliminar_documentos } from './models/Documentos_adjuntos.js'
const port = 3000
const app = express()

//Cof de middleware 
app.use(express.json());

app.get('/', (req, res) => {
  res.send('Hello World!')
})
//API para un usuario
app.post('/create', async (req, res) => {
    const {correo, contrasena, rol } = req.body;
    console.log("el correo es: " + correo);
    try{
        const resultCreateUser = await User.CreateUser({correo, contrasena, rol });
        console.log("Datos recibidos:", { correo, contrasena, rol });
        console.log(resultCreateUser);
        res.send('API funciona')

    }catch(err){
        res.send(err)

    }
})
app.get('/listar', async (req, res) => {
    try {
        const usuarios = await Listar_usuarios.ListarUsuarios();
        res.json(usuarios);
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al listar los usuarios');
    }
})
app.put('/actualizar', async (req, res) => {
    const {id, correo, contrasena, rol } = req.body;
    try {
        const resultActualizarUsuario = await Actualizar_usuarios.ActualizarUsuario({id, correo, contrasena, rol });
        console.log("Datos recibidos:", { id, correo, contrasena, rol });
        console.log(resultActualizarUsuario);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al actualizar el usuario');
    }
})
app.delete('/eliminar/:id', async (req, res) => {   
    const { id } = req.params;
    try {
        const resultEliminarUsuario = await Eliminar_usuarios.EliminarUsuario(id);
        console.log("Usuario eliminado con ID:", id);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al eliminar el usuario');
    }
})
//API para una solicitud
app.post('/createsolicitud', async (req, res) => {
    const {usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud } = req.body;
    console.log("la solicitud es: " + tipo_solicitud);
    try{
        const resultCrearSolicitud = await solicitudes.CrearSolicitud({usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud });
        console.log("Datos recibidos:", { usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud });
        console.log(resultCrearSolicitud);
        res.send('API funciona')

    }catch(err){
        res.send(err)

    }
})
app.get('/listarsolicitudes', async (req, res) => {
    try {
        const solicitudesList = await Listar_solicitudes.ListarSolicitudes();
        res.json(solicitudesList);
    } catch (err) {  
        console.error(err);
        res.status(500).send('Error al listar las solicitudes');
    }
})
app.put('/actualizarsolicitud', async (req, res) => {
    const {id, usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud } = req.body;
    try {
        const resultActualizarSolicitud = await Actualizar_solicitudes.ActualizarSolicitud({id, usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud });
        console.log("Datos recibidos:", { id, usuario_id, carrera, tipo_solicitud, descripcion, estado, fecha_solicitud });
        console.log(resultActualizarSolicitud);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al actualizar la solicitud');
    }
})
app.delete('/eliminarsolicitud/:id', async (req, res) => { 
    const { id } = req.params;
    try {
        const resultEliminarSolicitud = await Eliminar_solicitudes.EliminarSolicitud(id);
        console.log("Solicitud eliminada con ID:", id);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al eliminar la solicitud');
    }
})

//API para un historial de solicitudes
app.post('/crearhistorial', async (req, res) => {
    const {solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por } = req.body;
    console.log("la solicitud es: " + solicitud_id);
    try{
        const resultCrearSolicitudHistorial = await historial_solicitudes.CrearHistorial({solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por });
        console.log("Datos recibidos:", { solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por });
        console.log(resultCrearSolicitudHistorial);
        res.send('API funciona')

    }catch(err){
        res.send(err)

    }
})
app.get('/listarhistorial', async (req, res) => {
    try {
        const historial = await listar_historial_solicitudes.ListarHistorial();
        res.json(historial);
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al listar el historial de solicitudes');
    }
})
app.put('/actualizarhistorial', async (req, res) => {
    const {solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por } = req.body;
    try {
        const resultActualizarHistorial = await actualizar_historial_solicitudes.ActualizarHistorial({solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por });
        console.log("Datos recibidos:", { solicitud_id, estado_anterior, nuevo_estado, observacion, fecha_cambio, actualizado_por });
        console.log(resultActualizarHistorial);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al actualizar el historial de solicitudes');
    }
})
app.delete('/eliminarhistorial/:solicitud_id', async (req, res) => {
    const { solicitud_id } = req.params;
    try {
        const resultEliminarHistorial = await eliminar_historial_solicitudes.EliminarHistorial(solicitud_id);
        console.log("Solicitud eliminada con ID:", solicitud_id);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al eliminar el historial de solicitudes');
    }
})

//API para una notificacion
app.post('/crearnotificacion', async (req, res) => {
    const {usuario_id , mensaje, leido, fecha} = req.body;
    console.log("la notificacion es: " + mensaje);
    try{
        const resultCrearNotificacion = await notificaciones.CrearNotificacion({usuario_id , mensaje, leido, fecha});
        console.log("Datos recibidos:", { usuario_id , mensaje, leido, fecha });
        console.log(resultCrearNotificacion);
        res.send('API funciona')

    }catch(err){
        res.send(err)

    }
})
app.get('/listarnotificaciones', async (req, res) => {
    try {
        const notificacionesList = await Listar_notificaciones.ListarNotificaciones();
        res.json(notificacionesList);
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al listar las notificaciones');
    }
})
app.put('/actualizarnotificacion', async (req, res) => {
    const {id, usuario_id , mensaje, leido, fecha } = req.body;
    try {
        const resultActualizarNotificacion = await Actualizar_notificaciones.ActualizarNotificacion({id, usuario_id , mensaje, leido, fecha });
        console.log("Datos recibidos:", { id, usuario_id , mensaje, leido, fecha });
        console.log(resultActualizarNotificacion);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al actualizar la notificación');
    }
})
app.delete('/eliminarnotificacion/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const resultEliminarNotificacion = await Eliminar_notificaciones.EliminarNotificacion(id);
        console.log("Notificación eliminada con ID:", id);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al eliminar la notificación');
    }
})
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

//API para un documento adjunto
app.post('/creardocumento', async (req, res) => {
    const {solicitud_id, nombre_archivo, url_archivo, fecha_subida} = req.body;
    console.log("el documento es: " + nombre_archivo);
    try{
        const resultCrearDocumento = await Documentos_adjuntos.CrearDocumnetos({solicitud_id, nombre_archivo, url_archivo, fecha_subida});
        console.log("Datos recibidos:", { solicitud_id, nombre_archivo, url_archivo, fecha_subida });
        console.log(resultCrearDocumento);
        res.send('API funciona')

    }catch(err){
        res.send(err)

    }
})
app.get('/listardocumentos', async (req, res) => {
    try {
        const documentosList = await Listar_documentos.ListarDocumentos();
        res.json(documentosList);
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al listar los documentos adjuntos');
    }
})
app.put('/actualizardocumento', async (req, res) => {
    const {id, solicitud_id, nombre_archivo, url_archivo, fecha_subida } = req.body;
    try {
        const resultActualizarDocumento = await Actualizar_documentos.ActualizarDocumento({id, solicitud_id, nombre_archivo, url_archivo, fecha_subida });
        console.log("Datos recibidos:", { id, solicitud_id, nombre_archivo, url_archivo, fecha_subida });
        console.log(resultActualizarDocumento);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al actualizar el documento adjunto');
    }
})
app.delete('/eliminardocumento/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const resultEliminarDocumento = await Eliminar_documentos.EliminarDocumento(id);
        console.log("Documento eliminado con ID:", id);
        res.send('API funciona')
    } catch (err) {
        console.error(err);
        res.status(500).send('Error al eliminar el documento adjunto');
    }
})