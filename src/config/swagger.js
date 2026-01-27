import swaggerJSDoc from 'swagger-jsdoc';

const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'API Bienestar UIDE',
            version: '1.0.0',
            description: 'Documentación oficial del backend de Bienestar Estudiantil',
        },
        servers: [
            {
                url: 'http://localhost:3000/api',
                description: 'Servidor local',
            },
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                },
            },
        },
        security: [{ bearerAuth: [] }],
    },

    apis: [
        './src/presentation/routes/*.js',
        './src/presentation/controllers/*.js',
    ],
};

export const swaggerSpec = swaggerJSDoc(options);
