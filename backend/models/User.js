const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  address: { type: String },
  profileImage: { type: String, default: '' },
  wishlist: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product' }],
  addresses: [
    {
      title: { type: String, required: true },
      address: { type: String, required: true },
      city: { type: String, required: true },
      postalCode: { type: String },
      country: { type: String, required: true },
      isDefault: { type: Boolean, default: false }
    }
  ],
  paymentMethods: [
    {
      cardHolderName: { type: String, required: true },
      cardNumber: { type: String, required: true }, // Should be stored securely or tokenized in real app
      expiryDate: { type: String, required: true },
      isDefault: { type: Boolean, default: false }
    }
  ],
  resetPasswordToken: { type: String },
  resetPasswordExpires: { type: Date },
  isSocial: { type: Boolean, default: false },
  provider: { type: String },
  walletBalance: { type: Number, default: 0 },
  walletTransactions: [
    {
      amount: { type: Number, required: true },
      type: { type: String, enum: ['deposit', 'payment', 'refund'], required: true },
      description: { type: String },
      date: { type: Date, default: Date.now }
    }
  ],
  notifications: [
    {
      title: { type: String, required: true },
      body: { type: String, required: true },
      type: { type: String, default: 'general' },
      isRead: { type: Boolean, default: false },
      date: { type: Date, default: Date.now }
    }
  ]
}, { timestamps: true });

// Parolu hash-ləmək
userSchema.pre('save', async function() {
  if (!this.isModified('password')) {
    return;
  }
  
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Parolu yoxlamaq
userSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
