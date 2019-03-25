    org $1000
*-------------------------------------------------------
* Author: Michal Krzyzanowski
* Login: C00240696 
* Date: 21/01/19
* Title: Avalon: The Mysterious Foe
* Description: text-based adventure game, goal is to explore the world and complete
* encouters such as battles and treasures
*-------------------------------------------------------

*-------------------------------------------------------
*Validation values to be used, modify as needed
*Add additional validation values as required-------
*------------------------------------------------

; constants
max_hp              EQU 10     max hp of player
thief_max_hp        EQU 10     max hp of thief enemy
murderer_max_hp     EQU 20     max hp of murderer


; events
treasure            EQU 2      location of treasure
thief_combat        EQU 4      location of thief encounter
peddlar             EQU 8      location of wandering peddlar(shop) event
thief_combat_two    EQU 12     location of second thief encounter




*Start of Game
start:

    ; setup player stats
    move.b  #max_hp, health  player's health, game over if 0
    
    move.b  #10, stamina  player's stamina, needed for exploring

    move.b  #0, steps  steps taken, used for player movement
    
    move.b  #0, gold  player's gold, used to buy water or upgrade weapon
    
    move.b  #4, damage  damage of player's weapon
    
    move.b  #0, honour  player's honour, gained after winning battles
    
    move.b  #0, water_flask  water flasks used to restore hp
    
    move.b  #0, murder_quest  boolean checking if murderer quest is active
    
    move.b  #0, boss_battle  boolean if player is fighting the murderer
    
    
    ; setup thief stats
    move.b  #thief_max_hp, thief_health
    move.b  #1, thief_dmg
    
    ; setup shrouded figure stats
    move.b  #murderer_max_hp, murderer_hp
    move.b  #4, murderer_dmg


    bsr welcome     branch to the welcome subroutine
    
*Game loop
    org     $3000      the rest of the program is to be located from 3000 onwards


*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------


welcome:
    bsr     endl            branch to endl subroutine
    lea     welcome_msg,A1  assign message to address register A1
    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    bsr     endl            branch to endl subroutine
    bsr     endl
    bsr     pause
    
    ; clear the screen and display the prologue text
    bsr     clear_screen    
    lea     prologue, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     pause
    bsr     gameplay
    

*-------------------------------------------------------
*---------Gameplay Input Values Subroutine--------------
*------------------------------------------------------- 

   
input:
    move.b  #4, D0
    trap    #15
    rts


*-------------------------------------------------------
*---Village gameplay start point------------------------
*------------------------------------------------------- 


gameplay:
    ; displays the village text with choices for the player
    bsr     clear_screen
    lea     village_enter_msg, A1
    move.b  #14,D0
    trap    #15
    bsr     pause
    bsr     clear_screen
    lea     village_msg, A1
    move.b  #14,D0
    trap    #15
    bsr     input
    
    cmp     #1, D1
    beq     explore_start
    bsr     clear_screen
    bne     gameplay


*-------------------------------------------------------
*---exploration-------------------------------------------
*-------------------------------------------------------


explore:
    ; displays explore text and presents the player with multiple options
    bsr     clear_screen
    lea     travel_msg, A1
    move.b  #14, D0
    trap    #15
    
    bsr     input
    
    ; restore stamina
    cmp     #2, D1
    beq     camp
    
    ; check player status
    cmp     #3, D1
    beq     status
    
    ; return to village, only if a certain condition is met
    cmp     #4, D1
    beq     return
    
    ; prevents player from exploring if out of stamina
    move.b  stamina, D2
    cmp     #0, D2
    beq     stamina_lack
    
    ; move
    cmp     #1, D1
    beq     movement
    
    bsr     clear_screen
    bne     explore


*-------------------------------------------------------
*---player status screen-----------------------------
*-------------------------------------------------------


status:
    ; status of player, can check inventory or stats
    bsr     clear_screen
    lea     status_msg, A1
    move.b  #14, D0
    trap    #15
    
    bsr     input
    
    cmp     #1, D1
    beq     inventory
    
    cmp     #2, D1
    beq     display_stats
    
    cmp     #3, D1
    beq     explore
    
    bne     status
    

*-------------------------------------------------------
*---no stamina to explore-----------------------------
*-------------------------------------------------------


