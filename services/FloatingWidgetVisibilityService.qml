pragma Singleton

import Quickshell

Singleton {
    function activeWorkspace(outputName: string): var {
        if (!NiriService.available || !NiriService.windowsReady || !outputName)
            return null;

        return NiriService.workspaces.find(workspace =>
            workspace.output === outputName && workspace.is_active) || null;
    }

    function visibleOnOutput(outputName: string): bool {
        const workspace = activeWorkspace(outputName);
        if (!workspace)
            return false;

        return !NiriService.windows.some(window =>
            window.workspace_id === workspace.id);
    }
}
