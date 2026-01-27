import DeviceService from '../../business/services/DeviceService.js';
import { ok } from '../middleware/apiResponse.js';
import { ApiError } from '../middleware/errorHandler.js';

class DeviceController {
    static async register(req, res) {
        const { fcmToken, platform, deviceId } = req.body;
        if (!fcmToken || !platform) throw new ApiError(400, 'VALIDATION_ERROR', 'fcmToken y platform son requeridos');

        const device = await DeviceService.registerDevice(req.user.userId, { fcmToken, platform, deviceId });
        return ok(res, { message: 'Dispositivo registrado', data: device });
    }

    static async unregister(req, res) {
        const { fcmToken } = req.body;
        if (!fcmToken) throw new ApiError(400, 'VALIDATION_ERROR', 'fcmToken requerido');

        await DeviceService.unregisterDevice(req.user.userId, fcmToken);
        return ok(res, { message: 'Dispositivo desregistrado' });
    }
}

export default DeviceController;
