/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2023 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.14
import QtQuick.Controls 2.14 as Controls
import QtQuick.Layouts 1.14
import org.kde.kirigami 2.12 as Kirigami
import "../elements"
import im.kaidan.kaidan 1.0
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

SettingsPageBase {
	title: qsTr("Delete account")
	implicitHeight: layout.implicitHeight
	implicitWidth: layout.implicitWidth
	ColumnLayout {
		id: layout

		anchors.fill: parent
		Layout.preferredWidth: 600

		MobileForm.FormCard {
			Layout.fillWidth: true

			contentItem: ColumnLayout {
				spacing: 0

				MobileForm.FormCardHeader {
					title: qsTr("Warning")
				}
				MobileForm.AbstractFormDelegate {
					Layout.fillWidth: true
					Layout.fillHeight: true

					contentItem: RowLayout {
						Kirigami.Icon {
							Layout.fillHeight: true

							source: "dialog-warning"
						}
						Controls.Label {
							Layout.fillWidth: true
							Layout.fillHeight: true

							text: qsTr("Your account will be deleted completely, which means from this app and from the server. You will not be able to use your account again!")
							wrapMode: Text.Wrap
						}
					}
				}
			}
		}


		Item {
			Layout.fillHeight: true
		}

		MobileForm.FormCard {
			id: card
			Layout.fillWidth: true

			contentItem: RowLayout {
				spacing: 0
				MobileForm.AbstractFormDelegate {
					Layout.fillWidth: true
					implicitWidth: (card.width/2)-1
					onClicked: stack.pop()
					contentItem: RowLayout {
						Kirigami.Icon {
							source: "dialog-cancel"
						}
						Controls.Label {
							Layout.fillWidth: true
							text: qsTr("Cancel")
							wrapMode: Text.Wrap
						}
					}
				}

				Kirigami.Separator{
					Layout.fillHeight: true
				}
				MobileForm.AbstractFormDelegate {
					Layout.fillWidth: true

					implicitWidth: (card.width/2)-1
					onClicked:{
						Kaidan.deleteAccountFromClientAndServer()
						settingsSheet.close()
						stack.initialItem && stack.pop(stack.initialItem)
					}
					contentItem: RowLayout {
						Kirigami.Icon {
							source: "checkbox"
							Layout.rightMargin: Kirigami.Units.largeSpacing
							width: Kirigami.Units.iconSizes.small
							height: Kirigami.Units.iconSizes.small
						}
						Controls.Label {
							Layout.fillWidth: true
							text: qsTr("Delete Account")
							wrapMode: Text.Wrap
						}
					}
				}
			}
		}
	}
}
