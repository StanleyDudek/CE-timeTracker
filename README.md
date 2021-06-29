## 🛑 OUTDATED UNTIL FURTHER NOTICE 🛑 USE AT OWN DISCRETION 🛑

# CE-timeTracker
## A CobaltEssentials extension to provide tracking of cumulative player connection time across sessions on BeamMP Servers

![image](https://user-images.githubusercontent.com/49531350/114254945-73a52b00-9980-11eb-97c4-0671c3b5c25d.png)


### Installation:

#### 1. Place timeTracker.lua in
`.../Resources/Server/CobaltEssentials/extensions/`

#### 2. Add an entry to turn it on in:
`.../Resources/Server/CobaltEssentials/LoadExtensions.cfg`

```cfg
# Add your new extensions here as a key/value pair
# The first one is the name in the lua enviroment
# The second value is the file path to the main lua from CobaltEssentials/extensions

exampleExtension = "exampleExtension"
timeTracker = "timeTracker"
```
---
### Configuration:
N/A

---
### Usage:

This extension will keep track of the total time in seconds a player is connected to a server and store it in `.../CobaltDB/playersDB/<playername>.json`

It will look like this example :
```json
{
"stats":{	
	"totalTime":2075.858
}
}
```

This extension's only command currently is `/totaltime <playername>`

This will show you the total time stored for that player.

A player's totalTime is updated on vehicle resets and when the player leaves the server.
