import Quickshell.Services.Notifications
import QtQuick

QtObject {
    id: root
    
    property ListModel notificationModel: ListModel {}
    
    property NotificationServer server: NotificationServer {
        id: notifServer
        
        bodyMarkupSupported: true 
        actionsSupported: true

        onNotification: notification => {
            console.log("Got:", notification.summary, "ID:", notification.id);

            let iconSource = notification.image || notification.appIcon || "dialog-information";
            
            if (iconSource.indexOf("/") === -1 && iconSource.indexOf("image://") === -1) {
                iconSource = "image://theme/" + iconSource;
            } else if (iconSource.indexOf("/") === 0) {
                iconSource = "file://" + iconSource;
            }

            // Handle updates (replaces_id)
            let existingIndex = -1;
            if (notification.replacesId > 0) {
                for (let i = 0; i < root.notificationModel.count; ++i) {
                    if (root.notificationModel.get(i).id === notification.replacesId) {
                        existingIndex = i;
                        break;
                    }
                }
            }
            
            if (existingIndex === -1) {
                for (let i = 0; i < root.notificationModel.count; ++i) {
                    if (root.notificationModel.get(i).id === notification.id) {
                        existingIndex = i;
                        break;
                    }
                }
            }

            const data = {
                "id": notification.id,
                "summary": notification.summary,
                "body": notification.body,
                "icon": iconSource,
                "urgency": notification.urgency,
                "timestamp": Date.now()
            };

            if (existingIndex !== -1) {
                root.notificationModel.set(existingIndex, data);
            } else {
                root.notificationModel.insert(0, data);
            }
        }
    }
}
