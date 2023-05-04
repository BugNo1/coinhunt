#include <QDebug>
#include <QtMath>
#include "bugmodel.h"

BugModel::BugModel(QObject *parent)
    : QObject(parent)
{
}

BugModel::BugModel(int initialSpeed, QObject *parent)
    : QObject(parent), m_initialSpeed(initialSpeed)
{
    m_speedTimer.setSingleShot(true);
    connect(&m_speedTimer, SIGNAL(timeout()), this, SLOT(speedTimerSlot()));
}

void BugModel::initialize()
{
    setActiveBugCollision(false);
    setEnabled(true);
    setSpeed(m_initialSpeed);
    setCoinsCollected(0);
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

int BugModel::coinsCollected()
{
    return m_coins;
}

void BugModel::setCoinsCollected(int coins)
{
    if (coins != m_coins) {
        m_coins = coins;
        emit coinsCollectedChanged();
    }
}

void BugModel::addCoin() {
    setCoinsCollected(m_coins + 1);
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

void BugModel::startSpeedRun(int speed, int duration)
{
    setSpeed(speed);
    m_speedTimer.start(duration);
}

void BugModel::speedTimerSlot()
{
    setSpeed(m_initialSpeed);
    emit itemTimerFinished();
}
