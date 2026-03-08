const express = require('express');
const router = express.Router();
const Setting = require('../models/Setting');

// @desc    Get public settings (Maintenance status, etc.)
// @route   GET /api/settings/public
// @access  Public
router.get('/public', async (req, res) => {
  try {
    const settings = await Setting.findOne().select('isMaintenanceMode contactEmail contactPhone');
    res.json(settings || { isMaintenanceMode: false });
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
});

module.exports = router;
