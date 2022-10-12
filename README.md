# Attack on Hero 2 Rebalanced# AOH2R

## What Is This? 
Dota 2 custom map and game mode. The core concept of the game was the same as the priors, but I focused more on UX and allowing for many diferent paths to the correct answer.  
The code is spaghetti. I was a terrible developer back then. I apologize :(

Boss abilities are implemented using datadriven templates to either orchestrate the casting of an original ability, or to call on a custom lua ability script. All boss abilities should ideally be datadriven calling some other script.  
Boss ability scheduling is handled by a (terrible) ticketing system where abilities will submit a ticket to a ticket concession and spin until their number comes up. Please replace with a sane solution if possible, or I'll go insane.  
  
Note that boss behavior is, at a core level, just the normal dota 2 creep behavior. Everything is build up around that foundation, and the methods used to implement abilities/behaviors were made to streamline developing for that specifically. 
  

## Setup
1. Plop the contents into your Steam\steamapps\common\dota 2 beta folder, wherever that is.
2. Install dota 2 tools.
3. Figure out how to get this thing to launch. It involved going into content\dota_addons\attackcopy\maps and opening attackonhero.vmap with the tools hammer editor to build and playtest.)
4. Experience the sheer absurdity of how badly I coded back in the day.

## Where Some Things Are
I'm including this section because I never got around to fixing where certain code exists in the project, it was definitely on my to-do list though. 
1. Reusable boss ability wrappers (The thing that adds delays, scheduling, telegraphy) -> generics.lua
   1. If you see a circle on the ground or above the head, this is what creates that.
2. Hero attribute modification + dash modifiers -> hero_attribute_fix.lua
   1. Dashing is a whole deal of things communicating. Frontend hud.js for clientside handling (alleviates backend strain), dashmanager.lua for serverside handling, hero_attribute_fix.lua for dash stats and upgrades, and aohgamemode.lua for big-ass ugly setup code. 
3. Global damage effects like Talon items and Arcane Staff -> global_damage_effects.lua. It was implemented this way for performance reasons, but try not to add too much to it. 
   1. Any instance of OnTakeDamage should probably be handled here. On any instance of any event, every modifier listening to that event will fire regardless of the source/target. OnTakeDamage is the most common one and tends to create feedback loops, so try to work around that.
4. Boss ticketing behavior -> modifier_boss.lua and generics.lua. Truly awful ticketing system, should be replaced with a subscriber/reporter pattern.
5. Boss backend health bar + revenge handler -> modifier_main_boss.lua. Should be split into two files, but oh well.


## In My Defense
1. I was in the process of fixing the backend code and streamlining the code for boss abilities, but I got burnt out :(
2. I worked on Notepad++ and never bothered installing an IDE with a formatter. Not really a defense but it's the best I've got.

## Notes
content/dota_addons/attackcopy/panorama/scriptsUnobfuscated contains the unobfuscated version of the panorama scripts folder. The reason I didn't just replace the old files is because there's a chance that an update was pushed after this backup was made, and my for-sure backup was accidentally deleted by an rmdir command.


## Attack On Hero Genealogy
For posterity here's the family tree of this style of game.

0. **Probably the Warcraft 3 mod Impossible Bosses, but there's likely a whole dimension of ancestors here.** 
1. **Attack On Hero**
     1. The OG.
2. **Attack On Hero Rebalanced**
     1. Took code from Attack On Hero and increased the quality of the content.  
3. **Attack On Hero 2**
     1. Same as above
     2. I think this guy used some voodoo magic to grab the frontend code.   
4. **Attack On Hero 2 Rebalanced** (That's me :D) 
     1. Code "appropriated" and frontend rebuilt to get around obfuscation.
     2. The original project name is even to this day "attackcopy".
5. **Hero Attack On Gods, etc**
     1. Built on my public source code, competition was actually the reason for my obfuscating the frontend.  
