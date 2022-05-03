/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2022 Kaidan developers and contributors
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

#include <memory>
#include <QObject>

class QSqlQuery;
class QSqlDatabase;
class QThreadPool;
struct DatabasePrivate;

/**
 * The Database class manages the SQL database. It opens the database and converts old
 * formats.
 */
class Database : public QObject
{
	Q_OBJECT
	friend class DatabaseComponent;

public:
	Database(QObject *parent = nullptr);
	~Database();

	/**
	 * Converts the database to the latest version and guarantees that all tables have
	 * been created.
	 */
	void createTables();

	/// Transaction on random thread from the thread pool (should be replaced in the
	/// future).
	void startTransaction();
	void commitTransaction();

private:
	QObject *dbWorker() const;
	QSqlDatabase currentDatabase();
	QSqlQuery createQuery();

	/// Returns the number of active transactions on the current thread.
	int &activeTransactions();
	/// Begins a transaction if none has been started.
	void transaction();
	/// Commits the transaction if every transaction has been finished.
	void commit();

	/**
	 * @return true if the database has to be converted using @c convertDatabase()
	 * because the database is not up-to-date.
	 */
	bool needToConvert();

	/**
	 * Converts the database to latest model.
	 */
	void convertDatabase();

	/**
	 * Loads the database information and detects the database version.
	 */
	void loadDatabaseInfo();

	/**
	 * Saves the database information.
	 */
	void saveDatabaseInfo();

	/**
	 * Creates a new database without content.
	 */
	void createNewDatabase();

	/*
	 * Upgrades the database to the next version.
	 */
	void convertDatabaseToV2();
	void convertDatabaseToV3();
	void convertDatabaseToV4();
	void convertDatabaseToV5();
	void convertDatabaseToV6();
	void convertDatabaseToV7();
	void convertDatabaseToV8();
	void convertDatabaseToV9();
	void convertDatabaseToV10();
	void convertDatabaseToV11();
	void convertDatabaseToV12();
	void convertDatabaseToV13();

	std::unique_ptr<DatabasePrivate> d;
};
