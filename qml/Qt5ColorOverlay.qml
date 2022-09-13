import QtGraphicalEffects 1.12

ColorOverlay {
    source: image
    color: Qt.lighter(root.color, root.intensityFactor < 0.1 ? 0.1 : root.intensityFactor)
}