stamina_lack:
    ; tells the player that he is out of stamina and cannot move
    bsr     clear_screen
    lea     stamina_lack_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    
    bsr     pause
    bsr     explore
    

*-------------------------------------------------------
*---setup camp, restore stamina fully-----------------------------
*-------------------------------------------------------


camp:
    ; restores stamina fully
    bsr     clear_screen
    lea     camp_msg, A1
    move.b  #14, D0
    trap    #15
    move.b  #10, stamina
    bsr     endl
    bsr     endl
    bsr     pause
    bsr     explore    


*-------------------------------------------------------
*---movement-----------------------------
*-------------------------------------------------------


movement:
    ; movement of the player, - 1 stamina, + 1 step(progress)
    bsr     clear_screen
    add.b   #1, steps
    sub.b   #1, stamina
    lea     move_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    
    bsr     pause
    bsr     clear_screen
    
    ; check for different events
    clr     D1
    move.b  steps, D1
    cmp     #treasure, D1
    beq     event_treasure
    
    cmp     #thief_combat, D1
    beq     thief_encounter
    
    cmp     #peddlar, D1
    beq     peddlar_encounter
    
    cmp     #thief_combat_two, D1
    beq     thief_encounter
    
    bne     explore
     
    
*-------------------------------------------------------
*---return to village state------------------------
*------------------------------------------------------- 


return:
    ; return back to the village, steps are reset
    bsr     clear_screen
    clr     D1
    move.b  murder_quest, D1
    cmp     #0, D1
    beq     cannot_return
    
    lea     return_msg, A1
    move.b  #14, D0
    trap    #15
    move.b  #0, steps
    bsr     endl
    bsr     endl
    bsr     input
    
    ; return to exploration
    cmp     #1, D1
    beq     explore_start
    
    ; final boss
    cmp     #2, D1
    beq     search
    
    bne     return
    
    
*-------------------------------------------------------
*---cannot return to village------------------------
*-------------------------------------------------------


cannot_return:
    ; cannot return due to a certain condition being not met
    bsr     clear_screen
    lea     cannot_return_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     pause
    bsr     explore


*-------------------------------------------------------
*---searching for the murderer--------------------------
*-------------------------------------------------------


search:
    ; final boss engage text
    bsr     clear_screen
    lea     search_msg, A1
    move.b  #14, D0
    trap    #15
    move.b  #1, boss_battle
    bsr     endl
    bsr     endl
    bsr     pause
    bsr     final_battle


*-------------------------------------------------------
*---Treasure Event------------------------
*-------------------------------------------------------


event_treasure:
    ; treasure event encountered, gold find
    bsr     clear_screen
    lea     treasure_msg, A1
    move.b  #14, D0
    trap    #15
    add.b   #10, gold
    bsr     endl
    bsr     endl
    bsr     pause
    bsr     clear_screen
    bsr     explore


*-------------------------------------------------------
*---Thief Encounter Event-----------------
*-------------------------------------------------------


thief_encounter:
    ; battle against weak enemy
    bsr     clear_screen
    lea     thief_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     pause
    bsr     clear_screen
    bsr     combat


*-------------------------------------------------------
*---peddlar(shop) Encounter Event-----------------
*-------------------------------------------------------


peddlar_encounter:
    ; player meets a peddlar, can use shop or progress in the murderer quest
    bsr     clear_screen
    lea     peddlar_enct_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     input
    
    
    cmp     #1, D1
    beq     shop
    
    cmp     #2, D1
    beq     murderer_quest
    
    cmp     #3, D1
    beq     explore

    bne     peddlar_encounter
    
    
    
*-------------------------------------------------------
*---shop, buy water or upgrade weapon-----------------------------
*-------------------------------------------------------

    
shop:
    ; buy water flasks, upgrade weapon
    bsr     clear_screen
    lea     shop_msg, A1
    move.b  #14, D0
    trap    #15
    
    lea     gold_msg, A1
    move.b  #14, D0
    trap    #15
    
    clr     D1
    move.b  gold, D1
    move.b  #3, D0
    trap    #15
    
    clr     D1
    move.b  #103, D1
    move.b  #6, D0
    trap    #15
    bsr     endl
    bsr     endl
    
    bsr     input
    
    cmp     #1, D1
    beq     buy_water
    
    cmp     #2, D1
    beq     upgrade_weapon
    
    cmp     #3, D1
    beq     peddlar_encounter
    
    bne     shop
    


