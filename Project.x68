    org $1000
*-------------------------------------------------------
* Author: Michal Krzyzanowski
* Login: C00240696 
* Date: 21/01/19
* Title: --
* Description: --
*-------------------------------------------------------
*Choose to be a Worker or a God 
*https://www.avalon-rpg.com/
*-------------------------------------------------------

*-------------------------------------------------------
*Validation values to be used, modify as needed
*Add additional validation values as required-------
*------------------------------------------------


exit                EQU 0      used to exit assembly program
min_feed            EQU 100    min feed requirement
min_potions         EQU 1      min number of potions
max_potions         EQU 9      max number of potions
min_weapons         EQU 6      min weapons
win_point           EQU 5      points accumilated on win
lose_point          EQU 8      points deducted on a loss
max_hp              EQU 10     max hp of player
thief_max_hp        EQU 10     max hp of thief enemy


; events
treasure            EQU 2      location of treasure
thief_combat        EQU 4      location of thief encounter
peddlar             EQU 8      location of wandering peddlar(shop) event


; weapons(maybe)



*Start of Game
start:

    ; setup player stats
    move.b  #max_hp, health put health in memory location
    
    move.b  #10, stamina put player stamina in memory location

    move.b  #7, steps  steps taken value stored in memory location
    
    move.b  #0, gold   player gold is stored in memory location
    
    move.b  #5, damage player gold is stored in memory location
    
    move.b  #0, honour
    
    move.b  #0, water_flask water flasks used to restore hp
    
    
    ; setup thief stats
    move.b  #thief_max_hp, thief_health
    move.b  #1, thief_dmg


    ; bsr     welcome    branch to the welcome subroutine
    ; bsr     input      branch to the input subroutine
    ; bsr     game       branch to the game subroutine
    bsr explore
    
*Game loop
    org     $3000      the rest of the program is to be located from 3000 onwards


*-------------------------------------------------------
*-------------------Game Subroutine---------------------
*-------------------------------------------------------


game:
    bsr     gameloop   branch to gameloop subroutine
    rts                return from game: subroutine
          
end:
    simhalt


*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------


welcome:
    bsr     endl            branch to endl subroutine
    lea     welcome_msg,A1  assign message to address register A1
    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    bsr     endl            branch to endl subroutine
    rts                     return from welcome: subroutine
    


*-------------------------------------------------------
*---------Gameplay Input Values Subroutine--------------
*------------------------------------------------------- 

   
input:
    move.b  #4, D0
    trap    #15
    rts
   
    
*-------------------------------------------------------
*----------------Gameloop (main loop)-------------------
*------------------------------------------------------- 


gameloop:
    bsr     update          branch to update game subroutine 
    bsr     clear_screen    clears the screen         
    bsr     draw            branch to draw screen subroutine
    bsr     clear_screen    clears the screen
    bsr     gameplay        branch to gameplay subroutine
    bsr     clear_screen    clears the screen
    bsr     hud             branch to display HUD subroutine
    bsr     clear_screen    clears the screen
    bsr     replay          branch to replay game subroutine
    bsr     clear_screen    clears the screen
    rts                     return from gameloop: subroutine


*-------------------------------------------------------
*----------------Update Quest Progress------------------
*  Complete Quest
*------------------------------------------------------- 


update:
    bsr     endl            print a CR and LF
    bsr     decorate        decorate with dots using a loop
    lea     update_msg,A1   
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
    
    
*-------------------------------------------------------
*-----------------Draw Quest Updates--------------------
* Draw the game progress information, status regarding
* quest
*------------------------------------------------------- 


draw:
    bsr     endl
    bsr     decorate
    lea     draw_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
    
    
*-------------------------------------------------------
*------------------------Potions------------------------
* Input the ingredients for each potion. Ingredients costs 
* money. For an advanced mark you need to manage this 
* resource
*------------------------------------------------------- 


feed:
    bsr     endl
    bsr     decorate
    lea     potion_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts


*-------------------------------------------------------
*--------------------Potions Inventory---------------------
* Number of potions to be used in a Quest 
*-------------------------------------------------------

 
potions:
    bsr     endl
    bsr     decorate
    lea     potions_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts


*-------------------------------------------------------
*-------------------------Weapons-----------------------
* Number of weapons
*------------------------------------------------------- 

  
weapons:
    bsr     endl
    bsr     decorate
    lea     weapons_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts


*-------------------------------------------------------
*---Game Play (Quest Progress)--------------------------
*------------------------------------------------------- 


