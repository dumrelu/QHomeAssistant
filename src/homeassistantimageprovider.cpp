#include "homeassistantimageprovider.h"

#include <QSvgRenderer>
#include <QPainter>
#include <QDebug>

HomeAssistantImageProvider::HomeAssistantImageProvider()
    : QQuickImageProvider{ QQuickImageProvider::Image }
{
}

QImage HomeAssistantImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    const auto width = requestedSize.width() >= 0 ? requestedSize.width() : 128;
    const auto height = requestedSize.height() >= 0 ? requestedSize.height() : 128;

    QImage image{ QSize{ width, height }, QImage::Format_ARGB32 };
    image.fill(0xFFFFFF);
    QPainter imagePainter{ &image };
    QSvgRenderer svgRenderer{ QString{":/QHomeAssistant/icons/"} + id + ".svg" };
    if(svgRenderer.isValid())
    {
        svgRenderer.render(&imagePainter, QRectF{{0.0f, 0.0f}, requestedSize});
    }
    imagePainter.end();

    if(size)
    {
        *size = QSize{ width, height };
    }

    return image;
}
