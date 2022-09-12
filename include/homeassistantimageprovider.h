#pragma once

#include <QQuickImageProvider>

class HomeAssistantImageProvider : public QQuickImageProvider
{
public:
    HomeAssistantImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
};
