import Quickshell
import QtQuick

ScriptModel {
    id: root

    objectProp: "key"

    property string query: ""
    property var commands: []
    property var tmuxSessions: []

    readonly property bool tmuxMode:
        query.startsWith("!")

    readonly property bool commandMode:
        query.startsWith(">")

    values: {
        if (root.commandMode) {
            const search =
                root.query
                    .slice(1)
                    .trim()
                    .toLowerCase();

            return root.commands.filter(command =>
                search.length === 0
                || command.name
                    .toLowerCase()
                    .includes(search)
            );
        }

        if (root.tmuxMode) {
            const search =
                root.query
                    .slice(1)
                    .trim()
                    .toLowerCase();

            const matches =
                search.length === 0
                    ? root.tmuxSessions
                    : root.tmuxSessions.filter(
                        sessionName =>
                            sessionName
                                .toLowerCase()
                                .includes(search)
                    );

            return matches.map(sessionName => ({
                key: "tmux:" + sessionName,
                type: "tmux",
                name: sessionName
            }));
        }

        const search =
            root.query
                .trim()
                .toLowerCase();

        const applications = [
            ...DesktopEntries.applications.values
        ];

        const matches =
            search.length === 0
                ? applications
                : applications.filter(application => {
                    const searchable = [
                        application.name,
                        application.genericName,
                        application.comment,
                        ...application.keywords
                    ]
                        .join(" ")
                        .toLowerCase();

                    return searchable.includes(search);
                });

        return matches
            .sort((first, second) => {
                const nameComparison =
                    first.name.localeCompare(second.name);

                return nameComparison !== 0
                    ? nameComparison
                    : first.id.localeCompare(second.id);
            })
            .map(application => ({
                key: "app:" + application.id,
                type: "application",
                application: application,
                name: application.name
            }));
    }
}
