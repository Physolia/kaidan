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

#pragma once

// QXmpp
#include <QXmppMessageReceiptManager.h>
// Kaidan
#include "Message.h"

class ClientWorker;
class QXmppMamManager;
class QXmppMessage;
class QXmppResultSetReply;

/**
 * @class MessageHandler Handler for incoming and outgoing messages.
 */
class MessageHandler : public QObject
{
	Q_OBJECT

public:
	MessageHandler(ClientWorker *clientWorker, QXmppClient *client, QObject *parent = nullptr);

	QFuture<QXmpp::SendResult> send(QXmppMessage &&message);

	void handleRosterReceived();
	void handleLastMessageStampFetched(const QDateTime &stamp);

	/**
	 * Handles incoming messages from the server.
	 */
	void handleMessage(const QXmppMessage &msg, MessageOrigin origin);

	/**
	 * Send a text message to any JID
	 */
	void sendMessage(const QString &toJid, const QString &body, bool isSpoiler, const QString &spoilerHint);

	/**
	 * Sends a chat state notification to the server.
	 */
	void sendChatState(const QString &toJid, const QXmppMessage::State state);

	/**
	 * Sends the corrected version of a message.
	 */
	void sendCorrectedMessage(Message msg);

	/**
	 * Sends a chat marker for a read message.
	 *
	 * @param chatJid bare JID of the chat that contains the read message
	 * @param messageId ID of the read message
	 */
	void sendReadMarker(const QString &chatJid, const QString &messageId);

	void sendMessageReaction(const QString &chatJid, const QString &messageId, const QVector<QString> &emojis);

signals:
	void sendMessageRequested(const QString &toJid,
				  const QString &body,
				  bool isSpoiler,
				  const QString &spoilerHint);

	void retrieveBacklogMessagesRequested(const QString &jid, const QDateTime &stamp);

private:
	void handleConnected();

	/**
	 * Handles pending messages found in the database.
	 */
	void handlePendingMessages(const QVector<Message> &messages);

	void sendPendingMessage(Message message);

	void retrieveInitialMessages();
	void retrieveCatchUpMessages(const QDateTime &stamp);
	void retrieveBacklogMessages(const QString &jid, const QDateTime &last);

	/**
	 * Handles a message that may contain a read marker.
	 *
	 * @return whether the message is handled because it contains a read marker
	 */
	bool handleReadMarker(const QXmppMessage &message, const QString &senderJid, const QString &recipientJid, bool isOwnMessage);

	bool handleReaction(const QXmppMessage &message, const QString &senderJid);

	static void parseSharedFiles(const QXmppMessage &message, Message &messageToEdit);
	static std::optional<File> parseOobUrl(const QXmppOutOfBandUrl &url, qint64 fileGroupId);

	ClientWorker *m_clientWorker;
	QXmppClient *m_client;
	QXmppMessageReceiptManager m_receiptManager;
	QXmppMamManager *m_mamManager;

	QDateTime m_lastMessageStamp;
	bool m_lastMessageLoaded = false;

	uint m_runningInitialMessageQueries = 0;
};
