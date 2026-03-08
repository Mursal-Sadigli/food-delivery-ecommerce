const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema({
  admin: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  action: { type: String, required: true }, // Məs: "DELETE_PRODUCT", "UPDATE_CONFIG", "CHANGE_USER_ROLE"
  targetType: { type: String, required: true }, // Məs: "Product", "User", "Setting"
  targetId: { type: String },
  details: { type: String },
  ipAddress: { type: String },
  userAgent: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('AuditLog', auditLogSchema);
