<p align="center">
  <img src="https://raw.githubusercontent.com/Jarflux/inSink/master/InSink/Assets.xcassets/AppIcon.appiconset/sink128.png?raw=true" alt="InSink Logo"/>
    <h1 align="center">InSink</h1>
</p>

![](https://img.shields.io/github/release/qubyte/rubidium.svg?maxAge=100000)
![](https://img.shields.io/badge/build-stable-brightgreen.svg?maxAge=100000)
![](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=10000)
<br />
<br />
<a align="center" href="https://github.com/Jarflux/inSink/releases/download/v1.0/InSink.app.zip">Download InSink v1.0</a>

## Description
InSink is a Mac OSX utility application that listens to changes on local files, to push the changes to a local running Adobe AEM instance. Jcr_root folders in the directoreis are mapped to the root node of the AEM instance.

## Options
#### Extensions
Comma separeted list of file extensions that need to be pushed to AEM.<br />
````
f.e. html, css, js, json, xml, woff, tff, eot, svg, woff2
````

#### Directories
Comma separated list of directories that contain files.<br />
````
f.e. /Users/Documents/site/html, /Users/theme/css
````

#### Excluded Paths
Comma separated list of excluded path.<br />
````
f.e. /.idea/, /target/, pom.xml
````

## Example

<img src="http://i.imgur.com/C4qa4kG.png" alt="Screenshot local folder with theme.css and content">
<img src="http://i.imgur.com/bIBEUOE.png" alt="Screenshot InSink showing file is beeing pushed">
<img src="http://i.imgur.com/56Gy7Cf.png" alt="Screenshot AEM crx showing node containing theme.css content">

