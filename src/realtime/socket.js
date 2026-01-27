// src/realtime/socket.js
import { Server } from 'socket.io';

let io;

export const initSocket = (httpServer, { corsOrigins = [] } = {}) => {
    io = new Server(httpServer, {
        cors: {
            origin: corsOrigins.length ? corsOrigins : true,
            methods: ['GET', 'POST'],
            credentials: false,
        },
    });

    io.on('connection', (socket) => {
        socket.on('join_objeto', ({ objetoId }) => {
            if (!objetoId) return;
            socket.join(`objeto:${objetoId}`);
        });

        socket.on('leave_objeto', ({ objetoId }) => {
            if (!objetoId) return;
            socket.leave(`objeto:${objetoId}`);
        });
    });

    return io;
};

export const emitComentarioObjeto = (objetoId, payload) => {
    if (!io) return;
    io.to(`objeto:${objetoId}`).emit('comentario_nuevo', payload);
};
