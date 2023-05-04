#ifndef BUGMODEL_H
#define BUGMODEL_H

#include <QObject>
#include <QTimer>
#include <QMutex>

class BugModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool activeBugCollision READ activeBugCollision WRITE setActiveBugCollision NOTIFY activeBugCollisionChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(int coinsCollected READ coinsCollected WRITE setCoinsCollected NOTIFY coinsCollectedChanged)

public:
    BugModel(QObject *parent=0);
    BugModel(int initialSpeed, QObject *parent=0);

    Q_INVOKABLE void initialize();

    bool activeBugCollision();
    void setActiveBugCollision(bool activeBugCollision);
    Q_INVOKABLE void bugCollision(int bugId, bool colliding);

    int coinsCollected();
    void setCoinsCollected(int coins);
    Q_INVOKABLE void addCoin();

    bool enabled();
    void setEnabled(bool enabled);

    int speed();
    void setSpeed(int speed);
    Q_INVOKABLE void startSpeedRun(int speed, int duration);

signals:
    void activeBugCollisionChanged();
    void coinsCollectedChanged();
    void enabledChanged();
    void speedChanged();
    void itemTimerFinished();

public slots:
    void speedTimerSlot();

private:
    bool m_activeBugCollision;
    int m_bugId;
    int m_coins;
    bool m_enabled;
    int m_speed;
    int m_initialSpeed;
    QTimer m_speedTimer;
};

#endif // BUGMODEL_H
