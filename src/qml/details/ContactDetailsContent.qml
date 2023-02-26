// SPDX-FileCopyrightText: 2023 Melvin Keskin <melvo@olomono.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.14
import QtQuick.Layouts 1.14
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import im.kaidan.kaidan 1.0
import "../elements"

DetailsContent {
	id: root

	property bool isChatWithOneself: MessageModel.currentAccountJid === jid

	encryptionArea: ColumnLayout {
		spacing: 0

		OmemoWatcher {
			id: accountOmemoWatcher
			jid: AccountManager.jid
		}

		OmemoWatcher {
			id: contactOmemoWatcher
			jid: root.jid
		}

		MobileForm.FormCardHeader {
			title: qsTr("Encryption")
		}

		MobileForm.FormSwitchDelegate {
			text: qsTr("OMEMO 2")
			description: qsTr("End-to-end encryption with OMEMO 2 ensures that nobody else than you and your chat partners can read or modify the data you exchange.")
			enabled: MessageModel.usableOmemoDevices.length
			checked: MessageModel.isOmemoEncryptionEnabled
			// The switch is toggled by setting the user's preference on using encryption.
			// Note that 'checked' has already the value after the button is clicked.
			onClicked: MessageModel.encryption = checked ? Encryption.Omemo2 : Encryption.NoEncryption
		}

		MobileForm.FormButtonDelegate {
			text: {
				if (!MessageModel.usableOmemoDevices.length) {
					if (accountOmemoWatcher.distrustedOmemoDevices.length) {
						return qsTr("Scan the QR codes of <b>your</b> devices to encrypt for them")
					} else if (ownResourcesWatcher.resourcesCount > 1) {
						return qsTr("<b>Your</b> other devices don't use OMEMO 2")
					} else if (root.isChatWithOneself) {
						return qsTr("<b>You</b> have no other devices supporting OMEMO 2")
					}
				} else if (accountOmemoWatcher.authenticatableOmemoDevices.length) {
					if (accountOmemoWatcher.authenticatableOmemoDevices.length === accountOmemoWatcher.distrustedOmemoDevices.length) {
						return qsTr("Scan the QR codes of <b>your</b> devices to encrypt for them")
					}

					return qsTr("Scan the QR codes of <b>your</b> devices for maximum security")
				}

				return ""
			}
			icon.name: {
				if (!MessageModel.usableOmemoDevices.length) {
					if (accountOmemoWatcher.distrustedOmemoDevices.length) {
						return "channel-secure-symbolic"
					} else if (ownResourcesWatcher.resourcesCount > 1) {
						return "channel-insecure-symbolic"
					} else if (root.isChatWithOneself) {
						return "channel-insecure-symbolic"
					}
				} else if (accountOmemoWatcher.authenticatableOmemoDevices.length) {
					if (accountOmemoWatcher.authenticatableOmemoDevices.length === accountOmemoWatcher.distrustedOmemoDevices.length) {
						return "security-medium-symbolic"
					}

					return "security-high-symbolic"
				}

				return ""
			}
			visible: text
			enabled: accountOmemoWatcher.authenticatableOmemoDevices.length
			onClicked: pageStack.layers.push(qrCodePage, { isForOwnDevices: true })

			UserResourcesWatcher {
				id: ownResourcesWatcher
				jid: AccountManager.jid
			}
		}

		MobileForm.FormButtonDelegate {
			text: {
				if(root.isChatWithOneself) {
					return ""
				}

				if (!MessageModel.usableOmemoDevices.length) {
					if (contactOmemoWatcher.distrustedOmemoDevices.length) {
						return qsTr("Scan the QR code of your <b>contact</b> to enable encryption")
					}

					return qsTr("Your <b>contact</b> doesn't use OMEMO 2")
				} else if (contactOmemoWatcher.authenticatableOmemoDevices.length) {
					if (contactOmemoWatcher.authenticatableOmemoDevices.length === contactOmemoWatcher.distrustedOmemoDevices.length) {
						return qsTr("Scan the QR codes of your <b>contact's</b> devices to encrypt for them")
					}

					return qsTr("Scan the QR code of your <b>contact</b> for maximum security")
				}

				return ""
			}
			icon.name: {
				if (!MessageModel.usableOmemoDevices.length) {
					if (contactOmemoWatcher.distrustedOmemoDevices.length) {
						return "channel-secure-symbolic"
					}

					return "channel-insecure-symbolic"
				} else if (contactOmemoWatcher.authenticatableOmemoDevices.length) {
					if (contactOmemoWatcher.authenticatableOmemoDevices.length === contactOmemoWatcher.distrustedOmemoDevices.length) {
						return "security-medium-symbolic"
					}

					return "security-high-symbolic"
				}

				return ""
			}
			visible: text
			enabled: contactOmemoWatcher.authenticatableOmemoDevices.length
			onClicked: pageStack.layers.push(qrCodePage, { contactJid: root.jid })
		}
	}

	RosterItemWatcher {
		id: contactWatcher
		jid: root.jid
	}

	MobileForm.FormCard {
		Layout.fillWidth: true

		contentItem: ColumnLayout {
			spacing: 0

			MobileForm.FormCardHeader {
				title: qsTr("Notifications")
			}

			MobileForm.FormSwitchDelegate {
				text: qsTr("Incoming messages")
				description: qsTr("Show notification and play sound on message arrival")
				checked: !mutedWatcher.muted
				onToggled: mutedWatcher.muted = !mutedWatcher.muted

				NotificationsMutedWatcher {
					id: mutedWatcher
					jid: root.jid
				}
			}
		}
	}

	MobileForm.FormCard {
		Layout.fillWidth: true

		contentItem: ColumnLayout {
			spacing: 0

			MobileForm.FormCardHeader {
				title: qsTr("Privacy")
			}

			MobileForm.FormButtonDelegate {
				text: qsTr("Request status")
				description: qsTr("Request contact's availability, devices and other personal information")
				visible: !contactWatcher.item.sendingPresence
				onClicked: Kaidan.client.rosterManager.subscribeToPresenceRequested(root.jid)
			}

			MobileForm.FormSwitchDelegate {
				text: qsTr("Send status")
				description: qsTr("Provide your availability, devices and other personal information")
				checked: contactWatcher.item.receivingPresence
				visible: !isChatWithOneself
				onToggled: {
					if (checked) {
						Kaidan.client.rosterManager.acceptSubscriptionToPresenceRequested(MessageModel.currentChatJid)
					} else {
						Kaidan.client.rosterManager.refuseSubscriptionToPresenceRequested(MessageModel.currentChatJid)
					}
				}
			}

			MobileForm.FormSwitchDelegate {
				text: qsTr("Send typing notifications")
				description: qsTr("Indicate when you have this conversation open, are typing and stopped typing")
				checked: contactWatcher.item.chatStateSendingEnabled
				onToggled: {
					RosterModel.setChatStateSendingEnabled(
						MessageModel.currentAccountJid,
						MessageModel.currentChatJid,
						checked)
				}
			}

			MobileForm.FormSwitchDelegate {
				text: qsTr("Send read notifications")
				description: qsTr("Indicate which messages you have read")
				checked: contactWatcher.item.readMarkerSendingEnabled
				onToggled: {
					RosterModel.setReadMarkerSendingEnabled(
						MessageModel.currentAccountJid,
						MessageModel.currentChatJid,
						checked)
				}
			}
		}
	}

	MobileForm.FormCard {
		Layout.fillWidth: true

		contentItem: ColumnLayout {
			spacing: 0

			MobileForm.FormCardHeader {
				title: qsTr("Removal")
			}

			ColumnLayout {
				spacing: 0

				MobileForm.FormButtonDelegate {
					id: removalButton
					text: qsTr("Remove")
					description: qsTr("Remove contact and complete chat history")
					icon.name: "edit-delete-symbolic"
					icon.color: "red"
					checkable: true
					onToggled: contactRemovalCorfirmButton.visible = !contactRemovalCorfirmButton.visible
				}

				MobileForm.FormButtonDelegate {
					id: contactRemovalCorfirmButton
					text: qsTr("Confirm")
					visible: false
					Layout.leftMargin: Kirigami.Units.largeSpacing * 6
					onClicked: {
						visible = false
						removalButton.enabled = false
						Kaidan.client.rosterManager.removeContactRequested(jid)
					}
				}
			}
		}
	}
}
