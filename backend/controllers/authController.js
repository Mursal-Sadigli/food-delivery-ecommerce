const User = require('../models/User');
const jwt = require('jsonwebtoken');
const { sendResetEmail, send2FACode } = require('../utils/emailService');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

exports.registerUser = async (req, res) => {
  try {
    const { name, email, password, referralCode: referredByCode } = req.body;
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({ message: 'İstifadəçi artıq mövcuddur' });
    }

    let referredBy = null;
    if (referredByCode) {
      const referrer = await User.findOne({ referralCode: referredByCode.toUpperCase() });
      if (referrer) {
        referredBy = referrer._id;
      }
    }

    const referralCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    const user = await User.create({ name, email, password, referralCode, referredBy });

    if (user) {
      res.status(201).json({
        _id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        token: generateToken(user._id),
      });
    } else {
      res.status(400).json({ message: 'Yanlış istifadəçi məlumatları' });
    }
  } catch (error) {
    console.error("Qeydiyyat Backend Xətası:", error);
    res.status(500).json({ message: 'Server xətası', error: error.message, stack: error.stack });
  }
};

exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });

    if (user && (await user.matchPassword(password))) {
      // Check if 2FA is enabled
      if (user.isTwoFactorEnabled) {
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        user.twoFactorCode = otp;
        user.twoFactorExpires = Date.now() + 5 * 60 * 1000; // 5 mins
        await user.save();

        await send2FACode(user.email, otp);

        return res.json({
          twoFactorRequired: true,
          email: user.email,
          message: 'İki-faktorlu doğrulama kodu emailinizə göndərildi'
        });
      }

      res.json({
        _id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        token: generateToken(user._id),
      });
    } else {
      res.status(401).json({ message: 'Yanlış email və ya şifrə' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası', error: error.message });
  }
};

// @desc    Şifrəni unutmusan - Token göndər
// @route   POST /api/auth/forgot-password
// @access  Public
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'Bu email ilə istifadəçi tapılmadı' });
    }

    // 6 rəqəmli token yaradın
    const resetToken = Math.floor(100000 + Math.random() * 900000).toString();
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpires = Date.now() + 10 * 60 * 1000; // 10 dəqiqə

    await user.save();

    // Resend vasitəsilə real email göndər
    const emailSent = await sendResetEmail(email, resetToken);

    if (emailSent) {
      res.json({ message: 'Şifrə bərpa kodu email ünvanınıza göndərildi' });
    } else {
      res.status(500).json({ message: 'Email göndərilərkən xəta baş verdi, lakin kod yaradıldı (Konsola baxın)', token: resetToken });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası', error: error.message });
  }
};

// @desc    Şifrəni sıfırla
// @route   POST /api/auth/reset-password
// @access  Public
exports.resetPassword = async (req, res) => {
  try {
    const { email, token, newPassword } = req.body;
    const user = await User.findOne({ 
      email,
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ message: 'Yanlış və ya vaxtı keçmiş bərpa kodu' });
    }

    user.password = newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;

    await user.save();

    res.json({ message: 'Şifrəniz uğurla yeniləndi' });
  } catch (error) {
    res.status(500).json({ message: 'Server xətası', error: error.message });
  }
};
// @desc    Sosial Giriş (Google/Apple)
// @route   POST /api/auth/social
// @access  Public
exports.socialLogin = async (req, res) => {
  try {
    const { email, name, provider, idToken } = req.body;
    
    // Real tətbiqdə burada idToken verified edilməlidir (google-auth-library və s. ilə)
    // Placeholder olaraq biz email-ə güvənirik.
    
    let user = await User.findOne({ email });

    if (user) {
      // İstifadəçi artıq var, sadəcə login et
      res.json({
        _id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        token: generateToken(user._id),
      });
    } else {
      // Yeni istifadəçi yarat
      // Sosial giriş üçün təsadüfi bir şifrə qoyuruq (əslində heç vaxt istifadə olunmayacaq)
      const password = Math.random().toString(36).slice(-10);
      const referralCode = Math.random().toString(36).substring(2, 8).toUpperCase();
      
      user = await User.create({
        name: name || 'Sosial İstifadəçi',
        email,
        password,
        isSocial: true,
        referralCode
      });

      if (user) {
        res.status(201).json({
          _id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          token: generateToken(user._id),
        });
      } else {
        res.status(400).json({ message: 'Sosial istifadəçi yaradılarkən xəta' });
      }
    }
  } catch (error) {
    console.error("Sosial Giriş Xətası:", error);
    res.status(500).json({ message: 'Server xətası', error: error.message });
  }
};
// @desc    Verify 2FA Code
// @route   POST /api/auth/verify-2fa
// @access  Public
exports.verify2FA = async (req, res) => {
  try {
    const { email, code } = req.body;
    const user = await User.findOne({ 
      email,
      twoFactorCode: code,
      twoFactorExpires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ message: 'Yanlış və ya vaxtı keçmiş 2FA kodu' });
    }

    user.twoFactorCode = undefined;
    user.twoFactorExpires = undefined;
    await user.save();

    res.json({
      _id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      token: generateToken(user._id),
    });
  } catch (error) {
    res.status(500).json({ message: 'Server xətası', error: error.message });
  }
};

// @desc    Toggle 2FA
// @route   POST /api/auth/toggle-2fa
// @access  Private
exports.toggle2FA = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ message: 'İstifadəçi tapılmadı' });

    user.isTwoFactorEnabled = !user.isTwoFactorEnabled;
    await user.save();

    res.json({ 
      isTwoFactorEnabled: user.isTwoFactorEnabled,
      message: user.isTwoFactorEnabled ? '2FA aktiv edildi' : '2FA deaktiv edildi' 
    });
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};
