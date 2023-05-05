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
    Q_PROPERTY(int width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY heightChanged)

public:
    BugModel(QObject *parent=0);
    BugModel(int initialSpeed, int initialWidth, int initialHeight, QObject *parent=0);

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

    int width();
    void setWidth(int width);
    int height();
    void setHeight(int height);
    Q_INVOKABLE void startEnlargeRun(int width, int height, int duration);

signals:
    void activeBugCollisionChanged();
    void coinsCollectedChanged();
    void enabledChanged();
    void speedChanged();
    void widthChanged();
    void heightChanged();
    void itemTimerFinished();

public slots:
    void speedTimerSlot();
    void enlargeTimerSlot();

private:
    bool m_activeBugCollision;
    int m_bugId;
    int m_coins;
    bool m_enabled;
    int m_speed;
    int m_initialSpeed;
    int m_width;
    int m_initialWidth;
    int m_height;
    int m_initialHeight;
    QTimer m_speedTimer;
    QTimer m_enlargeTimer;
};

#endif // BUGMODEL_H
