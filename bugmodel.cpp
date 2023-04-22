#include <QDebug>
#include <QtMath>
#include "bugmodel.h"

BugModel::BugModel(QObject *parent)
    : QObject(parent)
{
}

void BugModel::initialize()
{
    setActiveBugCollision(false);
    setEnabled(true);
    setSpeed(100);
}

bool BugModel::activeBugCollision()
{
    return m_activeBugCollision;
}

void BugModel::setActiveBugCollision(bool activeBugCollision)
{
    if (activeBugCollision != m_activeBugCollision) {
        m_activeBugCollision = activeBugCollision;
        emit activeBugCollisionChanged();
    }
}

void BugModel::bugCollision(int bugId, bool colliding)
{
    if (! m_activeBugCollision && colliding) {
        m_bugId = bugId;
        setActiveBugCollision(true);
    }
    else if (m_activeBugCollision && m_bugId == bugId && ! colliding) {
        setActiveBugCollision(false);
    }
}

bool BugModel::enabled()
{
    return m_enabled;
}

void BugModel::setEnabled(bool enabled)
{
    if (enabled != m_enabled) {
        m_enabled = enabled;
        emit enabledChanged();
    }
}

int BugModel::speed()
{
    return m_speed;
}

void BugModel::setSpeed(int speed)
{
    if (speed != m_speed) {
        m_speed = speed;
        emit speedChanged();
    }
}
