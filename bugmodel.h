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

public:
    BugModel(QObject *parent=0);

    Q_INVOKABLE void initialize();

    bool activeBugCollision();
    void setActiveBugCollision(bool activeBugCollision);
    Q_INVOKABLE void bugCollision(int bugId, bool colliding);

    bool enabled();
    void setEnabled(bool enabled);

    int speed();
    Q_INVOKABLE void setSpeed(int speed);

signals:
    void activeBugCollisionChanged();
    void enabledChanged();
    void speedChanged();

private:
    bool m_activeBugCollision;
    int m_bugId;
    bool m_enabled;
    int m_speed;
};

#endif // BUGMODEL_H
