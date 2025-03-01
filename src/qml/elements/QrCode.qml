// SPDX-FileCopyrightText: 2020 Melvin Keskin <melvo@olomono.de>
// SPDX-FileCopyrightText: 2021 Linus Jahn <lnj@kaidan.im>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.14
import QtQuick.Layouts 1.14
import org.kde.kirigami 2.19 as Kirigami

import im.kaidan.kaidan 1.0

/**
 * This is a QR code generated for a specified JID or the own JID.
 *
 * If "isForLogin" is true, a QR code with a login XMPP URI for logging in on
 * another device is generated.

 * Otherwise, a QR code with a Trust Message URI is generated.
 * The Trust Message URI contains key IDs that other clients can use to make
 * trust decisions but they can also just add that contact.
 * If a JID is provided, that JID is used for the URI.
 * Otherwise, the own JID is used.
 */
Kirigami.Icon {
	source: {
		if (width > 0) {
			if (isForLogin) {
				return qrCodeGenerator.generateLoginUriQrCode(width)
			} else if (jid) {
				return qrCodeGenerator.generateContactTrustMessageQrCode(width, jid)
			} else {
				return qrCodeGenerator.generateOwnTrustMessageQrCode(width)
			}
		}

		return ""
	}

	property bool isForLogin: false
	property string jid

	QrCodeGenerator {
		id: qrCodeGenerator
	}

	Connections {
		target: MessageModel

		// Update the currently displayed QR code.
		function onKeysChanged() {
			widthChanged()
		}
	}
}
