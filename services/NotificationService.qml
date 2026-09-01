pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property alias model: notifications
    property alias popupModel: popups
    readonly property int count: notifications.count
    readonly property int popupCount: popups.count

    function iconSource(notification) {
        const source = notification.image || notification.appIcon;
        if (!source)
            return "";
        if (source.startsWith("/") )
            return "file://" + source;
        if (source.includes(":"))
            return source;
        return Quickshell.iconPath(source);
    }

    function removeById(id) {
        for (let index = 0; index < notifications.count; index++) {
            if (notifications.get(index).notificationId === id) {
                notifications.remove(index);
                break;
            }
        }
        removePopupById(id);
    }

    function removePopupById(id) {
        for (let index = 0; index < popups.count; index++) {
            if (popups.get(index).notificationId === id) {
                popups.remove(index);
                return;
            }
        }
    }

    function dismiss(index) {
        if (index < 0 || index >= notifications.count)
            return;
        const notification = notifications.get(index).notification;
        const notificationId = notifications.get(index).notificationId;
        notifications.remove(index);
        removePopupById(notificationId);
        if (notification)
            notification.dismiss();
    }

    function clear() {
        const tracked = [];
        for (let index = 0; index < notifications.count; index++)
            tracked.push(notifications.get(index).notification);
        notifications.clear();
        popups.clear();
        for (const notification of tracked) {
            if (notification)
                notification.dismiss();
        }
    }

    ListModel { id: notifications }
    ListModel { id: popups }

    NotificationServer {
        id: server

        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        actionsSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true;
            root.removeById(notification.id);
            notifications.insert(0, {
                notification: notification,
                notificationId: notification.id,
                appName: notification.appName || "Notification",
                summary: notification.summary || "Notification",
                body: notification.body || "",
                icon: root.iconSource(notification),
                receivedAt: new Date()
            });
            popups.append({
                notificationId: notification.id,
                appName: notification.appName || "Notification",
                summary: notification.summary || "Notification",
                body: notification.body || "",
                icon: root.iconSource(notification)
            });
        }
    }
}
