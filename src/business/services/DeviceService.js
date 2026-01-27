import UserDevice from '../../data/models/UserDevice.js';

class DeviceService {
    static async registerDevice(userId, { fcmToken, platform, deviceId }) {
        const [device] = await UserDevice.findOrCreate({
            where: { userId, fcmToken },
            defaults: { platform, deviceId, isActive: true, lastSeenAt: new Date() },
        });

        await device.update({ platform, deviceId, isActive: true, lastSeenAt: new Date() });
        return device;
    }

    static async unregisterDevice(userId, fcmToken) {
        await UserDevice.update({ isActive: false }, { where: { userId, fcmToken } });
    }

    static async getActiveTokensByUserIds(userIds) {
        const devices = await UserDevice.findAll({ where: { userId: userIds, isActive: true } });
        const map = new Map();
        for (const d of devices) {
            if (!map.has(d.userId)) map.set(d.userId, []);
            map.get(d.userId).push(d.fcmToken);
        }
        return map;
    }

    static async disableToken(fcmToken) {
        await UserDevice.update({ isActive: false }, { where: { fcmToken } });
    }
}

export default DeviceService;
