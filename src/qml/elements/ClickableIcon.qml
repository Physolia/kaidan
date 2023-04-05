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
import org.kde.kirigami 2.19 as Kirigami

/**
 * This is a clickable icon changing its color on several events if possible.
 */
Kirigami.Icon  {
	width: Kirigami.Units.largeSpacing * 3.8
	height: width

	// Icons which cannot be colored (e.g. emojis) are highlighted in another way.
	active: mouseArea.containsMouse

	property alias mouseArea: mouseArea
	signal clicked()

	MouseArea {
		id: mouseArea

		property bool remainTooltip: false

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		Controls.ToolTip.text: parent.Controls.ToolTip.text
		Controls.ToolTip.delay: Kirigami.Settings.isMobile ? 0 : Kirigami.Units.veryLongDuration * 2
		Controls.ToolTip.timeout: Kirigami.Units.veryLongDuration * 10
		onEntered: {
			parent.color = Kirigami.Theme.hoverColor

			if (Controls.ToolTip.text && !Kirigami.Settings.isMobile) {
				Controls.ToolTip.show(Controls.ToolTip.text, Controls.ToolTip.timeout)
			}
		}
		onPressed: {
			parent.color = Kirigami.Theme.focusColor

			if (Controls.ToolTip.text && !Kirigami.Settings.isMobile) {
				Controls.ToolTip.hide()
			}
		}
		onPressAndHold: {
			if (Controls.ToolTip.text && Kirigami.Settings.isMobile) {
				remainTooltip = true
				Controls.ToolTip.show(Controls.ToolTip.text, Controls.ToolTip.timeout)
			}
		}
		onReleased: {
			if (Controls.ToolTip.text && Kirigami.Settings.isMobile) {
				if (remainTooltip) {
					remainTooltip = false
					// TODO: Remain tooltip on mobile devices
					Controls.ToolTip.show(Controls.ToolTip.text, Controls.ToolTip.timeout)
				}
			}
		}
		onExited: {
			parent.color = Kirigami.Theme.textColor
		}
		onClicked: {
			parent.clicked()

			if (containsMouse)
				entered()
			else
				exited()
		}
	}
}
