/***********************************************************************
 *
 * Copyright (C) 2013 Graeme Gott <graeme@gottcode.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 ***********************************************************************/

#include "daily_progress.h"

#include "preferences.h"

#include <QFile>
#include <QSettings>

//-----------------------------------------------------------------------------

QString DailyProgress::m_path;

//-----------------------------------------------------------------------------

DailyProgress::DailyProgress(QObject* parent) :
	QObject(parent),
	m_words(0),
	m_msecs(0),
	m_type(0),
	m_goal(0),
	m_current_valid(false)
{
	// Fetch date of when the program was started
	QDate date = QDate::currentDate();
	m_current = new Progress(date);

	// Initialize daily progress data
	m_file = new QSettings(m_path, QSettings::IniFormat, this);

	int version = m_file->value(QLatin1String("Version"), -1).toInt();
	if (version == 1) {
		// Load current daily progress data from 1.5
		m_file->beginGroup(QLatin1String("Progress"));
		QVariantList values = m_file->value(date.toString(Qt::ISODate)).toList();
		m_words = values.value(0).toInt();
		m_msecs = values.value(1).toInt();
		m_type = values.value(2).toInt();
		m_goal = values.value(3).toInt();
	} else if (version == -1) {
		// Load current daily progress data from 1.4
		QSettings settings;
		if (settings.value(QLatin1String("Progress/Date")).toString() == date.toString(Qt::ISODate)) {
			m_words = settings.value(QLatin1String("Progress/Words"), 0).toInt();
			m_msecs = settings.value(QLatin1String("Progress/Time"), 0).toInt();
		}
		settings.remove(QLatin1String("Progress"));
		m_file->setValue(QLatin1String("Version"), 1);
		m_file->beginGroup(QLatin1String("Progress"));
	} else {
		int extra = 0;
		QString newpath = m_path + ".bak";
		while (QFile::exists(newpath)) {
			++extra;
			newpath = m_path + ".bak" + QString::number(extra);
		}
		QFile::copy(m_path, newpath);
		qWarning("The daily progress history is of unsupported version %d and could not be loaded.", version);
	}

	m_typing_timer.start();
}

//-----------------------------------------------------------------------------

DailyProgress::~DailyProgress()
{
	save();
	delete m_current;
}

//-----------------------------------------------------------------------------

int DailyProgress::percentComplete()
{
	if (!m_current_valid) {
		m_current_valid = true;
		m_current->setProgress(m_words, m_msecs, m_type, m_goal);
	}
	return m_current->progress();
}

//-----------------------------------------------------------------------------

void DailyProgress::increaseTime()
{
	qint64 msecs = m_typing_timer.restart();
	if (msecs < 30000) {
		m_msecs += msecs;
		m_current_valid = false;
	}
}

//-----------------------------------------------------------------------------

void DailyProgress::loadPreferences(const Preferences& preferences)
{
	m_type = preferences.goalType();
	if (m_type == 1) {
		m_goal = preferences.goalMinutes() * 60000;
	} else if (m_type == 2) {
		m_goal = preferences.goalWords();
	} else {
		m_goal = 0;
	}
	m_current_valid = false;
}

//-----------------------------------------------------------------------------

void DailyProgress::save()
{
	m_file->setValue(m_current->date().toString(Qt::ISODate), QVariantList()
			<< m_words
			<< m_msecs
			<< m_type
			<< m_goal);
}

//-----------------------------------------------------------------------------

void DailyProgress::setPath(const QString& path)
{
	m_path = path;
}

//-----------------------------------------------------------------------------

void DailyProgress::Progress::setProgress(int words, int msecs, int type, int goal)
{
	m_progress = 0;
	if (goal > 0) {
		if (type == 1) {
			m_progress = (msecs * 100) / goal;
		} else if (type == 2) {
			m_progress = (words * 100) / goal;
		}
	} else if (words || msecs) {
		m_progress = 100;
	}
}

//-----------------------------------------------------------------------------
