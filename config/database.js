import mysql from 'mysql2/promise';
export const pool = await mysql.createPool({
    host: 'localhost',
    user: 'root',
    database: 'bienestar_estudiantil',
    password: '123456',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
});

export const testConection = () => {
    pool.getConnection().then(data => {
        return {
            code: 200,
            message: "Conexión exitosa"
        }
    }, (err) => {
        return new Error("Error de conexión, revisa la contraseña");
    })
}



/* function testConection() {
    pool.getConnection().then(data => {
        return {
            code: 200,
            message: "Conexión exitosa"
        }
    }, (err) => {
        return new Error("Error de conexión, revisa la contraseña");
    })
} */