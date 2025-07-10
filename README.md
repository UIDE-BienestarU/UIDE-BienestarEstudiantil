Configuración de la Base de Datos Bienestar UIDE con Sequelize

El proyecto utiliza Sequelize como ORM para interactuar con una base de datos MySQL, con dependencias gestionadas mediante npm.
Requisitos Previos

Instalación
Paso 1: Configurar el Proyecto

Clonar o Crear el Proyecto:Crea un nuevo proyecto Node.js o navega al directorio existente:
mkdir bienestar-uide
cd bienestar-uide
npm init -y


Instalar Dependencias:Instala las dependencias especificadas en el package.json:
npm install bcrypt@6.0.0 bcryptjs@3.0.2 cors@2.8.5 dotenv@17.0.1 express@5.1.0 jsonwebtoken@9.0.2 mysql2@3.14.1 sequelize@6.37.7 nodemon@3.1.10


Configurar Variables de Entorno:Crea un archivo .env en la raíz del proyecto para configurar la conexión a MySQL:
DB_HOST=localhost
DB_USER=tu_usuario
DB_PASSWORD=tu_contraseña
DB_NAME=bienestar_uide
DB_PORT=3306
JWT_SECRET=tu_secreto_jwt

Reemplaza tu_usuario, tu_contraseña y tu_secreto_jwt con tus credenciales de MySQL y una clave secreta para JWT.


Paso 2: Configurar la Base de Datos MySQL

Crear la Base de Datos:Conéctate a MySQL y crea la base de datos bienestar_uide:
CREATE DATABASE bienestar_uide;


Aplicar el Esquema (Opcional):Si prefieres usar el esquema SQL directamente, ejecuta schema.sql con un cliente MySQL:
mysql -u tu_usuario -p bienestar_uide < schema.sql

Esto crea las tablas e inserta 10 registros iniciales. Sin embargo, con Sequelize, puedes definir modelos y sincronizarlos (ver Paso 3).


Paso 3: Configurar Sequelize

Inicializar Sequelize:Crea un archivo de configuración para Sequelize (por ejemplo, config/database.js):
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
    logging: false,
  }
);

module.exports = sequelize;


Definir Modelos Sequelize:Crea un directorio models y define los modelos para cada tabla. Ejemplo para Usuario y Estudiante:
models/Usuario.js:
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Usuario = sequelize.define('Usuario', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  correo_institucional: {
    type: DataTypes.STRING(100),
    unique: true,
    allowNull: false,
  },
  contrasena: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  rol: {
    type: DataTypes.ENUM('estudiante', 'administrador'),
    allowNull: false,
  },
}, {
  tableName: 'Usuario',
  timestamps: false,
});

module.exports = Usuario;

models/Estudiante.js:
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Usuario = require('./Usuario');

const Estudiante = sequelize.define('Estudiante', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
  },
  nombre_completo: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  cedula: {
    type: DataTypes.STRING(20),
    unique: true,
    allowNull: false,
  },
  matricula: {
    type: DataTypes.STRING(20),
    unique: true,
    allowNull: false,
  },
  telefono: {
    type: DataTypes.STRING(15),
    allowNull: false,
  },
  carrera: {
    type: DataTypes.ENUM(
      'Ingeniería en Tecnologías de la Información',
      'Arquitectura',
      'Psicología',
      'Marketing',
      'Derecho',
      'Business'
    ),
    allowNull: false,
  },
  semestre: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
}, {
  tableName: 'Estudiante',
  timestamps: false,
});

Estudiante.belongsTo(Usuario, { foreignKey: 'id' });
Usuario.hasOne(Estudiante, { foreignKey: 'id' });

module.exports = Estudiante;

Crea archivos similares para Administrador, TipoSolicitud, SubtipoSolicitud, Solicitud, Documento, HistorialEstado, Discapacidad, y Notificacion, siguiendo el esquema SQL.

Configurar Asociaciones:Crea un archivo models/index.js para definir las relaciones entre tablas:
const sequelize = require('../config/database');
const Usuario = require('./Usuario');
const Estudiante = require('./Estudiante');
const Administrador = require('./Administrador');
const TipoSolicitud = require('./TipoSolicitud');
const SubtipoSolicitud = require('./SubtipoSolicitud');
const Solicitud = require('./Solicitud');
const Documento = require('./Documento');
const HistorialEstado = require('./HistorialEstado');
const Discapacidad = require('./Discapacidad');
const Notificacion = require('./Notificacion');

