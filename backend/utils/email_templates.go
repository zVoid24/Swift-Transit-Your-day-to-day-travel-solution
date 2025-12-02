package utils

import (
	"fmt"
)

func GetOTPEmailBody(otp string) string {
	return fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }

        .container {
            max-width: 620px;
            margin: 40px auto;
            background: #ffffff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 8px 20px rgba(0,0,0,0.08);
            border: 1px solid #e8e8e8;
        }

        .header {
            background-color: #0d2b24;
            text-align: center;
            padding: 30px 20px;
        }

        .logo {
            width: 90px;
            margin-bottom: 10px;
        }

        .title {
            color: #ffffff;
            font-size: 26px;
            font-weight: 700;
            margin: 0;
        }

        .content {
            padding: 35px 30px;
            text-align: center;
            color: #333333;
        }

        .content p {
            margin: 0 0 18px;
            font-size: 16px;
            line-height: 1.6;
        }

        .otp-box {
            background-color: #fdf6ec;
            border: 2px solid #c95b3d;
            border-radius: 8px;
            padding: 18px 0;
            width: 70%%;
            margin: 25px auto;
            font-size: 34px;
            font-weight: 700;
            letter-spacing: 8px;
            color: #c73d2c;
        }

        .note {
            font-size: 14px;
            color: #777777;
            margin-top: 20px;
        }

        .footer {
            background-color: #fafafa;
            padding: 20px;
            text-align: center;
            font-size: 12px;
            color: #999999;
            border-top: 1px solid #eeeeee;
        }

        .footer p {
            margin: 4px 0;
        }
    </style>
</head>

<body>
    <div class="container">

        <!-- Header with Logo -->
        <div class="header">
            <img src="cid:swift-logo" alt="Swift Transit Logo" class="logo" />
            <h1 class="title">Swift Transit</h1>
        </div>

        <!-- Main Content -->
        <div class="content">
            <p>Hello,</p>
            <p>Please use the One-Time Password (OTP) provided below to complete your verification.</p>

            <div class="otp-box">%s</div>

            <p class="note">This OTP is valid for 10 minutes. For your security, please do not share this code with anyone.</p>
        </div>

        <!-- Footer -->
        <div class="footer">
            <p>&copy; 2025 Swift Transit. All rights reserved.</p>
            <p>If you did not request this OTP, simply ignore this email.</p>
        </div>

    </div>
</body>
</html>
`, otp)
}
