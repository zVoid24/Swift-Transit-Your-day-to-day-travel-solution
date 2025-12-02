package utils

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"net/smtp"
	"os"
)

func SendEmail(to, subject, htmlBody string) error {
	from := os.Getenv("GMAIL")
	password := os.Getenv("GMAIL_PASSWORD")

	smtpHost := "smtp.gmail.com"
	smtpPort := "587"

	// Load logo image from assets
	imageBytes, err := os.ReadFile("assets/logo.png")
	if err != nil {
		return fmt.Errorf("error reading logo image: %w", err)
	}
	encodedImage := base64.StdEncoding.EncodeToString(imageBytes)

	// Boundary for multipart
	boundary := "SwiftBoundaryXYZ"

	var msg bytes.Buffer

	// Headers
	msg.WriteString("From: " + from + "\r\n")
	msg.WriteString("To: " + to + "\r\n")
	msg.WriteString("Subject: " + subject + "\r\n")
	msg.WriteString("MIME-Version: 1.0\r\n")
	msg.WriteString("Content-Type: multipart/related; boundary=\"" + boundary + "\"\r\n")
	msg.WriteString("\r\n")

	// HTML part
	msg.WriteString("--" + boundary + "\r\n")
	msg.WriteString("Content-Type: text/html; charset=\"UTF-8\"\r\n")
	msg.WriteString("Content-Transfer-Encoding: 7bit\r\n\r\n")
	msg.WriteString(htmlBody + "\r\n\r\n")

	// Image attachment (CID)
	msg.WriteString("--" + boundary + "\r\n")
	msg.WriteString("Content-Type: image/png\r\n")
	msg.WriteString("Content-ID: <swift-logo>\r\n")
	msg.WriteString("Content-Transfer-Encoding: base64\r\n")
	msg.WriteString("Content-Disposition: inline; filename=\"logo.png\"\r\n\r\n")
	msg.WriteString(encodedImage + "\r\n")
	msg.WriteString("--" + boundary + "--")

	auth := smtp.PlainAuth("", from, password, smtpHost)

	err = smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{to}, msg.Bytes())
	if err != nil {
		return fmt.Errorf("failed to send email: %w", err)
	}

	return nil
}