Administrador.belongsTo(Usuario, { foreignKey: 'id' });
SubtipoSolicitud.belongsTo(TipoSolicitud, { foreignKey: 'tipo_id' });
Solicitud.belongsTo(Estudiante, { foreignKey: 'estudiante_id' });
Solicitud.belongsTo(SubtipoSolicitud, { foreignKey: 'subtipo_id' });
Documento.belongsTo(Solicitud, { foreignKey: 'solicitud_id' });
HistorialEstado.belongsTo(Solicitud, { foreignKey: 'solicitud_id' });
HistorialEstado.belongsTo(Administrador, { foreignKey: 'admin_id' });
Discapacidad.belongsTo(Estudiante, { foreignKey: 'estudiante_id' });
Notificacion.belongsTo(Solicitud, { foreignKey: 'solicitud_id' });

module.exports = {
  sequelize,
  Usuario,
  Estudiante,
  Administrador,
  TipoSolicitud,
  SubtipoSolicitud,
  Solicitud,
  Documento,
  HistorialEstado,
  Discapacidad,
  Notificacion,
};


Sincronizar la Base de Datos:Crea un script (por ejemplo, init-db.js) para sincronizar los modelos con la base de datos:
const { sequelize } = require('./models');

async function initDb() {
  try {
    await sequelize.authenticate();
    console.log('Conexión establecida.');
    await sequelize.sync({ force: true }); // Usa force: true para recrear tablas
    console.log('Base de datos sincronizada.');
  } catch (error) {
    console.error('Error:', error);
  }
}

initDb();

Ejecútalo:
node init-db.js

Nota: force: true elimina las tablas existentes. Usa force: false para conservar datos si el esquema ya está aplicado.


Paso 4: Cargar Datos desde Archivos JSON
Para cargar los datos de schema.sql (10 inserciones iniciales) y sample_data.json (registros adicionales), crea un script de inicialización.

Crear un Script de Inicialización:Crea un archivo (por ejemplo, seeders/seed.js):
const { sequelize, Usuario, Estudiante, Administrador, TipoSolicitud, SubtipoSolicitud, Solicitud, Documento, HistorialEstado, Discapacidad, Notificacion } = require('../models');
const fs = require('fs');
const bcrypt = require('bcryptjs');