*-------------------------------------------------------
*---Buy water flasks------------------------------------
*-------------------------------------------------------


buy_water:
    ; checks if you have enough gold to buy water flask
    bsr     clear_screen 
    clr     D1
    move.b  gold, D1
    cmp     #10, D1
    blt     no_gold
    
    
    sub.b   #10, gold
    add.b   #1, water_flask
    lea     water_gained_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     pause
    
    bsr     shop


*-------------------------------------------------------
*---Not Enough Gold-------------------------------------
*-------------------------------------------------------


no_gold:
    ; not enough gold to buy
    bsr     clear_screen
    lea     no_gold_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     pause
    
    bsr     shop


*-------------------------------------------------------
*---Upgrade weapon damage-------------------------------
*-------------------------------------------------------


upgrade_weapon:
    ; upgrade weapon damage by 2 if player has enough gold
    bsr     clear_screen
    clr     D1
    move.b  gold, D1
    cmp     #20, D1
    blt     no_gold
    
    sub.b   #20, gold
    add.b   #2, damage
    lea     upgrade_gained_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     pause
    
    bsr     shop

  
*-------------------------------------------------------
*--Murderer Quest Info----------------------------------
*-------------------------------------------------------
  
murderer_quest:
    ; gain info on murderer quest, appears only once
    bsr     clear_screen
    
    clr     D1
    move.b  murder_quest, D1
    cmp     #1, D1
    beq     quest_active
    
    add.b   #1, murder_quest
    lea     rumour_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     pause
    bsr     peddlar_encounter
    
    
*-------------------------------------------------------
*--Murderer Quest Already Active------------------------
*-------------------------------------------------------


quest_active:
    ; if asking the peddlar for rumours a second time
    lea     quest_active_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     pause
    bsr     peddlar_encounter


*-------------------------------------------------------
*---Combat (thief)--------------------------------------
*-------------------------------------------------------


combat:
    ; display player's health in combat
    bsr         clear_screen
    lea         combat_hp_msg, A1
    move.b      #14, D0
    trap        #15

    clr         D1
    move.b      health, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl
    
    ; display thief's health in combat
    lea         thief_hp_msg, A1
    move.b      #14, D0
    trap        #15

    clr         D1
    move.b      thief_health, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl
    
    ; display combat actions
    lea         combat_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      water_flask, D1
    move.b      #3, D0
    trap        #15
    
    clr         D1
    move.b      #41, D1
    move.b      #6, D0
    trap        #15
    
    bsr         endl
    bsr         endl
    bsr         input
    
    cmp         #1, D1
    beq         attack
    
    cmp         #2, D1
    beq         flee
    
    cmp         #3, D1
    beq         heal
    bne         combat


*-------------------------------------------------------
*---Attack (Combat)-------------------------------------
*-------------------------------------------------------


attack:
    ; player deals damage but also takes damage
    bsr         clear_screen
    lea         attack_msg, A1
    move.b      #14, D0
    trap        #15
    
    ; display the damage dealt to the enemy
    clr         D1
    move.b      damage, D1
    move.b      #3, D0
    trap        #15
    
    lea         dmg_msg, A1
    move.b      #14, D0
    trap        #15
    sub.b       D1, thief_health
    bsr         endl
    bsr         endl
    bsr         pause
    
    ; display the damage the enemy has dealt to the player
    bsr         clear_screen
    lea         enemy_attack_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      thief_dmg, D1
    move.b      #3, D0
    trap        #15
    
    lea         dmg_msg, A1
    move.b      #14, D0
    trap        #15
    sub.b       D1, health
    
    bsr         endl
    bsr         endl
    bsr         pause
    
    ; check if enemy or player has been defeated
    clr         D1
    move.b      health, D1
    cmp         #0, D1
    beq         failure
    
    cmp         #max_hp, D1
    bgt         failure

    clr         D1
    move.b      thief_health, D1
    cmp         #0, D1
    beq         victory
    
    cmp         #thief_max_hp, D1
    bgt         victory
    
    bne         combat
     

*-------------------------------------------------------
*---Victory (Combat)-------------------------------------
*-------------------------------------------------------


