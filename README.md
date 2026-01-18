> [!CAUTION]
> - This package depends on the fixed versions of Microsoft Edge WebView2.
> - Don't use this bucket or package, if you already have WebView2 installed.

# Microsoft Edge WebView2 for Scoop 

A bucket that provides a portable install of Microsoft Edge WebView2 for Scoop.

## Features

- A fully portable install of Microsoft Edge WebView2.

- Full control over how Microsoft Edge WebView2 is updated.

- Provides better update reliability for Microsoft Edge WebView2.

## Usage

> [!TIP]
> Use [Microsoft Edge Update policies](https://learn.microsoft.com/deployedge/microsoft-edge-update-policies) to suppress installs & updates.

- Add the bucket:

    ```cmd
    scoop bucket add webview2 https://github.com/Aetopia/scoop-webview2
    ```

- Install the package:

    ```cmd
    scoop install webview2
    ```

## Troubleshooting

### How to verify if an app is using the portable runtime?

> [!TIP]
> Make sure the WebView2 runtime isn't installed on your system.

- Launch any app that depends on WebView2.

- Open Task Manager & locate the app's processes.

- Locate any WebView2 process & verify it points to the portable runtime. 

### How do I force an installer to use the portable runtime?

> [!NOTE]
> - Installers will attempt to install WebView2, if it isn't installed.
> - This can be bypassed by spoofing certain [registry keys & values](https://learn.microsoft.com/microsoft-edge/webview2/concepts/distribution#detect-if-a-webview2-runtime-is-already-installed).

- The bucket provides scripts to tell installers that WebView2 is installed.

- You may run the correct script depending your system architecture:

    - Tell installers that WebView2 is installed: 
        
        - [`scripts/install`](scripts/install)

    - Tell installers that WebView2 is uninstalled: 

        - [`scripts/uninstall`](scripts/uninstall)

## Sources
- https://github.com/ProKn1fe/WebView2.Runtime

- https://learn.microsoft.com/deployedge/microsoft-edge-update-policies

- https://www.ntlite.com/community/index.php?threads/webview2-portable.5560

- https://learn.microsoft.com/microsoft-edge/webview2/concepts/distribution#detect-if-a-webview2-runtime-is-already-installed