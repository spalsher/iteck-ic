const QRCode = require('qrcode');

exports.generateQRCode = async (data) => {
  try {
    // Generate QR code as base64 string
    const qrCode = await QRCode.toDataURL(JSON.stringify(data), {
      errorCorrectionLevel: 'M',
      type: 'image/png',
      quality: 0.92,
      margin: 1,
      width: 300
    });
    return qrCode;
  } catch (error) {
    throw new Error('Failed to generate QR code');
  }
};