victory:
    ; gain rewards upon beating your enemy
    bsr         clear_screen
    lea         victory_msg, A1
    move.b      #14, D0
    trap        #15
    add.b       #12, gold
    add.b       #1, water_flask
    add.b       #1, honour
    
    ; reset enemy health
    move.b      #thief_max_hp, thief_health
    
    bsr         endl
    bsr         endl
    bsr         pause
    bsr         explore
   
   
*-------------------------------------------------------
*---Victory (final)-------------------------------------
*-------------------------------------------------------


game_won:
    ; final boss defeated
    bsr         clear_screen
    lea         game_won_msg, A1
    move.b      #14, D0
    trap        #15 
    add.b       #5, honour
    bsr         endl
    bsr         endl
    bsr         pause
    bsr         end_game
    
    
*-------------------------------------------------------
*---GameOver--------------------------------------------
*-------------------------------------------------------


failure:
    ; player hp dropped down to 0
    bsr         clear_screen
    lea         failure_msg, A1
    move.b      #14, D0
    trap        #15
    
    bsr         endl
    bsr         endl
    bsr         pause
    bsr         end_game
    
    
*-------------------------------------------------------
*---Flee (Combat)-------------------------------------
*-------------------------------------------------------


flee:
    ; escape from combat, lose honour, cannot flee from final boss
    bsr         clear_screen
    lea         flee_msg, A1
    move.b      #14, D0
    trap        #15
    
    bsr         endl
    bsr         endl
    bsr         pause
    
    clr         D1
    move.b      honour, D1
    cmp         #0, D1
    beq         explore
    
    sub.b       #1, honour
    
    bsr         explore


*-------------------------------------------------------
*---Heal (Combat)-------------------------------------
*-------------------------------------------------------


heal:
    ; restore helath fully, use up 1 water flask
    bsr         clear_screen
    
    clr         D1
    move.b      water_flask, D1
    cmp         #0, D1
    beq         no_water
    
    clr         D1
    move.b      health, D1
    cmp         #max_hp, D1
    beq         full_health
    
    sub.b       #1, water_flask
    move.b      #max_hp, health
    lea         heal_msg, A1
    move.b      #14, D0
    trap        #15
    bsr         endl
    bsr         endl
    bsr         pause
    
    clr         D1
    move.b      boss_battle, D1
    cmp         #1, D1
    beq         final_battle
    
    bne         combat


*-------------------------------------------------------
*---Full Health (Combat)--------------------------------
*-------------------------------------------------------


full_health:
    ; triggered when hp is full, prevents water flask wastage
    bsr         clear_screen
    lea         full_health_msg, A1
    move.b      #14, D0
    trap        #15
    bsr         endl
    bsr         endl
    bsr         pause
    
    clr         D1
    move.b      boss_battle, D1
    cmp         #1, D1
    beq         final_battle
    
    bne         combat
    
    
*-------------------------------------------------------
*---No water Flasks (Combat)----------------------------
*-------------------------------------------------------


no_water:
    ; prevents player from healing if no water flasks in inventory
    bsr         clear_screen
    lea         no_water_msg, A1
    move.b      #14, D0
    trap        #15
    bsr         endl
    bsr         endl
    bsr         pause
    
    clr         D1
    move.b      boss_battle, D1
    cmp         #1, D1
    beq         final_battle
    
    bne         combat
    
    
    
*-------------------------------------------------------
*---Combat (Final)--------------------------------------
*-------------------------------------------------------


final_battle:
    ; display player's health in combat
    bsr         clear_screen
    lea         combat_hp_msg, A1
    move.b      #14, D0
    trap        #15

    clr         D1
    move.b      health, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl
    
    ; display shrouded figure's health in combat
    lea         murderer_hp_msg, A1
    move.b      #14, D0
    trap        #15

    clr         D1
    move.b      murderer_hp, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl
    
    ; display combat actions
    lea         final_battle_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      water_flask, D1
    move.b      #3, D0
    trap        #15
    
    clr         D1
    move.b      #41, D1
    move.b      #6, D0
    trap        #15
    
    bsr         endl
    bsr         endl
    bsr         input
    
    cmp         #1, D1
    beq         boss_attack
    
    cmp         #2, D1
    beq         heal
    bne         final_battle
    
    