gameplay:
    bsr     endl
    bsr     decorate
    lea     gameplay_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    bsr     pause
    lea     chapterOne,A1
    move.b  #14,D0
    trap    #15
    bsr     input
    
    cmp     #1, D1
    beq     explore_start
    bsr     clear_screen
    bne     gameplay
    
    rts


*-------------------------------------------------------
*---Game Play (Exploration)-----------------------------
*-------------------------------------------------------


explore:
    bsr     clear_screen
    lea     travel_msg, A1
    move.b  #14, D0
    trap    #15
    
    bsr     input
    
    cmp     #2, D1
    beq     camp
    
    cmp     #3, D1
    beq     status
    
    move.b  stamina, D2
    cmp     #0, D2
    beq     stamina_lack
    
    cmp     #1, D1
    beq     movement
    
    bsr     clear_screen
    bne     explore


*-------------------------------------------------------
*---Game Play (Exploration)-----------------------------
*-------------------------------------------------------


status:
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
*---Game Play (Exploration)-----------------------------
*-------------------------------------------------------


stamina_lack:
    bsr     clear_screen
    lea     stamina_lack_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    
    bsr     pause
    bsr     explore
    

*-------------------------------------------------------
*---Game Play (Exploration)-----------------------------
*-------------------------------------------------------


camp:
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
*---Game Play (Exploration)-----------------------------
*-------------------------------------------------------


movement:
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
    
    clr     D1
    move.b  steps, D1
    cmp     #treasure, D1
    
    beq     event_treasure
    
    cmp     #thief_combat, D1
    
    beq     thief_encounter
    
    cmp     #peddlar, D1
    
    beq     peddlar_encounter
    
    bne     explore
    
    
*-------------------------------------------------------
*---Treasure Event (Exploration)------------------------
*-------------------------------------------------------


event_treasure:
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
*---Thief Encounter Event (Exploration)-----------------
*-------------------------------------------------------


thief_encounter:
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
*---Thief Encounter Event (Exploration)-----------------
*-------------------------------------------------------


peddlar_encounter:
    bsr     clear_screen
    lea     peddlar_enct_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     endl
    bsr     input
    
    cmp     1, D1
    beq     shop
    
    cmp     2, D1
    beq     murderer_quest
    
    cmp     3, D1
    beq     explore

    bne     peddlar_encounter
    
    
    
*-------------------------------------------------------
*---Combat (Exploration)-----------------------------
*-------------------------------------------------------

    
shop:
    


*-------------------------------------------------------
*---Combat (Exploration)-----------------------------
*-------------------------------------------------------

    
murderer_quest:
    

*-------------------------------------------------------
*---Combat (Exploration)-----------------------------
*-------------------------------------------------------

    
shop:
    
    
*-------------------------------------------------------
*---Combat (Exploration)-----------------------------
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
    bsr         endl
    bsr         endl
    bsr         input
    
    cmp         #1, D1
    beq         attack
    
    cmp         #2, D1
    beq         flee
    bne         combat


*-------------------------------------------------------
*---Attack (Combat)-------------------------------------
*-------------------------------------------------------


attack:
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
    beq         replay
    
    cmp         #max_hp, D1
    bgt         replay

    clr         D1
    move.b      thief_health, D1
    cmp         #0, D1
    beq         victory
    
    cmp         #thief_max_hp, D1
    bgt         failure
    
    bne         combat
     

*-------------------------------------------------------
*---Flee (Combat)-------------------------------------
*-------------------------------------------------------


victory:
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
*---Flee (Combat)-------------------------------------
*-------------------------------------------------------


failure:
    bsr         clear_screen
    lea         failure_msg, A1
    move.b      #14, D0
    trap        #15
    
    bsr         endl
    bsr         endl
    bsr         pause
    bsr         hud
    
    
*-------------------------------------------------------
*---Flee (Combat)-------------------------------------
*-------------------------------------------------------


flee:
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
*-----------------Heads Up Display (Munny)--------------
* Retrieves the score from memory location
*-------------------------------------------------------  

 
hud:

    bsr     endl
    bsr     decorate
    lea     hud_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  (A3),D1     retrieve the value A3 point to and move to D1
    move.b  #3,D0       move literal 3 to D0
    trap    #15         intrepret value in D0, which 3 which displays D1
    bsr     decorate
    rts


*-------------------------------------------------------
*-----------------------Being Attacked------------------
* This could be used for collision detection
*-------------------------------------------------------