async function seedDatabase() {
  try {
    // Cargar datos JSON
    const jsonData = JSON.parse(fs.readFileSync('sample_data.json', 'utf8'));

    // Datos iniciales de schema.sql
    const initialData = {
      Usuario: [
        { correo_institucional: 'mateo.castillo@uide.edu.ec', contrasena: await bcrypt.hash('12345', 10), rol: 'estudiante' },
        { correo_institucional: 'cristian.salinas@uide.edu.ec', contrasena: await bcrypt.hash('67890', 10), rol: 'estudiante' },
        { correo_institucional: 'admin1@uide.edu.ec', contrasena: await bcrypt.hash('adminxd', 10), rol: 'administrador' },
      ],
      Estudiante: [
        { id: 1, nombre_completo: 'Mateo Castillo', cedula: '1105852212', matricula: 'U123456', telefono: '099111222', carrera: 'Psicología', semestre: 5 },
        { id: 2, nombre_completo: 'Cristian Salinas', cedula: '1100220022', matricula: 'U654321', telefono: '099333444', carrera: 'Ingeniería en Tecnologías de la Información', semestre: 3 },
      ],
      Administrador: [{ id: 3 }],
      TipoSolicitud: [
        { nombre: 'Beca', otrasSolicitudes: null },
        { nombre: 'Apoyo Psicoeducativo', otrasSolicitudes: null },
      ],
      SubtipoSolicitud: [
        { tipo_id: 1, nombre_sub: 'Beca por excelencia académica', otros_sub: null },
        { tipo_id: 2, nombre_sub: 'Apoyo psicológico', otros_sub: null },
      ],
      Solicitud: [
        { estudiante_id: 1, subtipo_id: 1, fecha_solicitud: '2025-07-01', estado_actual: 'Pendiente', nivel_urgencia: 'Normal', observaciones: 'Solicita ayuda por méritos académicos' },
      ],
      Documento: [
        { solicitud_id: 1, nombre_documento: 'Copia de cédula', url_archivo: 'https://uide.edu.ec/docs/cedula_mateo.pdf' },
      ],
      HistorialEstado: [
        { solicitud_id: 1, admin_id: 3, estado: 'Pendiente', comentario: 'Solicitud registrada correctamente' },
      ],
    };

    // Insertar datos
    for (const user of [...initialData.Usuario, ...jsonData.Usuario]) {
      await Usuario.create({
        ...user,
        contrasena: await bcrypt.hash(user.contrasena, 10),
      });
    }
    await Estudiante.bulkCreate([...initialData.Estudiante, ...jsonData.Estudiante]);
    await Administrador.bulkCreate([...initialData.Administrador, ...jsonData.Administrador]);
    await TipoSolicitud.bulkCreate([...initialData.TipoSolicitud, ...jsonData.TipoSolicitud]);
    await SubtipoSolicitud.bulkCreate([...initialData.SubtipoSolicitud, ...jsonData.SubtipoSolicitud]);
    await Solicitud.bulkCreate([...initialData.Solicitud, ...jsonData.Solicitud]);
    await Documento.bulkCreate([...initialData.Documento, ...jsonData.Documento]);
    await HistorialEstado.bulkCreate([...initialData.HistorialEstado, ...jsonData.HistorialEstado]);
    await Discapacidad.bulkCreate(jsonData.Discapacidad || []);
    await Notificacion.bulkCreate(jsonData.Notificacion || []);

    console.log('Base de datos inicializada con éxito.');
  } catch (error) {
    console.error('Error al inicializar:', error);
  } finally {
    await sequelize.close();
  }
}

seedDatabase();


Ejecutar el Script:Corre el script de inicialización:
node seeders/seed.js o el que se haya efinido en el packge.Json en mi caso npm start

Esto insertará los datos de schema.sql y datos.js, asegurando que las contraseñas estén hasheadas con bcryptjs.

Verificar Datos:Verifica los datos en la base de datos:
const { sequelize, Usuario } = require('./models');
async function checkData() {
  const users = await Usuario.findAll();
  console.log(users);
}
checkData();

O usa un cliente MySQL:
USE bienestar_uide;
SELECT * FROM Usuario; 
SELECT * FROM Estudiante;  
SELECT * FROM Solicitud;  



Paso 5: Configurar el Servidor Express con Rutas
Crea un archivo index.js en la raíz del proyecto para configurar el servidor Express con las rutas solicitadas:
const express = require('express');
const cors = require('cors');
const { sequelize, Usuario, Solicitud, Notificacion } = require('./models');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Middleware para autenticación JWT (opcional, descomentar para usar)
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Acceso denegado' });

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Token inválido' });
    req.user = user;
    next();
  });
};

// Rutas para Usuarios
app.get('/users', async (req, res) => {
  try {
    const users = await Usuario.findAll();
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener usuarios' });
  }
});

app.post('/users', async (req, res) => {
  try {
    const { correo_institucional, contrasena, rol } = req.body;
    const hashedPassword = await bcrypt.hash(contrasena, 10);
    const user = await Usuario.create({
      correo_institucional,
      contrasena: hashedPassword,
      rol,
    });
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ error: 'Error al crear usuario' });
  }
});

app.get('/users/:id', async (req, res) => {
  try {
    const user = await Usuario.findByPk(req.params.id);
    if (!user) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener usuario' });
  }
});

app.put('/users/:id', async (req, res) => {
  try {
    const { correo_institucional, contrasena, rol } = req.body;
    const user = await Usuario.findByPk(req.params.id);
    if (!user) return res.status(404).json({ error: 'Usuario no encontrado' });
    
    const updates = {};
    if (correo_institucional) updates.correo_institucional = correo_institucional;
    if (contrasena) updates.contrasena = await bcrypt.hash(contrasena, 10);
    if (rol) updates.rol = rol;

    await user.update(updates);
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: 'Error al actualizar usuario' });
  }
});