*-------------------------------------------------------
*---Attack (final)-------------------------------------
*-------------------------------------------------------


boss_attack:
    ; same as normal combat but, no flee option, winning leads to game win screen
    bsr         clear_screen
    lea         attack_msg, A1
    move.b      #14, D0
    trap        #15
    
    ; display the damage dealt to the enemy
    clr         D1
    move.b      damage, D1
    move.b      #3, D0
    trap        #15
    
    lea         dmg_msg, A1
    move.b      #14, D0
    trap        #15
    sub.b       D1, murderer_hp
    bsr         endl
    bsr         endl
    bsr         pause
    
    ; display the damage the enemy has dealt to the player
    bsr         clear_screen
    lea         enemy_attack_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      murderer_dmg, D1
    move.b      #3, D0
    trap        #15
    
    lea         dmg_msg, A1
    move.b      #14, D0
    trap        #15
    sub.b       D1, health
    
    bsr         endl
    bsr         endl
    bsr         pause
    
    ; check if enemy or player has been defeated
    clr         D1
    move.b      health, D1
    cmp         #0, D1
    beq         failure
    
    cmp         #max_hp, D1
    bgt         failure

    clr         D1
    move.b      murderer_hp, D1
    cmp         #0, D1
    beq         game_won
    
    cmp         #murderer_max_hp, D1
    bgt         game_won
    
    bne         final_battle
    
    
*-------------------------------------------------------
*---Game Play (Exploration)-----------------------------
*-------------------------------------------------------


display_stats:
    ; display health message and player's current health
    bsr         clear_screen
    lea         health_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      health, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl

    ; display stamina message and player's current stamina
    lea         stamina_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      stamina, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl
    
    ; display steps message and steps taken by player
    lea         steps_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      steps, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl
    
    ; display gold message and player's current gold value
    lea         gold_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      gold, D1
    move.b      #3, D0
    trap        #15
    
    clr         D1
    move.b      #103, D1
    move.b      #6, D0
    trap        #15
    bsr         endl
    bsr         endl
    
    ; display honour message and current honour the player has
    lea         honour_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      honour, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl
    
    bsr         pause
    bsr         clear_screen
    bsr         status
    

*-------------------------------------------------------
*---Game Play (Exploration)-----------------------------
*-------------------------------------------------------

inventory:
    ; display water flasks message and current water flasks the player has
    bsr         clear_screen
    lea         water_flask_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      water_flask, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl
        
    ; display weapon message and the damage of the player's damage
    lea         weapon_msg, A1
    move.b      #14, D0
    trap        #15
    
    clr         D1
    move.b      damage, D1
    move.b      #3, D0
    trap        #15
    bsr         endl
    bsr         endl
    
    bsr         pause
    bsr         clear_screen
    bsr         status
    
    
*-------------------------------------------------------
*------------------Start Exploring--------------------
*-------------------------------------------------------


    explore_start:
    ; message informing player that exploration has begun
    bsr     clear_screen
    lea     explore_start_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     pause
    bsr     clear_screen
    bsr     explore
    
    
*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------


clear_screen: 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts
    
; pause the game, await any input, prefferably enter for fast gameplay
pause:
    lea     pause_msg, A1
    move.b  #14, D0
    trap    #15
    
    move.b  #4, D0
    trap    #15
    rts

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
    
*-------------------------------------------------------
*------------------------End-Game-----------------------
*-------------------------------------------------------


end_game:
    ; after losing or winning, display final honour the player has gained over the course of the game
    bsr         clear_screen
    lea         end_game_msg, A1
    move.b      #14, D0
    trap        #15
    clr         D1
    move.b      honour, D1
    move.b      #3, D0
    trap        #15
    
    bsr         endl
    bsr         endl
    bsr         pause
    
    simhalt


*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------



crlf:                 dc.b    $0D,$0A,0
welcome_msg:          dc.b    '************************************************************'
                      dc.b    $0D,$0A
                      dc.b    'Avalon: The Mysterious Foe'
                      dc.b    $0D,$0A
                      dc.b    '************************************************************'
                      dc.b    $0D,$0A,0
