const Setting = require('../models/Setting');

const maintenanceMiddleware = async (req, res, next) => {
  try {
    // Public settings və Admin API-ləri üçün yoxlama etmirik
    if (req.path.startsWith('/api/settings/public') || req.path.startsWith('/api/admin')) {
      return next();
    }

    const settings = await Setting.findOne();
    
    if (settings && settings.isMaintenanceMode) {
      // Əgər istifadəçi giriş edibsə və admindirsə, davam etsin
      if (req.user && req.user.role === 'admin') {
        return next();
      }

      return res.status(503).json({
        message: 'Platformada hazırda texniki xidmət işləri gedir. Tezliklə yenidən aktiv olacağıq.',
        isMaintenance: true
      });
    }

    next();
  } catch (error) {
    console.error('Maintenance Middleware Error:', error);
    next();
  }
};

module.exports = maintenanceMiddleware;
