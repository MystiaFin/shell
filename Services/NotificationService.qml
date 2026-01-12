import Quickshell.Services.Notifications
import QtQuick

Item {
    property ListModel notificationModel: ListModel {}
    
    signal removeNotification(int index)
    
    NotificationServer {
        onNotification: notification => {
            let iconSource = notification.image || notification.appIcon || "dialog-information";
            
            if (iconSource.indexOf("/") === -1) {
                iconSource = "image://theme/" + iconSource;
            } else if (iconSource.indexOf("/") === 0) {
                iconSource = "file://" + iconSource;
            }

            notificationModel.insert(0, {
                "id": notification.id,
                "summary": notification.summary,
                "body": notification.body,
                "icon": iconSource
            });
        }
    }
    
    function remove(index) {
        if (index >= 0 && index < notificationModel.count) {
            notificationModel.remove(index);
        }
    }
}