collision_hit:
    *hit
    lea     hit_msg,A1
    move    #14,D0
    trap    #15
    rts
    
collision_miss:
    *miss
    lea     miss_msg,A1
    move    #14,D0
    trap    #15
    rts


*-------------------------------------------------------
*--------------------------Loop-------------------------
*-------------------------------------------------------


loop:
    move.b  #5, D3 loop counter D3=5
next:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     next    repeat until D0=0


*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------


decorate:
    move.b  #60, D3
    bsr     endl
out:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     out	    repeat until D0=0
    bsr     endl
    rts
    
clear_screen: 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts
    
pause:
    lea     pause_msg, A1
    move.b  #14, D0
    trap    #15
    
    move.b  #4, D0
    trap    #15
    rts
    
explore_start:
    lea     explore_start_msg, A1
    move.b  #14, D0
    trap    #15
    bsr     endl
    bsr     pause
    bsr     clear_screen
    bsr     explore
    
    
*-------------------------------------------------------
*------------------------Replay-------------------------
*-------------------------------------------------------


replay:
    bsr     endl
    lea     replay_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15

    cmp     #exit,D1
    beq     end         if SR Z register contains 1 beq => Branch Equals
    bsr     gameloop

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
    
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------



crlf:                 dc.b    $0D,$0A,0
welcome_msg:          dc.b    '************************************************************'
                      dc.b    $0D,$0A
                      dc.b    'Avalon: The Legend Lives'
                      dc.b    $0D,$0A
                      dc.b    '************************************************************'
                      dc.b    $0D,$0A,0   
potion_msg:           dc.b    'Feed load (each horse needs at least 100 units of feed)'
                      dc.b    $0D,$0A
                      dc.b    'Enter feed load : ',0
potions_msg:          dc.b    'Number of potions : ',0
weapons_msg:          dc.b    'Each quest need at least 2 Weapons'
                      dc.b    $0D,$0A
                      dc.b    'minimum requirement is 2 i.e. Sword x 1 and Speer x 1.'
                      dc.b    $0D,$0A
                      dc.b    'Enter # of weapons : ',0
gameplay_msg:         dc.b    'Village',0
chapterOne:           dc.b    'you are standing in the village square.'
                      dc.b    $0D,$0A
                      dc.b    'What do you do?'
                      dc.b    $0D,$0A
                      dc.b    '1. Explore land'
                      dc.b    $0D,$0A,0
explore_start_msg:    dc.b    'You leave the village to explore the lands!',0
travel_msg:           dc.b    '1. Travel(1 step, -1 stamina)'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '2. Setup camp(restore stamina)'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b    '3. View player status'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A,0
status_msg:           dc.b	  '            *--------*.'
				      dc.b	  $0D, $0A
				      dc.b	  '            | Status |'
				      dc.b	  $0D, $0A
				      dc.b	  '            *--------*'
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
update_msg:           dc.b    'Update Gameplay !',0
draw_msg:             dc.b    'Draw Screen !',0
hit_msg:              dc.b    'Strike!',0
miss_msg:             dc.b    'Miss!',0
loop_msg:             dc.b    '.',0
replay_msg:           dc.b    'Enter 0 to Quit any other number to replay : ',0
hud_msg:              dc.b    'Score : ',0
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
combat_msg:           dc.b	  '            *--------*.'
				      dc.b	  $0D, $0A
				      dc.b	  '            | Combat |'
				      dc.b	  $0D, $0A
				      dc.b	  '            *--------*'
				      dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
				      dc.b	  $0D, $0A
                      dc.b    '1. Attack'
                      dc.b    $0D,$0A
                      dc.b    $0D,$0A
                      dc.b   '2. Flee'
                      dc.b    $0D,$0A,0
combat_hp_msg:        dc.b   'Player: ',0
thief_hp_msg:         dc.b   'Thief: ',0
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
shop_msg:			  dc.b	'            *------*.'
				      dc.b	$0D, $0A
				      dc.b	'            | Shop |'
				      dc.b	$0D, $0A
				      dc.b	'            *------*'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'1. Water Flask x1			10g'
				      dc.b	$0D, $0A
				      dc.b	'2. Weapon Enchancement <+2dmg>		20g'
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
				      dc.b	'Peddlar: The Bounty for getting rid of this guy is preeety high.'
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	$0D, $0A
				      dc.b	'<== Started "Eliminate the Murderer" Quest ==>',0


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

    end start


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
