<p align="center">
  <img src="https://raw.githubusercontent.com/Jarflux/inSink/master/InSink/Assets.xcassets/AppIcon.appiconset/sink128.png?raw=true" alt="InSink Logo"/>
    <h1 align="center">InSink</h1>
</p>

![](https://img.shields.io/badge/build-stable-brightgreen.svg?maxAge=100000)
<a href="http://choosealicense.com/licenses/mit/"><img src="https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=10000" alt="MIT License"/></a>
<br />
<br />
<a align="center" href="https://github.com/Jarflux/inSink/releases/download/v1.3/InSink.app.zip">Download InSink v1.3</a>

## Description
InSink is a Mac OSX utility application that listens to changes on local files, to push the changes to a local running Adobe AEM instance. Jcr_root folders in the directories are mapped to the root node of the AEM instance.

<img src="http://i.imgur.com/AXEqI0D.png" alt="Screenshot Main window">

## Configuration
#### Extensions
Comma separeted list of file extensions that need to be pushed to AEM.<br />
````
html, css, js, json, xml, woff, tff, eot, svg, woff2
````
#### Project Root
Root path that will be prefixed to every module location.<br />
````
/Users/TonyStark/project/root/
````
#### Modules
Comma separated list of modules that contain files.<br />
````
interface-module, html-folder, deeper/path
````
#### Excluded Paths
Comma separated list of excluded path.<br />
````
/.idea/, /target/, pom.xml
````
<img src="http://i.imgur.com/FZTTUCa.png" alt="Screenshot Configuration">

#### Export Configuration
Exporting the configuration will show a modal with all the config in a single string
<img src="http://i.imgur.com/fePES4t.png" alt="Screenshot Export Configuration modal">

#### Import Configuration
To import configuration paste the single config string into the field.
<img src="http://i.imgur.com/wBCl3kl.png" alt="Screenshot Import Configuration modal">

