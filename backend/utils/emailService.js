const { Resend } = require('resend');

const resend = new Resend(process.env.RESEND_API_KEY);

const sendResetEmail = async (email, token) => {
  try {
    const { data, error } = await resend.emails.send({
      from: 'SmartMarket <onboarding@resend.dev>', // Resend default test domain
      to: email,
      subject: 'Şifrə Sıfırlama Kodu',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #333;">SmartMarket Şifrə Sıfırlama</h2>
          <p>Siz şifrənizi sıfırlamaq üçün müraciət etmisiniz. Zəhmət olmasa aşağıdakı 6 rəqəmli kodu tətbiqə daxil edin:</p>
          <div style="background: #f4f4f4; padding: 15px; font-size: 24px; font-weight: bold; text-align: center; border-radius: 5px; letter-spacing: 5px;">
            ${token}
          </div>
          <p style="margin-top: 20px; color: #777; font-size: 12px;">Bu kod 10 dəqiqə ərzində etibarlıdır. Əgər bu müraciəti siz etməmisinizsə, bu emaili görməzdən gələ bilərsiniz.</p>
        </div>
      `,
    });

    console.log('Resend cavabı - Data:', data);
    if (error) {
      console.error('Email göndərilərkən xəta (Resend):', JSON.stringify(error, null, 2));
      return false;
    }

    return true;
  } catch (err) {
    console.error('Email xidməti xətası:', err);
    return false;
  }
};

const send2FACode = async (email, code) => {
  try {
    const { data, error } = await resend.emails.send({
      from: 'SmartMarket <onboarding@resend.dev>',
      to: email,
      subject: 'SmartMarket İki-Faktorlu Giriş Kodu',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #333;">SmartMarket Təhlükəsizlik</h2>
          <p>Sizin giriş kodunuz budur. Zəhmət olmasa tətbiqə daxil edin:</p>
          <div style="background: #e7f3ff; padding: 15px; font-size: 28px; font-weight: bold; text-align: center; border-radius: 5px; letter-spacing: 8px; color: #007bff;">
            ${code}
          </div>
          <p style="margin-top: 20px; color: #777; font-size: 12px;">Bu kod 5 dəqiqə ərzində etibarlıdır.</p>
        </div>
      `,
    });

    if (error) return false;
    return true;
  } catch (err) {
    return false;
  }
};

module.exports = { sendResetEmail, send2FACode };