app.delete('/users/:id', async (req, res) => {
  try {
    const user = await Usuario.findByPk(req.params.id);
    if (!user) return res.status(404).json({ error: 'Usuario no encontrado' });
    await user.destroy();
    res.json({ message: 'Usuario eliminado' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar usuario' });
  }
});

// Rutas para Solicitudes
app.get('/solicitudes', async (req, res) => {
  try {
    const solicitudes = await Solicitud.findAll();
    res.json(solicitudes);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener solicitudes' });
  }
});

app.post('/solicitudes', async (req, res) => {
  try {
    const { estudiante_id, subtipo_id, fecha_solicitud, estado_actual, nivel_urgencia, observaciones } = req.body;
    const solicitud = await Solicitud.create({
      estudiante_id,
      subtipo_id,
      fecha_solicitud,
      estado_actual: estado_actual || 'Pendiente',
      nivel_urgencia: nivel_urgencia || 'Normal',
      observaciones,
    });
    res.status(201).json(solicitud);
  } catch (error) {
    res.status(400).json({ error: 'Error al crear solicitud' });
  }
});

app.get('/solicitudes/:id', async (req, res) => {
  try {
    const solicitud = await Solicitud.findByPk(req.params.id);
    if (!solicitud) return res.status(404).json({ error: 'Solicitud no encontrada' });
    res.json(solicitud);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener solicitud' });
  }
});

app.put('/solicitudes/:id', async (req, res) => {
  try {
    const { estado_actual, observaciones } = req.body;
    const solicitud = await Solicitud.findByPk(req.params.id);
    if (!solicitud) return res.status(404).json({ error: 'Solicitud no encontrada' });
    
    const updates = {};
    if (estado_actual) updates.estado_actual = estado_actual;
    if (observaciones) updates.observaciones = observaciones;

    await solicitud.update(updates);
    res.json(solicitud);
  } catch (error) {
    res.status(400).json({ error: 'Error al actualizar solicitud' });
  }
});

// Rutas para Notificaciones
app.get('/notificaciones', async (req, res) => {
  try {
    const notificaciones = await Notificacion.findAll();
    res.json(notificaciones);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener notificaciones' });
  }
});

app.listen(3000, async () => {
  try {
    await sequelize.authenticate();
    console.log('Conexión a la base de datos establecida.');
    console.log('Servidor corriendo en el puerto 3000');
  } catch (error) {
    console.error('Error al conectar con la base de datos:', error);
  }
});

Ejecuta el servidor con:
nodemon index.js o como se definio en el package.json

Paso 6: Probar las Rutas
Usa una herramienta como Postman o curl para probar las rutas:

GET /usuario: http://localhost:3000/usuario



GET /solicitudes:http://localhost:3000/solicitudes




Estructura de los Datos JSON

schema.sql Datos Iniciales:

3 Usuario (2 estudiantes, 1 administrador).
2 Estudiante.
1 Administrador.
2 TipoSolicitud.
2 SubtipoSolicitud.
1 Solicitud.
1 Documento.
1 HistorialEstado.


data.json:

5 Usuario (4 estudiantes, 1 administrador).
4 Estudiante.
1 Administrador.
2 TipoSolicitud.
3 SubtipoSolicitud.
4 Solicitud.
3 Documento.
3 HistorialEstado.
1 Discapacidad.
3 Notificacion.



Los datos JSON respetan las restricciones de claves foráneas y campos únicos (por ejemplo, correo_institucional, cedula, matricula).
Solución de Problemas mas comunes en el proyecto

Errores de Conexión: Verifica las credenciales en .env y asegúrate de que MySQL esté en ejecución.
Errores de Inicialización: Revisa duplicados en campos únicos o referencias de claves foráneas faltantes.
Problemas de Sincronización: Usa force: false en sequelize.sync para evitar eliminar datos existentes.
Errores de bcrypt: Usa bcryptjs para hashear contraseñas, ya que bcrypt puede tener problemas de compatibilidad.

Ejecutar la Aplicación
Para iniciar la aplicación con reinicio automático:
npm install
nodemon index.js

Para producción:
node index.js
Integrantes: Christian Salnas, Mateo Castillo, Anderson Calva y Erick Morales