prologue:			  dc.b	'You are a simple adventurer with only a copper shortsword at your'
				      dc.b	$0D, $0A
				      dc.b	'disposal.'
				      dc.b	$0D, $0A
				      dc.b	'you have lived quietly at a tiny village but, things have'
				      dc.b	$0D, $0A
				      dc.b	'turned for the worse recently.'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'every night, people have started dissappearing.'
				      dc.b	$0D, $0A
				      dc.b	'you decided to investigate the cause of the disappearances.'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'you start making your way to the village square.',0
village_enter_msg:	  dc.b	'*-----------*'
			          dc.b    $0D,$0A
			          dc.b	'|  Village  |'
			          dc.b    $0D,$0A
			          dc.b	'*-----------*'
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A,0
village_msg:          dc.b    'you enter the village square.'
                      dc.b    $0D,$0A
                      dc.b    'What do you do?'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '1. Explore the lands'
                      dc.b    $0D,$0A,0
return_msg:           dc.b    'you return to the village square.'
                      dc.b    $0D,$0A
                      dc.b    'What do you do?'
                      dc.b    $0D,$0A
				      dc.b    $0D,$0A
				      dc.b    $0D,$0A
                      dc.b    '1. explore the lands'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '2. Search for the murderer'
                      dc.b    $0D,$0A,0
explore_start_msg:    dc.b    'You leave the village to explore the lands!',0
travel_msg:           dc.b	  '*---------*'
				      dc.b	  $0D, $0A
				      dc.b	  '| Explore |'
				      dc.b	  $0D, $0A
				      dc.b	  '*---------*'
				      dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
                      dc.b    '1. Travel(1 step, -1 stamina)'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '2. Setup camp(restore stamina)'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '3. View player status'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '4. Return to the village.'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A,0
status_msg:           dc.b	  '*--------*'
				      dc.b	  $0D, $0A
				      dc.b	  '| Status |'
				      dc.b	  $0D, $0A
				      dc.b	  '*--------*'
				      dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
                      dc.b    '1. display inventory'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '2. view player stats'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '3. Return to explore'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A,0
move_msg:             dc.b    'you walk for 1 minute!'
                      dc.b    $0D,$0A
                      dc.b    '<== stamina decreased by 1! ==>',0
pause_msg:            dc.b    'Press Enter to continue...',0
health_msg:           dc.b    'Health: ',0
stamina_msg:          dc.b    'Stamina: ',0
steps_msg:            dc.b    'Steps Taken: ',0
honour_msg:           dc.b    'Honour: ',0
water_flask_msg:      dc.b    'Water Flasks: ',0
weapon_msg:           dc.b    'Weapon Damage: ',0
treasure_msg:         dc.b    'After walking for a while, you stumble upon a small satchet.'
                      dc.b    $0D,$0A
                      dc.b    'You search the satchet.'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '<== you found 10g ==>',0
gold_msg:             dc.b    'Gold: ',0
stamina_lack_msg:     dc.b    'You are too tired to travel. rest up by setting up a camp!',0
camp_msg:             dc.b    'You setup a campfire and go to sleep.'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '<== Stamina fully restored! ==>',0
thief_msg:            dc.b    'While exploring the wilderness, you are attacked by a thief!'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '<== Combat initiated! ==>',0
combat_msg:  	      dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
                      dc.b    '1. Attack'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b   '2. Flee'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '3. Heal (Water Flasks: ',0
final_battle_msg:  	  dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
                      dc.b    '1. Attack'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '2. Heal (Water Flasks: ',0
combat_hp_msg:        dc.b   'Player: ',0
thief_hp_msg:         dc.b   'Thief: ',0
murderer_hp_msg:      dc.b   'Shrouded Figure: ',0
attack_msg:           dc.b    'You attack your opponent!'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '<== Dealt ',0
enemy_attack_msg:     dc.b    'Your opponent strikes back!'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '<== Dealt ',0
dmg_msg:              dc.b    ' dmg! ==>',0
flee_msg:             dc.b    'You flee the scene!'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '<== you lost 1 Honour ==>',0
victory_msg:          dc.b    '<== Victory Achieved! ==>'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '<== Obtained 1 Honour ==>'
                      dc.b    $0D,$0A
                      dc.b    '<== Obtained 12g ==>'
                      dc.b    $0D,$0A
                      dc.b    '<== Obtained water flask x1 ==>'
                      dc.b    $0D,$0A,0
