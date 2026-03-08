const User = require('../models/User');

// @desc    Get all notifications for current user
// @route   GET /api/users/notifications
// @access  Private
const getNotifications = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('notifications');
    res.json(user.notifications.sort((a, b) => b.date - a.date));
  } catch (error) {
    res.status(500).json({ message: 'Bildirişlər gətirilərkən xəta baş verdi' });
  }
};

// @desc    Mark notification as read
// @route   PUT /api/users/notifications/:id/read
// @access  Private
const markAsRead = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const notification = user.notifications.id(req.params.id);
    
    if (notification) {
      notification.isRead = true;
      await user.save();
    }
    
    res.json(user.notifications);
  } catch (error) {
    res.status(500).json({ message: 'Bildiriş yenilənərkən xəta baş verdi' });
  }
};

module.exports = {
  getNotifications,
  markAsRead,
};
