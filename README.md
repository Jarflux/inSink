![](https://img.shields.io/github/release/qubyte/rubidium.svg?maxAge=100000)
![](https://img.shields.io/badge/build-stable-brightgreen.svg?maxAge=100000)
![](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=10000)

<p align="center">
  <img src="https://raw.githubusercontent.com/Jarflux/inSink/master/InSink/Assets.xcassets/AppIcon.appiconset/sink128.png?raw=true" alt="InSink Logo"/>
    <h1 align="center">InSink</h1>
</p>
## Description
InSink is a Mac OSX utility application that listens to changes on local files, to push the changes to a local running Adobe AEM instance. InSink will use jcr_root folder as root 

## Options
#### Extensions
Comma separeted list of file extensions that need to be pushed to AEM.<br />
````
html, css, js, json, xml, woff, tff, eot, svg, woff2
````

#### Directories
Comma separated list of directories that contain files.<br />
````
/Users/tony/stark/cor/html, /Users/scarlett/johannson/theme/css
````

#### Excluded Paths
Comma separated list of excluded path.<br />
````
/.idea/, /target/, pom.xml, /site-package/, /aem-static-components/
````