failure_msg:          dc.b    '<== You Died! ==>',0
peddlar_enct_msg:     dc.b	'As you explore the land, you come across a wandering peddlar.'
					  dc.b	$0D, $0A
					  dc.b	$0D, $0A
					  dc.b	'The peddlar approaches you.'
					  dc.b	$0D, $0A
					  dc.b	$0D, $0A
					  dc.b	'Peddlar: Greetings! May I intrest you in my wares?'
					  dc.b	$0D, $0A
					  dc.b	$0D, $0A
					  dc.b	$0D, $0A
					  dc.b	'1. Browse Wares'
					  dc.b	$0D, $0A
					  dc.b	$0D, $0A
					  dc.b	'2. Rumours'
					  dc.b	$0D, $0A
					  dc.b	$0D, $0A
					  dc.b	'3. Leave',0
shop_msg:			  dc.b	'*------*'
				      dc.b	$0D, $0A
				      dc.b	'| Shop |'
				      dc.b	$0D, $0A
				      dc.b	'*------*'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'1. Water Flask                          10g'
				      dc.b	$0D, $0A
				      dc.b	'2. Weapon Enchancement <+2dmg>		20g'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b  '3. Return'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A,0
rumour_msg:			  dc.b	'You ask the peddlar for rumours.'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'Peddlar: Rumours? Well it is said that there is a murderer on the loose.'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'Peddlar: Apparently, he was last seen in the village.'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'Peddlar: The Bounty for getting rid of this guy is preeety high.'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'<== Started "Eliminate the Murderer" Quest ==>',0
no_gold_msg:	      dc.b	'Not enough gold!',0
water_gained_msg:	  dc.b	'<== You Bought a Water Flask! ==>',0
upgrade_gained_msg:	  dc.b	'<== You Upgraded your weapon by 2dmg! ==>',0
quest_active_msg:	  dc.b	'You ask the peddlar for more rumours.'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'Peddlar: Rumours? nothing new I''m afraid...',0
cannot_return_msg:	  dc.b	'You should find some information regarding the dissappearances first!',0
search_msg:			  dc.b	'You begin searching for the murderer.'
				      dc.b    $0D,$0A
				      dc.b    $0D,$0A
				      dc.b	'after Countless hours, you find a secret passage leading to a dark room'
				      dc.b    $0D,$0A
				      dc.b    $0D,$0A
				      dc.b	'In the room, a shrouded figure attacks you!'
				      dc.b    $0D,$0A
				      dc.b    $0D,$0A
				      dc.b    $0D,$0A
				      dc.b	'<== Combat Initiated! ==>',0
heal_msg:			  dc.b	'<== Health fully Restored! ==>',0
full_health_msg:	  dc.b	'Health is full!',0	
no_water_msg:		  dc.b	'No water flasks in inventory!',0
game_won_msg:		  dc.b	'*---------------------*'
			          dc.b    $0D,$0A
			          dc.b	'|  Congratulations!!  |'
			          dc.b    $0D,$0A
			          dc.b	'*---------------------*'
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A
			          dc.b	'You have slain the murderer and retained peace in the village!'
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A
			          dc.b  '<== Gained 5 Honour! ==>'
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A
			          dc.b	'Although, you recognised the attire of the murderer.'
			          dc.b    $0D,$0A
			          dc.b	'It is part of an infamous cult, the fellowship of the moon.'
			          dc.b    $0D,$0A
			          dc.b	'You have decided to venture out into the world and find more clues'
			          dc.b    $0D,$0A
			          dc.b	'about this cult.',0
end_game_msg:		  dc.b	'*-----------*'
			          dc.b    $0D,$0A
			          dc.b	'|  Results  |'
			          dc.b    $0D,$0A
			          dc.b	'*-----------*'
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A
			          dc.b    $0D,$0A
			          dc.b	'Honour: ',0		

; booleans
murder_quest:   ds.b    1
boss_battle:    ds.b    1

; player stats
health:         ds.b    1
stamina:        ds.b    1
steps:          ds.b    1
gold:           ds.b    1
damage:         ds.b    1
water_flask:    ds.b    1
honour:         ds.b    1


; enemy stats

; thief
thief_health:   ds.b    1
thief_dmg:      ds.b    1

; shrouded figure
murderer_hp:    ds.b    1
murderer_dmg:   ds.b    1 

    end start


























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
