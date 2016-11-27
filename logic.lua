------------------------------------------------------------------------
-- This is a Aspen EFD1000 inspired EFD                               --
-- Made by Ralph with help from Corjan                                --
-- Improved VERSION 2.00 beta                                         --
-- J.ZAHAR ET T. GEORGELIN                                            --
-- 03/03/16                                                           --
------------------------------------------------------------------------
-- *********************************************************************************************** --
------------------------------------------------------------------------
--                       DISPLAY OPTIONS VARIABLES                    --
--                         (Modify to taste)   	                      --
------------------------------------------------------------------------
----------- Barometer default Unit setting ----------
-- Set baro_unit to "inHg" to display in Hg
-----------------------------------------------------
baro_unit="Millibars" 
----------- V-Speed values --------------------------
--  adjust values to the current airplane
-- (Set all values to zero to hide speedtapes)
-----------------------------------------------------
-- vne=0 
-- vno=0 
-- vfe=0 
-- vs=0
-- vs0=0 
vne=210 -- Never exceed speed: start of red speedtape in kts (min 0, max 450)
vno=180 -- Normal operation speed: start of yellow speedtape in kts(min 0, max 450)
vfe=122 -- max flaps extension speed: start of green tape in kts
vs=84 -- Stall speed flaps 0°: start of white tape 1 in kts
vs0=55 -- Stall speed full flaps: start of white tape 2 and end of bottom red tape in kts
----------- Vref values ------------------------------
-- To be done....
------------------------------------------------------
-- •  Va – Design Maneuvering Speed 
-- •  Vbg – Best Glide Speed 
-- •  Vref – Approach Reference Speed 
-- •  Vr – Rotation Speed 
-- •  Vx – Best Angle of Climb Speed 
-- •  Vy – Best Rate of Climb Speed 
-- •  Vlo – Maximum Landing Gear Operating Speed 
-- •  Vle – Maximum Landing Gear Extended Speed
-------- Startup Diagnostics message durations -------
-- set all values to 0  to bypass startup sequence
------------------------------------------------------
start1_duration1=1000 -- duration of message in milliseconds, set duration to 0 for no display
start1_duration2=4000 -- duration of message in milliseconds, set duration to 0 for no display
start1_duration3=3000 -- duration of message in milliseconds, set duration to 0 for no display
start1_duration4=1500 -- duration of message in milliseconds, set duration to 0 for no display
start1_duration5=3000 -- duration of message in milliseconds, set duration to 0 for no display
start1_duration6=3000 -- duration of message in milliseconds, set duration to 0 for no display
start1_duration7=5000 -- duration of message in milliseconds, set duration to 0 for no display
start1_duration8=10000 -- duration of message in milliseconds, set duration to 0 for no display
-- start1_duration1=000
-- start1_duration2=000 
-- start1_duration3=000 
-- start1_duration4=000
-- start1_duration5=000
-- start1_duration6=000
-- start1_duration7=000
-- start1_duration8=000
---------- Shutdown phase message durations ---------
-- set all values to 0 to bypass shutdown phase
-----------------------------------------------------
countdown_duration=10000 -- duration of countdown message in milliseconds, set duration to 0 for no display
shutdown_duration2=3000 --- duration of message in milliseconds, set duration to 0 for no display
-- countdown_duration=000
-- shutdown_duration2=000
------------------------------------------------------------------------
--                      DISPLAY OPTIONS VARIABLES                     --
--                            END OF SECTION   	                      --
--                Do not modifiy the code beyond this point!          --
------------------------------------------------------------------------
-- *********************************************************************************************** --
---------------
-- Add sound --
---------------
snd_dhwarning = sound_add("dhaudio.wav") -- decision height
snd_apaltwarning = sound_add("alttone.wav")
----------------------
-- Global variables --
----------------------
decisionheightwarning = true
altwarning = true
mode=0 --source for HSI 0=GPS1 1=VLOC1 2=VLOC2
tapes_displayed = true -- tapes
off_state=true -- instrument is off
buttonpressed=false
hsimode=0 -- vor1
rmi1mode=0 --
rmi2mode=0 --

gpswptname="GPSWPT"
overspeed=false
running_text_inner_speed_minor_displayed=running_text_inner_speed_minor_id
running_text_inner_speed_major_displayed=running_text_inner_speed_major_id
-------------------------------------------------------
-- Add images in Z-order                             --
-- ne pas changer l'ordre d'affichage!               --
-------------------------------------------------------

img_horizon = img_add("horizon.png", -400, -1522 + 382, 2000, 3500)
img_horizonscale = img_add("horizonscale2.png",-400,-1522+382+250,2000,3500)

img_flightdirector = img_add("flightdirector.png", 222, 382, 354, 56) -- maquette du Flight director

img_add("background2.png",0,0,800,1522) -- fond de jauge
---------------------------------------------------------
--           fond de jauge modele pour debug           --
--           et positionnement NE PAS DECOMMENTER      --
-- img_add_fullscreen("modele.png")
---------------------------------------------------------

-----------------------------------
-- gauge upper section (horizon) --
-----------------------------------
-- affichage de l'horizon
img_decisionheight = img_add("dhind.png", 215, 24, 34, 34) -- indicateur DH

img_roll = img_add("roll3.png", 2, -20, 801, 800) -- inclinaison
img_slip = img_add("slip.png", 252, 82, 38, 8)--  Bille

---------- SPD & ALT TAPES --------
-- affichage du fond grisé (tapes)
img_tapesbackground = img_add("tapesbackground.png", 0, 51, 800, 606) 

----------- color speed tapes
-- do not change the display order!

img_spdred_low = img_add("speedred2.png", 96, -600, 20, 3000)
img_spdwhite0 = img_add("speedwhite.png", 96, -600, 20, 3000)
img_spdwhite1 = img_add("speedgreen.png", 96, -600, 20, 3000)
img_spdgreen = img_add("speedgreen.png", 96, -600, 20, 3000)
img_spdyellow = img_add("speedyellow.png", 96, -600, 20, 3000)
img_spdred_dash = img_add("speedred_dash.png", 80, -600, 50, 8)
img_spdred = img_add("speedred.png", 96, -600, 21, 3000)

viewport_rect(img_spdred_low, 96, 52, 50, 606)
viewport_rect(img_spdwhite0, 96, 52, 50, 606)
viewport_rect(img_spdwhite1, 107, 52, 10, 606)
viewport_rect(img_spdgreen, 96, 52, 50, 606)
viewport_rect(img_spdyellow, 96, 52, 50, 606)
viewport_rect(img_spdred, 96, 52, 50, 606)

----------- Running text and images for speed (vertical tapes)
function item_value_callback_speed(i)
t=(i*10)*-1
--print("i"..i.."="..string.format("%d", 0 - (i * 10) ))
if (t>450 or t<30) then
	return""
  else
	return string.format("%d", t)
    --return string.format("%d", 0 - (i * 10) )
end
end

--running_text_speed = running_txt_add_ver(0,-25,10,68,66,item_value_callback_speed,"-fx-font-size:28px; -fx-font-family:Arial; -fx-fill:white; -fx-text-alignment:right;")
--running_txt_add_ver(x,y,nr_visible_item,item_width,item_height,value callback,item_style)
running_text_speed = running_txt_add_ver(3,33,10,68,66,item_value_callback_speed,"-fx-font-size:32px; -fx-font-family:Arial; -fx-fill:white; -fx-text-alignment:right;")
viewport_rect(running_text_speed,0,52,95,302)
--running_img_speed_norm  = running_img_add_ver("speedscaleimage.png",71,-9,10,34,66)
-- running_img_speed_norm  = running_img_add_ver("speedscaleimage.png",76,-16,10,40,66)
running_img_speed_norm  = running_img_add_ver("speedscaleimage.png",76,-16,10,40,66)
--viewport_rect(running_img_speed_norm,72,52,34,302)
viewport_rect(running_img_speed_norm,80,52,200,100)

running_img_move_carot(running_img_speed_norm, 1) -- si vitesse < 20 kts, affichage bloqué à 0, soit le premier cran
running_txt_move_carot(running_text_speed, -1) -- si vitesse < à 20kts, affichage du tape bloqué à 20

---------- Affichage du speedbug
--img_speedbug_blue = img_add("speedbug_blue.png", 75, 327, 20, 60) -- bug vitesse("speedbug.png", 80, -8, 16, 50)
img_speedbug_blue = img_add("speedbug_blue.png", 75, 383, 20, 60) -- bug vitesse("speedbug.png", 80, -8, 16, 50)
img_speedbug_magenta = img_add("speedbug_magenta.png", 75, 327, 20, 60) -- bug vitesse("speedbug.png", 80, -8, 16, 50)
viewport_rect(img_speedbug_blue,60,52,137,600)
viewport_rect(img_speedbug_magenta,60,52,137,600)
-- Running text airspeed (drum) --
--img_speedbox = img_add("speedbox.png", 0, 325, 93, 110)-- affichage vitesse
img_speedbox = img_add("speedbox.png", 0, 325, 95, 110)-- affichage vitesse
function item_value_callback_inner_speed_minor(i)
	if i == 0 then 
	    return "-"  -- tiret affiché
	elseif i >= -1 then
		return""
	else
		return string.format("%d", (0 - i) % 10 )
	end
end
--running_text_inner_speed_minor_id = running_txt_add_ver(48,209,5,30,44, item_value_callback_inner_speed_minor, "-fx-font-size:42px; -fx-font-family:arial; -fx-font-weight:bold; -fx-fill:white;")
--running_txt_move_carot(running_text_inner_speed_minor_id, -1)
--running_txt_viewport_rect(running_text_inner_speed_minor_id,43,268,29,106)
running_text_inner_speed_minor_id_red = running_txt_add_ver(46,267,5,30,44, item_value_callback_inner_speed_minor, "-fx-font-size:46px; -fx-font-family:\"Arial\"; -fx-font-weight:bold; -fx-fill:red;")
running_text_inner_speed_minor_id = running_txt_add_ver(46,267,5,30,44, item_value_callback_inner_speed_minor, "-fx-font-size:46px; -fx-font-family:\"Arial\"; -fx-font-weight:bold; -fx-fill:white;")

running_txt_move_carot(running_text_inner_speed_minor_id, -1)
running_txt_viewport_rect(running_text_inner_speed_minor_id,43,330,29,100)
running_txt_viewport_rect(running_text_inner_speed_minor_id_red,43,330,29,100)
function item_value_callback_inner_speed_major(i)
    
	if i == 0 then
		return "--"
	else
		return string.format("%d", (0 - i) )
	end
	
end
--running_text_inner_speed_major_id = running_txt_add_ver(-1,253,3,50,44, item_value_callback_inner_speed_major, "-fx-font-size:42px; -fx-font-family:arial; -fx-fill:white; -fx-font-weight:bold; -fx-text-alignment:right")
--position en x,y de l'affichage, nb items,largeur, hauteur \"Arial Narrow\
running_text_inner_speed_major_id_red= running_txt_add_ver(-6,310,3,52,45, item_value_callback_inner_speed_major, "-fx-font-size:46px; -fx-font-family:arial; -fx-fill:red; -fx-font-weight:bold; -fx-text-alignment:right")
running_text_inner_speed_major_id = running_txt_add_ver(-6,310,3,52,45, item_value_callback_inner_speed_major, "-fx-font-size:46px; -fx-font-family:arial; -fx-fill:white; -fx-font-weight:bold; -fx-text-alignment:right")
visible(running_text_inner_speed_major_id,true)
visible(running_text_inner_speed_major_id_red,false)
running_txt_move_carot(running_text_inner_speed_major_id, 0)
running_txt_viewport_rect(running_text_inner_speed_major_id,-25,355,150,45)
running_txt_viewport_rect(running_text_inner_speed_major_id_red,-25,355,150,45)
--running_txt_viewport_rect(running_text_inner_speed_major_id,2,295,46,52)

------------Running text and images for alt (vertical tapes)
function item_value_callback_alt(i)
t=i*100
if (t>51000) then
	return""
  else
	return string.format("%d", i * 100 * -1 )
  end
 end

--running_text_alt = running_txt_add_ver(710,-159,8,80,116,item_value_callback_alt,"-fx-font-size:28px; -fx-font-family:Arial; -fx-fill:white; -fx-text-alignment:right;")
--running_img_alt  = running_img_add_ver("altscaleimage.png",663,-27,6,31,116)
--(670,-102,8,122,116
running_text_alt = running_txt_add_ver(670,-104,8,122,116,item_value_callback_alt,"-fx-font-size:34px; -fx-font-family:Arial; -fx-fill:white;  -fx-text-alignment:right;")---fx-font-weight:bold;
-- 664,-84,8,31,116)
running_img_alt  = running_img_add_ver("altscaleimage.png",645,-84,8,31,116)-- ("altscaleimage.png",663,-85,6,31,116)
running_img_move_carot(running_img_alt, 0)
running_txt_move_carot(running_text_alt, 0)

----------  Alt Bug 
img_altbug_blue = img_add("altbug_blue.png", 657, 327, 25, 60) -- bug altitude("altbug.png", 663, -8, 16, 50)
img_altbug_magenta = img_add("altbug_magenta.png", 657, 327, 25, 60)
viewport_rect(img_altbug_blue,663,52,137,600)
viewport_rect(img_altbug_magenta,663,52,137,600)
visible(img_altbug_blue,true)
visible(img_altbug_magenta,false)

---------- Running text altitude (drum) --
img_altbox = img_add("altbox.png", 640, 325, 160, 110)--663, 325, 137, 110)-- affichage altitude dans tape
function item_value_callback_inner_alt_minor(i)
--print("unité:"..i) 
	if i == 0 then
		return"00"
	elseif  i>0 and i<10 then
		return ""..string.format("%02d",((i)%10) * 10)
	elseif i>=10 then
	return string.format("%02d",((i)%10) * 10)
	else
		return string.format("%02d", ((0-i)%10) * 10 )
	end
	
end

--running_text_inner_alt_minor_id = running_txt_add_ver(745,225,5,50,40, item_value_callback_inner_alt_minor, "-fx-font-size:28px; -fx-font-family:arial; -fx-fill:white; -fx-font-weight:bold; -fx-text-alignment:right")
--running_txt_move_carot(running_text_inner_alt_minor_id, 0)
--running_txt_viewport_rect(running_text_inner_alt_minor_id,755,268,42,106)
-- 738,274,5,60,44
--running_text_inner_alt_minor_id = running_txt_add_ver(732,275,5,60,44, item_value_callback_inner_alt_minor, "-fx-font-size:34px; -fx-font-family:arial; -fx-fill:white; -fx-font-weight:bold; -fx-text-alignment:right")
running_txt_move_carot(running_text_inner_alt_minor_id, 0)
--755,330,100,100
running_txt_viewport_rect(running_text_inner_alt_minor_id,749,330,100,100)

function item_value_callback_inner_alt_major100(i)
--print("cent: ",i) 
	if i == 0 then
		return"0"
	-- elseif i==1 then
		 -- return "1"
	elseif i<0.1 and i>0 then
		 return "-"
	--return string.format("%d",-(i%10)+1)
	-- elseif i>1 and i<10 then
		-- return ""..string.format("%d",-(i%10))
	elseif i>=0.1 then
		 return ""..string.format("%d",i%10)
	else
		return string.format("%d", - i%10)
	end
	
end
--716,312,3,44,50
running_text_inner_alt_major100_id = running_txt_add_ver(694,331,3,60,32, item_value_callback_inner_alt_major100, "-fx-font-size:34px; -fx-font-family:arial; -fx-fill:white; -fx-font-weight:bold; -fx-text-alignment:right")
running_txt_move_carot(running_text_inner_alt_major100_id, 0)
--708,345,60,52)
running_txt_viewport_rect(running_text_inner_alt_major100_id,694,300,100,52)

function item_value_callback_inner_alt_major1000(i)
 -- print("mill:"..i) 
 if i==0 then
 return ""
 elseif i>0 and i<1 then 
 return "-"
 -- elseif i<10 and i>=1 then 
 -- return "-1"
 -- elseif i > 0 and i<10 then
		-- return"-"
	-- elseif i==1 then
		-- return string.format("%s","-")
	elseif i>=1 then
		return string.format("%d",-i)
	else
		return string.format("%d", - i)
	end
	
end
--running_text_inner_alt_major1000_id = running_txt_add_ver(638,291,3,104,60, item_value_callback_inner_alt_major1000, "-fx-font-size:52px; -fx-font-family:arial; -fx-fill:white; -fx-font-weight:bold; -fx-text-alignment:right")
--(590,291,3,150,60
running_text_inner_alt_major1000_id = running_txt_add_ver(582,303,3,150,48, item_value_callback_inner_alt_major1000, "-fx-font-size:52px; -fx-font-family:arial; -fx-fill:white; -fx-font-weight:bold; -fx-text-alignment:right")

running_txt_move_carot(running_text_inner_alt_major1000_id, 0)
-- 600,355,300,52)
running_txt_viewport_rect(running_text_inner_alt_major1000_id,580,355,300,52)
------------ red dashes on SPD and ALT
--img_altreddash=img_add("redslash_centerbutton.png",680,379,120,3) -- barre rouge sur alti si alt>51000
--img_spdreddash=img_add("redslash_centerbutton.png",1,379,80,3) -- barre rouge sur speed si speed>450
visible(img_altreddash,false)
visible(img_spdreddash,false)

------------ SPD & ALT box
img_upperspeedbox=img_add("upperspeedbox.png", 592, 0, 209, 51)
img_upperaltbox=img_add("upperaltbox.png", 0, 0, 171, 51)
img_apaltbox = img_add("apaltbox.png", 592, 0, 206, 51) -- indicateur altitude capturée en jaune
visible(img_upperspeedbox,true)
visible(img_upperaltbox,true)
visible(img_apaltbox,true)
-----------------------------------
-- gauge lower section (HSI & ND) --
-----------------------------------

------------ 360° ROSE
img_rosemarks= img_add("compasrosemarks.png",0,739,800,800)
img_compasrose= img_add("compasrose.png",(800-590)/2,844,590,590)

-- affichage de la rose sans les lettres
function item_value_callback_compass(i)
    t = i % 12
    if t == 0 then
        return ""
    elseif t == 3 then
        return ""
    elseif t == 6 then
        return ""        
    elseif t == 9 then
        return ""
    end  
    value = 36 - (t*3)
    if value < 0 then
        value = value + 36
    end
   
    return value
end
compass_inner_txt_id = running_txt_add_cir(400-22,1522-383-22,12,40,40,235,item_value_callback_compass, "-fx-font-size:34px; -fx-font-family:Arial; -fx-fill:white; -fx-font-weight:bold; -fx-text-alignment:center")
-- Affichage de la rose avec les lettres en police + grosse
function item_value_callback_compass2(j)
    t2 = j % 12
    if t2 == 0 then
        return "N"
    elseif t2 == 3 then
        return "W"
    elseif t2 == 6 then
        return "S"        
    elseif t2 == 9 then
        return "E"
    else
 		return ""
	end
end
compass_inner_txt_id2 = running_txt_add_cir(400-28,1522-383-28,12,60,60,235,item_value_callback_compass2, "-fx-font-size:40px; -fx-font-family:Arial; -fx-fill:white; -fx-font-weight:bold; -fx-text-alignment:center")

------------- left info block
img_add("rectNAVSOURCEINFOBLOCK.png", 20, 770, 85, 35)

------------- Turn indicator -- 
--img_turnleft = img_add("turnindbar2.png",132,825,536,536)
--img_rotate(img_turnleft, 8.5)
--img_turnright = img_add("turnindbar2.png",132,822,536,536)
--img_rotate(img_turnright, -8)
img_turnindicator=img_add("turnindicator2.png",(800-196)/2,812,196,42)
--img_turnlimitleft=img_add("turnlimitleft.png",302,810,198,42)
--img_turnlimitright=img_add("turnlimitright.png",302,810,198,42)

------------- true heading bug (GPS source)
img_trueh = img_add("trueheading.png", (800-67)/2, 1520-383-(570/2), 67, 570)

------------- Heading bug (HDG)
img_headind = img_add("headingind.png", (800-70)/2, 1520-383-(602/2), 70, 602)
img_headindblue = img_add("headingindblue2.png", (800-72)/2, 1520-383-(602/2), 70, 602)


img_degreebox = img_add("degreebox.png", 400-(134/2), 768, 134, 97)--332.5 768
txt_compheading = txt_add(" ", "-fx-font-size:58px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment:left;", 340, 762, 150, 100)-- ok

------------ Blue RMI needles on top of compass
img_rmi1needleblue = img_add("vorneedle1blue.png", (800-39)/2, 1522-383-(549.4/2), 39, 549.4)--30, 413
img_rmi2needleblue = img_add("vorneedle2hollowblue.png", (800-59.88)/2, 1522-383-(570/2), 59.88, 570)--
visible(img_rmi1needleblue,false)
visible(img_rmi2needleblue,false)

------------ HSI Needle on top of compass 
img_needle = img_add("hsi_needle4.png", (800-549.4)/2, 1522-383-(549.4/2), 549.4, 549.4)

img_center_needle_to = img_add("hsi_center_needle_to4.png", (800-549.4)/2, 1520-383-(549.4/2), 549.4, 549.4)--6.6  246.3
img_center_needle_from = img_add("hsi_center_needle_from4.png", (800-549.4)/2, 1520-383-(549.4/2), 549.4, 549.4)
visible(img_center_needle_to,false)
visible(img_center_needle_from,false)
img_center_needlehollow_to = img_add("hsi_center_needlehollow_to4.png", (800-549.4)/2, 1520-383-(549.4/2), 549.4, 549.4)
img_center_needlehollow_from = img_add("hsi_center_needlehollow_from4.png", (800-549.4)/2, 1520-383-(549.4/2), 549.4, 549.4)
visible(img_center_needlehollow_to,false)
visible(img_center_needlehollow_from,false)
img_to_flag=img_add("hsi_to_flag4.png", 800-(549.4)/2, 1520-383-(549.4/2), 549.4,549.4)--29, 276.6)
img_from_flag=img_add("hsi_from_flag4.png", 800-(549.4)/2, 1520-383-(549.4/2), 549.4,549.4)
visible(img_to_flag,false)
visible(img_from_flag,false)
img_add("airplane-icon.png", (800-64)/2, 1520-383-(64/2), 64, 64)   
--img_add("airplane-icon2.bmp", (800-64)/2, 1522-383-(54/2), 64, 54)        

 ------------ ARC ROSE
-- img_rose= img_add("compasrosemarks.png",0,735,800,800)
-- img_compasrose= img_add("compasrose.png",(800-590)/2,840,590,590)

------------- bottom menu bar & icons
img_bottom_menubar=img_add("bottommenubar.png",0,1510-50,800,53)
img_RMI_sourcearrow1=img_add("RMIsourcearrow1.png",168,1522-60,32,38)--168
img_RMI_sourcearrow2=img_add("RMIsourcearrow2.png",595,1522-60,32,38)--593

--------------
-- Add text --
--------------
-- Infobar top
txt_apspd1 = txt_add(" ", "-fx-font-size:48px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:left;", 12, -1, 90, 100)
txt_apspd2 = txt_add(" ", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:left;", 80, 11, 90, 100)
txt_apalt1 = txt_add("", "-fx-font-size:48px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:right;", 638, -1, 90, 100)
txt_apalt2 = txt_add("", "-fx-font-size:38px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:right;", 700, 5, 90, 100)

visible(txt_apspd1,true)
visible(txt_apspd2,true)
visible(txt_apalt1,true)
visible(txt_apalt2,true)
-- Infobar center
txt_add("TAS", "-fx-font-size:24px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment:left;", 6, 678, 150, 100)-- ok
txt_tas = txt_add("___", "-fx-font-size:40px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:right;", 15, 664, 121, 100)--68 ok
txt_tas_unit = txt_add(" kt", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:right;", 50, 672, 121, 100)

txt_add("GS", "-fx-font-size:24px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment:left;", 17, 729, 150, 100)-- ok
txt_gs = txt_add("___", "-fx-font-size:40px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:right;", 15, 714, 121, 100)-- ok
txt_gs_unit = txt_add(" kt", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:right;", 50, 723, 120, 100)

txt_add("OAT ", "-fx-font-size:24px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment:left;", 226, 729, 150, 100)
txt_oat = txt_add(" ", "-fx-font-size:40px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:right;", 248, 714, 120, 100)

img_windarrow = img_add("windarrow.png", 480, 715, 28, 40)
txt_wind = txt_add("    /   kt", "-fx-font-size:40px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:left;", 530, 714, 200, 100)

txt_inhg = txt_add("0000", "-fx-font-size:40px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:right;", 629, 664, 120, 50)
if baro_unit=="Millibars" then
	txt_inhg_unit=txt_add("mB","-fx-font-size:24px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:right;", 672, 680, 120, 50)
else
	txt_inhg_unit=txt_add("in","-fx-font-size:24px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:right;", 675, 680, 120, 50)
end
-- Navigation section

txt_add("CRS", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:left;", 199, 763, 200, 100)-- ok
txt_course = txt_add(" ", "-fx-font-size:42px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bolder; -fx-text-alignment:left;", 197, 792, 200, 100)-- ok

txt_add("HDG", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:left;", 524, 763, 200, 100)-- ok
txt_hdg = txt_add(" ", "-fx-font-size:42px; -fx-font-family:Arial; -fx-fill: cyan; -fx-font-weight:bolder; -fx-text-alignment:left;", 518, 792, 200, 100)-- ok

txt_vsi = txt_add("", "-fx-font-size:42px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:right;", 558, 760, 200, 100)-- ok
txt_vsi2=txt_add("FPM", "-fx-font-size:24px; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment:right;", 558, 805, 200, 100)-- ok
visible(txt_vsi,false)
visible(txt_vsi2,false)

txt_CDI_source = txt_add("", "-fx-font-size:26px; -fx-font-family:Arial; -fx-fill: #5fce4b; -fx-font-weight:bolder; -fx-text-alignment:left;", 25, 772, 200, 100)
txt_CDI_wptid = txt_add("", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: #5fce4b; -fx-font-weight:bold; -fx-text-alignment:left;", 12, 808, 200, 100)
txt_CDI_wptbearingdist = txt_add("", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: #5fce4b; -fx-font-weight:bold; -fx-text-alignment:left;", 12, 840, 200, 100)
txt_CDI_wptETA = txt_add("", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: #5fce4b; -fx-font-weight:bold; -fx-text-alignment:left;", 12, 872, 200, 100)

txt_RMI1_wptbearingdist = txt_add("", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:left;", 100, 1522-128, 200, 100)
txt_RMI1_wptid = txt_add("", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:left;", 100, 1522-98, 200, 100)
txt_RMI2_wptbearingdist = txt_add("XX.XNm", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:right;", 480, 1522-128, 200, 100)
txt_RMI2_wptid = txt_add("XXX.XMHz", "-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: aqua; -fx-font-weight:bold; -fx-text-alignment:right;", 480, 1522-98, 200, 100)

-- Infobar bottom
txt_leftbutton=txt_add("VOR1","-fx-font-size:34px; -fx-font-family:Arial; -fx-fill: cyan; -fx-font-weight:bold; -fx-text-alignment:center;", 150, 1460, 200, 100)
img_redslash_leftbutton=img_add("redslash_centerbutton.png",200,1478,100,3)
visible(img_redslash_leftbutton,false)

txt_centerbutton=txt_add("VLOC1","-fx-font-size:42px; -fx-font-family:Arial; -fx-fill: #5fce4b; -fx-font-weight:bolder; -fx-text-alignment:center;", 300, 1460, 200, 100)
img_redslash_centerbutton=img_add("redslash_centerbutton.png",400-(157/2),1485,157,3)
visible(img_redslash_centerbutton,true)

txt_rightbutton=txt_add("VOR2","-fx-font-size:34px; -fx-font-family:Arial; -fx-fill: cyan; -fx-font-weight:bold; -fx-text-alignment:right;", 390, 1460, 200, 100)
img_redslash_rightbutton=img_add("redslash_centerbutton.png",495,1478,100,3)
visible(img_redslash_rightbutton,true)

txt_leftdial=txt_add("CRS","-fx-font-size:46px; -fx-font-family:Arial; -fx-fill: cyan; -fx-font-weight:bold; -fx-text-alignment:left;", 40, 1462, 200, 100)
txt_rightdial=txt_add("HDG","-fx-font-size:46px; -fx-font-family:Arial; -fx-fill: cyan; -fx-font-weight:bold; -fx-text-alignment:right;", 800-154, 1462, 150, 100)

----------------------------
-- Failure flags --
----------------------------
img_VSI_fail=img_add("VSI_fail.png",800-235,1522-62-697,235,697)
img_ALT_fail=img_add("ALT_fail.png",0,0,162,659)
img_IAS_fail=img_add("IAS_fail.png",800-162,0,162,659)
-- visible(img_IAS_fail,false)
-- visible(img_ALT_fail,false)
-- visible(img_VSI_fail,false)
------------------
--  Lateral Menu--
------------------
img_lateral_menubar=img_add("bluelateralmenubar.png",800-24,1522-696-63,25,696) -- barre de menu latérale
img_TPSlegend_green=img_add("TPSlegend_green.png",800-16-3,1522-66.6-696+15,16,66.6)
img_TPSlegend_gray=img_add("TPSlegend_gray.png",800-16-3,1522-66.6-696+15,16,66.6)
visible(img_TPSlegend_green,true)
visible(img_TPSlegend_gray,false)
img_MINlegend_green=img_add("MINlegend_green.png",800-16-3,1522-66.6-696+155,16,66.6)
img_MINlegend_gray=img_add("MINlegend_gray.png",800-16-3,1522-66.6-696+155,16,66.6)
visible(img_MINlegend_green,true)
visible(img_MINlegend_gray,false)
img_360legend_green=img_add("360legend_green.png",800-16-3,1522-66.6-696+300,16,66.6)
img_ARClegend_green=img_add("ARClegend_green.png",800-16-3,1522-66.6-696+300,16,66.6)
visible(img_360legend_green,true)
visible(img_ARClegend_green,false)
img_MAPlegend_green=img_add("MAPlegend_green.png",800-16-3,1522-66.6-696+445,16,66.6)
img_MAPlegend_gray=img_add("MAPlegend_gray.png",800-16-3,1522-66.6-696+445,16,66.6)
visible(img_MAPlegend_green,false)
visible(img_MAPlegend_gray,true)
img_GPSSlegend_green=img_add("GPSSlegend_green.png",800-16-3,1522-66.6-696+590,16,85.9)
img_GPSSlegend_gray=img_add("GPSSlegend_gray.png",800-16-3,1522-66.6-696+590,16,85.9)
visible(img_GPSSlegend_green,false)
visible(img_GPSSlegend_gray,true)
-----------------------------------------
-- Startup & diagnostics images & text --
-----------------------------------------
img_startup_bkg_blackscreen=img_add("blackscreen.png",0,0,800,1522) 
visible(img_startup_bkg_blackscreen,true)
img_startup_bkg_white=img_add("startup_bkg_white.png",24,800,800-48,400)
visible(img_startup_bkg_white,true)
img_startup=img_add_fullscreen("startupscreen1ok.png")
visible(img_startup,false)
txt_IOP=txt_add("IOP", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 50, 825, 200, 100)
txt_IOP_statusna=txt_add("n/a", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 825, 200, 100)
txt_IOP_statusinit=txt_add("initializing", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 825, 200, 100)
txt_IOP_statuscomplete=txt_add("complete", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: darkgreen; -fx-font-weight:bold; -fx-text-alignment:left;",310, 825, 200, 100)

txt_ARINC=txt_add("ARINC", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 50, 868, 200, 100)
txt_ARINC_statusna=txt_add("n/a", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 868, 200, 100)
txt_ARINC_statusinit=txt_add("initializing", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 868, 200, 100)
txt_ARINC_statuscomplete=txt_add("complete", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: darkgreen; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 868, 200, 100)

txt_RS232=txt_add("RS232", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 50, 911, 200, 100)
txt_RS232_statusna=txt_add("n/a", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 911, 200, 100)
txt_RS232_statusinit=txt_add("initializing", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 911, 200, 100)
txt_RS232_statuscomplete=txt_add("complete", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: darkgreen; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 911, 200, 100)

txt_CFG=txt_add("Config Module", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 50, 954, 280, 100)
txt_CFG_statusna=txt_add("n/a", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 954, 200, 100)
txt_CFG_statusinit=txt_add("initializing", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 954, 200, 100)
txt_CFG_statuscomplete=txt_add("complete", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: darkgreen; -fx-font-weight:bold; -fx-text-alignment:left;",310, 954, 200, 100)

txt_RSM=txt_add("RSM", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 50, 997, 200, 100)
txt_RSM_statusna=txt_add("n/a", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 997, 200, 100)
txt_RSM_statusinit=txt_add("initializing", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 997, 200, 100)
txt_RSM_statuscomplete=txt_add("complete", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: darkgreen; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 997, 200, 100)

txt_IMU=txt_add("IMU", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 50, 1040, 200, 100)
txt_IMU_statusna=txt_add("n/a", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 1040, 200, 100)
txt_IMU_statusinit=txt_add("initializing", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 1040, 200, 100)
txt_IMU_statuscomplete=txt_add("complete", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: darkgreen; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 1040, 200, 100)

txt_ADC=txt_add("ADC", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 50, 1083, 200, 100)
txt_ADC_statusna=txt_add("n/a", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 1083, 200, 100)
txt_ADC_statusinit=txt_add("initializing", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 1083, 200, 100)
txt_ADC_statuscomplete=txt_add("complete", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: darkgreen; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 1083, 200, 100)

txt_ADAHRS=txt_add("ADAHRS", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 50, 1126, 200, 100)
txt_ADAHRS_statusna=txt_add("n/a", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 1126, 200, 100)
txt_ADAHRS_statusinit=txt_add("initializing", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 1126, 200, 100)
txt_ADAHRS_statuscomplete=txt_add("complete", "-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: darkgreen; -fx-font-weight:bold; -fx-text-alignment:left;", 310, 1126, 200, 100)

------------------------------------
-- Shutdown sequence images & text --
------------------------------------
-- img_screenoff: ecran noir au démarrage, 
-- doit être la dernière image affichée
-- pour pouvoir cacher toutes les autres !
img_shutdown1=img_add("shutdownmessage1.png",(800-764)/2,(1522-452)/2,764,452)
visible(img_shutdown1,false)
txt_shutdown_countdown=txt_add("10","-fx-font-size:32pt; -fx-font-family:Arial; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment:center;", 450, 693, 200, 100)
visible(txt_shutdown_countdown,false)
img_screenoff=img_add("blackscreen.png",0,0,800,1522) 
visible(img_screenoff,true)
img_shutdown2=img_add("shutdownmessage2.png",(800-382)/2,(1522-140)/2,382,140)
visible(img_shutdown2,false)

---------------
-- Viewports --
---------------
viewport_rect(img_horizon, 0, 0, 800, 800)
viewport_rect(img_horizonscale, 100, 105, 500,535 )

viewport_rect(img_roll, 161, 0, 479, 300)

viewport_rect(img_turnleft, 302, 800, 96, 42)
viewport_rect(img_turnright, 402, 800, 96, 42)

-- ============================= END OF GAUGE DEFINITION AND DRAWING SECTION =======================================================
---------------
-- Functions --
---------------
-------- Tapes display -----------------
function display_tapes(display)
	-- si l'affichage des tapes a été demandé
	-- if tapes_displayed == false then
	if (display == true and tapes_displayed==false) then
		tapes_displayed = true
		-- on diminue la zone d'affichage de l'échelle de roulis quand les tapes sont affichées
		viewport_rect(img_roll, 165, 0, 475, 800)
		-- affichage légende sur menu latéral
		visible(img_TPSlegend_green,true)
		visible(img_TPSlegend_gray,false)
	else
		tapes_displayed = false
		viewport_rect(img_roll, 0, 0, 800, 800)
		-- affichage légende sur menu latéral
		visible(img_TPSlegend_green,false)		
		visible(img_TPSlegend_gray,true)
	end
visible (img_tapesbackground,tapes_displayed) 
visible (img_altbug_blue,tapes_displayed) 
visible (img_altbug_magenta,tapes_displayed) 
visible (img_speedbug_blue,tapes_displayed) 
visible (img_speedbug_magenta,tapes_displayed) 
visible (img_speedbox,tapes_displayed)
visible (img_altbox,tapes_displayed) 

visible (img_spdred_low,tapes_displayed)
visible (img_spdwhite0,tapes_displayed)
visible (img_spdwhite1,tapes_displayed)
visible (img_spdgreen,tapes_displayed) 
visible (img_spdyellow,tapes_displayed)
visible (img_spdred,tapes_displayed)

visible (running_img_alt,tapes_displayed)
visible (running_img_speed_norm,tapes_displayed)
visible (running_text_inner_alt_major100_id,tapes_displayed)
visible (running_text_inner_alt_major1000_id,tapes_displayed)
visible (running_text_inner_alt_minor_id,tapes_displayed)
visible (running_text_inner_speed_minor_displayed,tapes_displayed)
visible (running_text_inner_speed_major_displayed,tapes_displayed)
--visible (running_text_inner_speed_minor_id,tapes_displayed)
--visible (running_text_inner_speed_major_id,tapes_displayed)
--visible (running_text_inner_speed_minor_id_red,tapes_displayed)
--visible (running_text_inner_speed_major_id_red,tapes_displayed)
visible (running_text_alt,tapes_displayed)
visible (running_text_speed,tapes_displayed)
visible(img_altreddash,tapes_displayed)
visible(img_spdreddash,tapes_displayed)
end-- 
---------  Startup sequence ----------------------
function display_startup() -- first page (all n/a in grey)
off_state = false
visible(img_screenoff,false) -- on enlève l'écran noir
visible(img_startup,false)
visible(img_startup_bkg_blackscreen,true) -- on met l'écran noir de démarrage
visible(img_startup_bkg_white,true) -- on met le fond blanc pour le texte
visible(txt_IOP,true)
txt_style(txt_IOP,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_IOP_statusna,true)
visible(txt_IOP_statusinit,false)
visible(txt_IOP_statuscomplete,false)
visible(txt_ARINC,true)
txt_style(txt_ARINC,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_ARINC_statusna,true)
visible(txt_ARINC_statusinit,false)
visible(txt_ARINC_statuscomplete,false)
visible(txt_RS232,true)
txt_style(txt_RS232,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_RS232_statusna,true)
visible(txt_RS232_statusinit,false)
visible(txt_RS232_statuscomplete,false)
visible(txt_CFG,true)
txt_style(txt_CFG,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_CFG_statusna,true)
visible(txt_CFG_statusinit,false)
visible(txt_CFG_statuscomplete,false)
visible(txt_RSM,true)
txt_style(txt_RSM,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_RSM_statusna,true)
visible(txt_RSM_statusinit,false)
visible(txt_RSM_statuscomplete,false)
visible(txt_IMU,true)
txt_style(txt_IMU,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_IMU_statusna,true)
visible(txt_IMU_statusinit,false)
visible(txt_IMU_statuscomplete,false)
visible(txt_ADC,true)
txt_style(txt_ADC,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_ADC_statusna,true)
visible(txt_ADC_statusinit,false)
visible(txt_ADC_statuscomplete,false)
visible(txt_ADAHRS,true)
txt_style(txt_ADAHRS,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: grey; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_ADAHRS_statusna,true)
visible(txt_ADAHRS_statusinit,false)
visible(txt_ADAHRS_statuscomplete,false)
timer_start(start1_duration1,nil,timer_callback1)
end
function timer_callback1() -- second page (IOP, ARINC, RS232)
visible(txt_IOP,true)
visible (txt_IOP_statusna,false)
txt_style(txt_IOP,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;")
visible(txt_IOP_statusinit,true) --initializing
visible(txt_IOP_statuscomplete,false)
visible(txt_ARINC,true)
visible (txt_ARINC_statusna,false)
txt_style(txt_ARINC,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;")
visible(txt_ARINC_statusinit,true)
visible(txt_ARINC_statuscomplete,false)
visible(txt_RS232,true)
txt_style(txt_RS232,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_RS232_statusna,false)
visible(txt_RS232_statusinit,true)
visible(txt_RS232_statuscomplete,false)
visible(txt_CFG,true)
visible (txt_CFG_statusna,true)
visible(txt_CFG_statusinit,false)
visible(txt_CFG_statuscomplete,false)
visible(txt_RSM,true)
visible (txt_RSM_statusna,true)
visible(txt_RSM_statusinit,false)
visible(txt_RSM_statuscomplete,false)
visible(txt_IMU,true)
visible (txt_IMU_statusna,true)
visible(txt_IMU_statusinit,false)
visible(txt_IMU_statuscomplete,false)
visible(txt_ADC,true)
visible (txt_ADC_statusna,true)
visible(txt_ADC_statusinit,false)
visible(txt_ADC_statuscomplete,false)
visible(txt_ADAHRS,true)
visible (txt_ADAHRS_statusna,true)
visible(txt_ADAHRS_statusinit,false)
visible(txt_ADAHRS_statuscomplete,false)
timer_start(start1_duration2,nil,timer_callback2)
end
function timer_callback2() -- third page (CFG)
visible(txt_IOP,true)
visible (txt_IOP_statusna,false)
visible(txt_IOP_statusinit,false)
visible(txt_IOP_statuscomplete,true)
visible(txt_ARINC,true)
visible (txt_ARINC_statusna,false)
visible(txt_ARINC_statusinit,false)
visible(txt_ARINC_statuscomplete,true)
visible(txt_RS232,true)
visible (txt_RS232_statusna,false)
visible(txt_RS232_statusinit,false)
visible(txt_RS232_statuscomplete,true)
visible(txt_CFG,true)
txt_style(txt_CFG,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_CFG_statusna,false)
visible(txt_CFG_statusinit,true)
visible(txt_CFG_statuscomplete,false)
visible(txt_RSM,true)
visible (txt_RSM_statusna,true)
visible(txt_RSM_statusinit,false)
visible(txt_RSM_statuscomplete,false)
visible(txt_IMU,true)
visible (txt_IMU_statusna,true)
visible(txt_IMU_statusinit,false)
visible(txt_IMU_statuscomplete,false)
visible(txt_ADC,true)
visible (txt_ADC_statusna,true)
visible(txt_ADC_statusinit,false)
visible(txt_ADC_statuscomplete,false)
visible(txt_ADAHRS,true)
visible (txt_ADAHRS_statusna,true)
visible(txt_ADAHRS_statusinit,false)
visible(txt_ADAHRS_statuscomplete,false)
timer_start(start1_duration3,nil,timer_callback3)
end
function timer_callback3()-- fourth page (RSM)
-- visible(txt_IOP,true)
-- visible (txt_IOP_statusna,true)
-- visible(txt_IOP_statusinit,false)
-- visible(txt_IOP_statuscomplete,false)
-- visible(txt_ARINC,true)
-- visible (txt_ARINC_statusna,true)
-- visible(txt_ARINC_statusinit,false)
-- visible(txt_ARINC_statuscomplete,false)
-- visible(txt_RS232,true)
-- visible (txt_RS232_statusna,true)
-- visible(txt_RS232_statusinit,false)
-- visible(txt_RS232_statuscomplete,false)
-- visible(txt_CFG,true)
visible (txt_CFG_statusna,false)
visible(txt_CFG_statusinit,false)
visible(txt_CFG_statuscomplete,true)
visible(txt_RSM,true)
txt_style(txt_RSM,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_RSM_statusna,false)
visible(txt_RSM_statusinit,true)
visible(txt_RSM_statuscomplete,false)
visible(txt_IMU,true)
visible (txt_IMU_statusna,false)
visible(txt_IMU_statusinit,false)
visible(txt_IMU_statuscomplete,false)
visible(txt_ADC,true)
visible (txt_ADC_statusna,false)
visible(txt_ADC_statusinit,false)
visible(txt_ADC_statuscomplete,false)
visible(txt_ADAHRS,true)
visible (txt_ADAHRS_statusna,false)
visible(txt_ADAHRS_statusinit,false)
visible(txt_ADAHRS_statuscomplete,false)
timer_start(start1_duration4,nil,timer_callback4)
end
function timer_callback4() -- fifth page (ADAHRS)
-- visible(txt_IOP,true)
-- visible (txt_IOP_statusna,true)
-- visible(txt_IOP_statusinit,false)
-- visible(txt_IOP_statuscomplete,false)
-- visible(txt_ARINC,true)
-- visible (txt_ARINC_statusna,true)
-- visible(txt_ARINC_statusinit,false)
-- visible(txt_ARINC_statuscomplete,false)
-- visible(txt_RS232,true)
-- visible (txt_RS232_statusna,true)
-- visible(txt_RS232_statusinit,false)
-- visible(txt_RS232_statuscomplete,false)
-- visible(txt_CFG,true)
-- visible (txt_CFG_statusna,true)
-- visible(txt_CFG_statusinit,false)
-- visible(txt_CFG_statuscomplete,false)
visible(txt_RSM,true)
visible (txt_RSM_statusna,false)
visible(txt_RSM_statusinit,false)
visible(txt_RSM_statuscomplete,true)
visible(txt_IMU,true)
txt_style(txt_IMU,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_IMU_statusna,false)
visible(txt_IMU_statusinit,true)
visible(txt_IMU_statuscomplete,false)
visible(txt_ADC,true)
txt_style(txt_ADC,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_ADC_statusna,false)
visible(txt_ADC_statusinit,true)
visible(txt_ADC_statuscomplete,false)
visible(txt_ADAHRS,true)
txt_style(txt_ADAHRS,"-fx-font-size:24pt; -fx-font-family:Arial; -fx-fill: black; -fx-font-weight:bold; -fx-text-alignment:left;")
visible (txt_ADAHRS_statusna,false)
visible(txt_ADAHRS_statusinit,true)
visible(txt_ADAHRS_statuscomplete,false)
timer_start(start1_duration5,nil,timer_callback5)
end
function timer_callback5() -- sixth page 
visible(img_screenoff,false) -- on enlève l'écran noir
visible(img_startup,true) -- on affiche l'écran de démarrage
visible(img_startup_bkg_blackscreen,false) -- on met l'écran noir de démarrage
visible(img_startup_bkg_white,false) -- on met le fond blanc pour le texte
-- visible(txt_IOP,true)
-- visible (txt_IOP_statusna,false)
-- visible(txt_IOP_statusinit,false)
-- visible(txt_IOP_statuscomplete,true)
-- visible(txt_ARINC,true)
-- visible (txt_ARINC_statusna,false)
-- visible(txt_ARINC_statusinit,false)
-- visible(txt_ARINC_statuscomplete,true)
-- visible(txt_RS232,true)
-- visible (txt_RS232_statusna,false)
-- visible(txt_RS232_statusinit,false)
-- visible(txt_RS232_statuscomplete,true)
-- visible(txt_CFG,true)
-- visible (txt_CFG_statusna,false)
-- visible(txt_CFG_statusinit,false)
-- visible(txt_CFG_statuscomplete,true)
-- visible(txt_RSM,true)
-- visible (txt_RSM_statusna,false)
-- visible(txt_RSM_statusinit,false)
-- visible(txt_RSM_statuscomplete,true)
-- visible(txt_IMU,true)
visible (txt_IMU_statusna,false)
visible(txt_IMU_statusinit,false)
visible(txt_IMU_statuscomplete,true)
visible(txt_ADC,true)
visible (txt_ADC_statusna,false)
visible(txt_ADC_statusinit,false)
visible(txt_ADC_statuscomplete,true)
visible(txt_ADAHRS,true)
visible (txt_ADAHRS_statusna,false)
visible(txt_ADAHRS_statusinit,true)
visible(txt_ADAHRS_statuscomplete,false)
timer_start(start1_duration6,nil,timer_callback6)
end
function timer_callback6() --all tests completed
visible(txt_ADAHRS,true)
visible (txt_ADAHRS_statusna,false)
visible(txt_ADAHRS_statusinit,false)
visible(txt_ADAHRS_statuscomplete,true)
timer_start(start1_duration7,nil,timer_callback7)
end
function timer_callback7() -- diagnostic sequence completed, warming up sequence: VSI, ALT and SPD failed
-- on enlève les textes du startup screen
visible(txt_IOP,false)
visible (txt_IOP_statusna,false)
visible(txt_IOP_statusinit,false)
visible(txt_IOP_statuscomplete,false)
visible(txt_ARINC,false)
visible (txt_ARINC_statusna,false)
visible(txt_ARINC_statusinit,false)
visible(txt_ARINC_statuscomplete,false)
visible(txt_RS232,false)
visible (txt_RS232_statusna,false)
visible(txt_RS232_statusinit,false)
visible(txt_RS232_statuscomplete,false)
visible(txt_CFG,false)
visible (txt_CFG_statusna,false)
visible(txt_CFG_statusinit,false)
visible(txt_CFG_statuscomplete,false)
visible(txt_RSM,false)
visible (txt_RSM_statusna,false)
visible(txt_RSM_statusinit,false)
visible(txt_RSM_statuscomplete,false)
visible(txt_IMU,false)
visible (txt_IMU_statusna,false)
visible(txt_IMU_statusinit,false)
visible(txt_IMU_statuscomplete,false)
visible(txt_ADC,false)
visible (txt_ADC_statusna,false)
visible(txt_ADC_statusinit,false)
visible(txt_ADC_statuscomplete,false)
visible(txt_ADAHRS,false)
visible (txt_ADAHRS_statusna,false)
visible(txt_ADAHRS_statusinit,false)
visible(txt_ADAHRS_statuscomplete,false)
-- on enlève le startup screen, l'instrument s'affiche
visible(img_startup,false)
-- on enleve les tapes
display_tapes(false) 
-- on enlève les ALT et SPEED Boxes
visible(img_upperspeedbox,false)
visible(img_upperaltbox,false)
visible(img_apaltbox,false)
visible(txt_apspd1,false)
visible(txt_apspd2,false)
visible(txt_apalt1,false)
visible(txt_apalt2,false)
-- on enleve l'affichage du VSI 
visible(txt_vsi,false) 
visible(txt_vsi2,false)
-- affichage des flags d'erreur IAS, VSI et ALT
visible(img_IAS_fail,true)
visible(img_ALT_fail,true)
visible(img_VSI_fail,true)
timer_start(start1_duration8,nil,timer_callback8)
end
function timer_callback8() -- bringing back everything to view, startup sequence complete
display_tapes(true)
visible(img_upperspeedbox,true)
visible(img_upperaltbox,true)
visible(img_apaltbox,false)
visible(txt_apspd1,true)
visible(txt_apspd2,true)
visible(txt_apalt1,true)
visible(txt_apalt2,true)
visible(txt_vsi,true)
visible(txt_vsi2,true)
-- flags d'erreur IAS, VSI et ALT
visible(img_IAS_fail,false)
visible(img_ALT_fail,false)
visible(img_VSI_fail,false)
off_state=false
end

function startup_sequence()
if off_state==true then
	display_startup()
end
end
------------ Shutdown sequence -----------------
function timer_callback01() -- shutdown phase 2
visible(img_screenoff,true)
visible(img_shutdown1,false)
visible(txt_shutdown_countdown,false)
visible(img_shutdown2,true)
timer_start(shutdown_duration2,nil,timer_callback02)
end
function timer_callback02() -- black screen (end of shutdown sequence)
--timer_stop(tmr_countdown)
visible(img_screenoff,true)
visible(img_shutdown1,false)
visible(txt_shutdown_countdown,false)
visible(img_shutdown2,false)
off_state = true
end

function timer_countdown01()
-- if buttonpressed==false then
	if count>=0 then 
		txt_set(txt_shutdown_countdown,count)
		count=count-1
	else
		timer_stop(tmr_countdown)
	end
-- else 
	-- timer_stop(tmr_countdown)
	-- timer_stop(tmr_shutdown)
-- end
end
function display_shutdown()
if off_state==false then
	visible(img_screenoff,false)
	visible(img_shutdown1,true)-- shutdown phase 1
	visible(txt_shutdown_countdown,true)
	count=countdown_duration/1000 -- nombre de secondes du compte à rebours
	tmr_countdown=timer_start(0,1000,timer_countdown01)-- décompte toutes les secondes
	timer_shutdown=timer_start(countdown_duration,nil,timer_callback01)
	end
end

function shutdown_sequence()
if off_state==false then
	display_shutdown()
end
end
-----------------------------------------

------ Altitude, speed and radar altimeter --
function new_altitudeorspeed(radalt, decisionheight, altitude, airspeed, altbug)
	img_visible(img_headind,false)
	img_visible(img_headindblue,true)
-- VNO, VNE and all speedbars
	y_yellow = ((airspeed - vno) * 6.6) - 3000+381 -- -taille image + position en Y en bas (niveau horizon)
	--y_yellow = var_cap(y_yellow, -469, 42)
	if vno > 0 then
		move(img_spdyellow,nil,y_yellow,nil,nil)
	else
		visible(img_spdyellow,false)--(move(img_spdyellow,nil,-469,nil,nil)
	end

	y_red = ((airspeed - vne) * 6.6) - 3000+381 -- -taille image + position en Y en bas
	--y_red = var_cap(y_red, -469, 42)
	if vne > 0 then
		move(img_spdred,nil,y_red,nil,nil)
		move(img_spdred_dash,nil,y_red+3000-4,nil,nil)
	else
		visible(img_spdred,false)-- move(img_spdred,nil,-469,nil,nil)
		visible(img_spdred_dash,false)
	end
	
	y_green = ((airspeed - vfe) * 6.6) - 3000+381 -- -taille image + position en Y en bas
	--y_green = var_cap(y_green, -469, 42)
	if vfe > 0 then
		move(img_spdgreen,nil,y_green,nil,nil)
	else
		visible(img_spdgreen,false)-- move(img_spdgreen,nil,-469,nil,nil)
	end	
	
	y_white1= ((airspeed - vs) * 6.6) - 3000+381 -- -taille image + position en Y en bas
	--y_white1 = var_cap(y_white1, -469, 42)
	if vs > 0 then
		move(img_spdwhite1,nil,y_white1,nil,nil)
	else
		visible(img_spdwhite1,false)--move(img_spdwhite1,nil,-469,nil,nil)
	end	
	
	y_white0= ((airspeed - vs0) * 6.6) - 3000+381 -- -taille image + position en Y en bas
	--y_white1 = var_cap(y_white1, -469, 42)
	if vs0 > 0 then
		move(img_spdwhite0,nil,y_white0,nil,nil)
	else
		visible(img_spdwhite0,false) --move(img_spdwhite0,nil,-469,nil,nil)
	end	
	
	y_red_low = ((airspeed - 0) * 6.6) - 3000+381 -- -taille image + position en Y en bas
	--y_white1 = var_cap(y_white1, -469, 42)
	if vs0 > 0 then
		move(img_spdred_low,nil,y_red_low,nil,nil)
	else
		visible(img_spdred_low,false)--move(img_spdred,nil,-469,nil,nil)
	end	
	
-- Speed indicator running image
	airspeed = var_cap(airspeed, 0, 450) -- max speeds displayed

yspeed = (airspeed * 6.6) + 450--383  
--   yspeed = var_cap(yspeed, 302, 604)
-- if airspeed<=30 then -- speed tape is freezed

   -- running_txt_move_carot(running_text_speed, -2) -- affichage bloqué à 20 kts (indice 2)
   -- running_img_move_carot(running_img_speed_norm, 5) -- affichage bloqué au premier trait
	-- viewport_rect(running_text_speed,0,52,95,302) -- on affiche que la partie supérieure du ruban
--	viewport_rect(running_text_speed,0,52,95,302) -- on affiche que la partie supérieure du ruban
	-- viewport_rect(running_img_speed_norm,72,52,34,302)
	-- viewport_rect(running_img_speed_norm,80,52,200,302)
-- viewport_rect(running_img_speed_norm,72,52,100,606)
-- else
if airspeed >= 450 then --speed tape is freezed
    visible(img_spdreddash,true)
	viewport_rect(running_text_speed,0,52,95,602)
--	running_txt_move_carot(running_text_speed, -45) -- affichage bloqué à 450 kts max (indice 45)
--    running_img_move_carot(running_img_speed_norm, 45) -- affichage bloqué au dernier trait
--viewport_rect(running_text_speed,0,302,95,302)
--	viewport_rect(running_text_speed,nil,nil,nil,604)
--viewport_rect(running_img_speed_norm,72,52+302,34,302)

	-- yspeed = 300 + (airspeed * 6.6)
    -- yspeed = var_cap(yspeed, 300, 511)

----- fin section inutile?
	--running_txt_viewport_rect(running_text_speed,0,52+302,95,302) -- on affiche que la partie inférieure
	--running_img_viewport_rect(running_img_speed_norm,72,52+604,34,302)
else -- "displayable" speed
	visible(img_spdreddash,false)
	running_txt_move_carot(running_text_speed, (airspeed / 10) * -1)
    running_img_move_carot(running_img_speed_norm, (airspeed / 10) * -1)

--running_txt_viewport_rect(running_text_speed,0,52,95,yspeed)
viewport_rect(running_text_speed,0,52,95,yspeed)
--running_img_viewport_rect(running_img_speed_norm,72,52,34,yspeed)
end
--running_img_
viewport_rect(running_img_speed_norm,72,52,50,yspeed-100)

	
-- Speed indicator running text (drum)
if airspeed >vs0 and airspeed < vne then -- affichage de la vitesse en blanc
overspeed=false
visible(running_text_inner_speed_minor_id_red,false)
visible(running_text_inner_speed_minor_id,true)
visible(running_text_inner_speed_major_id_red,false)
visible(running_text_inner_speed_major_id,true)
running_text_inner_speed_minor_displayed=running_text_inner_speed_minor_id
running_text_inner_speed_major_displayed=running_text_inner_speed_major_id
else -- affichage de la vitesse en rouge
overspeed=true
visible(running_text_inner_speed_minor_id_red,true)
visible(running_text_inner_speed_minor_id,false)
visible(running_text_inner_speed_major_id_red,true)
visible(running_text_inner_speed_major_id,false)
running_text_inner_speed_minor_displayed=running_text_inner_speed_minor_id_red
running_text_inner_speed_major_displayed=running_text_inner_speed_major_id_red
end

if airspeed<=20 then 
running_txt_move_carot(running_text_inner_speed_minor_displayed, 0) -- display freezed
running_txt_move_carot(running_text_inner_speed_major_displayed, 0) -- display freezed
else
	running_txt_move_carot(running_text_inner_speed_minor_displayed, (airspeed / 1) * -1)
    if airspeed % 10 > 9 then
    	running_txt_move_carot(running_text_inner_speed_major_displayed, ( airspeed - 9 - (math.floor(airspeed / 10) * 9) ) * -1 )
    else
    	running_txt_move_carot(running_text_inner_speed_major_displayed, math.floor(airspeed / 10) * -1)
    end
end -- if airspeed<=20
-----------------------------------------
--Altitude indicator running image
	altitudecap = var_cap(altitude, -1600, 51000) -- maximum displayed altitude

	running_txt_move_carot(running_text_alt, (altitudecap / 100) * -1)
    running_img_move_carot(running_img_alt, (altitudecap / 100) * -1)
	
	yalt = 900 + (altitudecap * 1.16)
	--yalt = var_cap(yaltcap, 300, 2000)
	
	--running_txt_viewport_rect(running_text_alt,663,42,137,yalt)
	--running_img_viewport_rect(running_img_alt,663,42,137,yalt)
--	running_txt_viewport_rect(running_text_alt,630,42,200,yalt)
--	running_img_viewport_rect(running_img_alt,630,42,200,yalt)
if altitude>=51000 then -- maximum displayed altitude
--visible(img_altreddash,true)
running_txt_viewport_rect(running_text_alt,630,42+302,250,295)
viewport_rect(running_img_alt,630,42+302+23,200,272)
else
--visible(img_altreddash,false)
running_txt_viewport_rect(running_text_alt,630,42,250,615)
viewport_rect(running_img_alt,630,42,200,615)
end
--Altitude indicator running text
	running_txt_move_carot(running_text_inner_alt_minor_id, (altitude / 10) * -1)
	
	
    -- running_txt_move_carot(running_text_inner_alt_major100_id, ( math.floor(altitude / 100) * -1 ))
	-- running_txt_move_carot(running_text_inner_alt_major1000_id, math.floor( altitude / 1000 ) * -1)
	
	
	if altitude % 100 > 90 then
    	running_txt_move_carot(running_text_inner_alt_major100_id, ( altitude - 90 - (math.floor(altitude / 100) * 90) ) * -0.1 )
    else
    	running_txt_move_carot(running_text_inner_alt_major100_id, math.floor(altitude / 100) * -1)
    end
	
	if (altitude % 1000) > 990 then
	 	running_txt_move_carot(running_text_inner_alt_major1000_id, (( altitude - 990 - (math.floor(altitude / 1000) * 990) ) * -0.1))
    else
    	running_txt_move_carot(running_text_inner_alt_major1000_id, math.floor( altitude / 1000 ) * -1)
    end
	
-- Autopilot altitude bug
	y_altbug = ((altbug - altitude) * -1.16) + 350
	y_altbug = var_cap(y_altbug, -8, 1000)
	if altbug > 0 then
		move(img_altbug_blue,nil,y_altbug,nil,nil)
		move(img_altbug_magenta,nil,y_altbug,nil,nil)
	else
		move(img_altbug_blue,nil,-8,nil,nil)
		move(img_altbug_magenta,nil,-8,nil,nil)
	end

-- altbox displayed if within +/-25ft and +/-200ft of captured alt
	if altbug > 0 then
	 altdelta=altbug - altitude
	if  altdelta<= 200 and altdelta >= 25 then
		visible(img_apaltbox, true)
		else if altdelta >= -200 and altdelta <=-25 then 
		visible(img_apaltbox, true)
		else
		visible(img_apaltbox, false)
		end
	end
end
-- Warning sound altitude captured
	if (altbug > 0) and (altdelta <= 200) and (altdelta >= -200) then
		
			if altwarning == false then
				sound_play(snd_apaltwarning)
			end
			
			altwarning = true
		else
			altwarning = false
		end
 
-- Decision height indicator at 10 feet and below
		visible(img_decisionheight, (decisionheight > 0) and (radalt < (decisionheight + 10)) )
		if (decisionheight > 0) and (radalt < (decisionheight + 10)) then
		
			if decisionheightwarning == false then
				sound_play(snd_dhwarning)
			end
			
			decisionheightwarning = true
		else
			decisionheightwarning = false
		end
end

function new_altitudeorspeed_fsx(radalt, altitude, airspeed, altbug)

	new_altitudeorspeed(radalt, 0, altitude, airspeed, altbug)
--function new_altitudeorspeed(radalt, dh, altitude, airspeed, altbug)	
end

------------------- Attitude indicator -------------------------------
function new_attitude(roll, pitch, slip)    

-- Roll outer ring (roll)
	rollind = var_cap(roll, -60, 60)
    img_rotate(img_roll, rollind * -1)
        
-- Roll horizon
   img_rotate(img_horizon, roll * -1)
   img_rotate(img_horizonscale, roll * -1)
    
-- Move horizon pitch
    radial = math.rad(roll * -1)
    pitchscale = var_cap(pitch,-90,90)
    pitchhoriz = var_cap(pitch,-20,20) -- on limite l'affichage de l'horizon pour laisser un bout de ciel ou de terre aux grandes incidences
    xhoriz = -(math.sin(radial) * pitchhoriz * 14)
    yhoriz = (math.cos(radial) * pitchhoriz * 14)
	xhscale = -(math.sin(radial) * pitchscale * 14)
    yhscale = (math.cos(radial) * pitchscale * 14)
    img_move(img_horizon, xhoriz - (2000-800)/2, yhoriz- (1522-154), nil, nil)
    img_move(img_horizonscale, xhscale - (2000-800)/2, yhscale  - (1522-154), nil, nil) 
  
-- Move slip ball
	slip = var_cap(slip * 2,-30,30)
    img_move(img_slip, 400-19 - slip, nil, nil, nil)
	
end

function new_attitude_fsx(roll, pitch, slip)
	
	new_attitude(roll *-1, pitch * -1, slip * -1)

end
-- Autopilot flight director --
function new_flight_director(state, fdpitch, fdroll,pitch,roll) --pitch and roll indegrees
-- Flight director visible
if state ==	1 then
visible(img_flightdirector, true)

img_rotate(img_flightdirector, (fdroll)*-1)
-- Flight director pitch and roll
	pitchind = fdpitch-pitch-- var_cap(pitch,-25,25)
	rollind = fdroll--var_cap(roll,-45,45)
--print("pitch:",pitchind)
	rad_roll = math.rad(rollind*-1)
	rad_pitch = math.rad(pitchind)
	x = -(math.sin(rad_pitch) * pitchind * 14)
	y = (math.cos(rad_pitch) * pitchind*14) --1412.7
--	print(y)
--	img_move(img_flightdirector, (x * -1) + 222, (y * -1) + 1522-1139, nil, nil)--img_move(img_flightdirector, (x * -1) + 222, (y * -1) + 321, nil, nil)
--	img_move(img_flightdirector, 222, (y * -1)+382, nil, nil)--img_move(img_flightdirector, (x * -1) + 222, (y * -1) + 321, nil, nil)
img_move(img_flightdirector, 222, y+383, nil, nil)--img_move(img_flightdirector, (x * -1) + 222, (y * -1) + 321, nil, nil)
	--print(rollind.."°")
  --print(rad_roll.."rad")

else 
 visible(img_flightdirector, false)
end
end

function new_flight_director_fsx(state, fdpitch,fdroll,pitch, roll) --pitch and roll in radians
-- pitch=math.deg(pitch*-1)
-- roll=math.deg(roll)
if state==true then 
new_flight_director(1,fdpitch,fdroll, pitch, roll)
else
new_flight_director(0, fdpitch,fdroll, pitch, roll)
end
end
---------------------------------------------------------------
-- Information bar top --
function new_infobartop(apspeed, apalt, airspeed)
	img_visible(img_headind,false)
	img_visible(img_headindblue,true)
-- Autopilot airspeed setting
txt_style(txt_apspd1,"-fx-font-size:44px; -fx-font-family:Arial; -fx-fill: magenta; -fx-font-weight:bold; -fx-text-alignment:left;")
txt_style(txt_apspd2,"-fx-font-size:32px; -fx-font-family:Arial; -fx-fill: magenta; -fx-font-weight:bold; -fx-text-alignment:left;")
--apspeedcap = var_cap(apspeed, 20, 450)
	if apspeed >= 20 and apspeed <=450 then
		txt_set(txt_apspd1, apspeed)
		txt_set(txt_apspd2, "kt")
		visible(img_speedbug_blue,true)
		visible(img_speedbug_magenta,true)
		if apspeed >= 100 then
			txt_move(txt_apspd2,93,nil,nil,nil)
		else
			txt_move(txt_apspd2,68,nil,nil,nil)
		end
	else
		txt_set(txt_apspd1, "---")
		txt_set(txt_apspd2, " ")
		visible(img_speedbug_blue,false)
		visible(img_speedbug_magenta,false)
		end
-- Autopilot airspeed bug
	y_speedbug = ((apspeed - airspeed) * -6.6) + 383-30--350
	-- y_speedbug = var_cap(y_speedbug, -8, 1000)
	if apspeed > 30 then
		move(img_speedbug_blue,nil,y_speedbug,nil,nil)
		move(img_speedbug_magenta,nil,y_speedbug,nil,nil)
	else
		move(img_speedbug_blue,nil,-8,nil,nil)
		move(img_speedbug_magenta,nil,-8,nil,nil)
	end
	
-- Autopilot altitude setting
txt_style(txt_apalt1,"-fx-font-size:44px; -fx-font-family:Arial; -fx-fill: magenta; -fx-font-weight:bold; -fx-text-alignment:right;")
txt_style(txt_apalt2,"-fx-font-size:38px; -fx-font-family:Arial; -fx-fill: magenta; -fx-font-weight:bold; -fx-text-alignment:right;")
apaltcap = var_cap(apalt, 100, 51000)
	if apalt==0 then
		txt_set(txt_apalt1, "")
		txt_set(txt_apalt2, "")
	elseif apalt >= 1000 then
		txt_set(txt_apalt1, string.format("%3d",(apaltcap/1000)))
		txt_set(txt_apalt2, string.format("%03d",apaltcap%1000))
	else
		txt_set(txt_apalt1, "")
		txt_set(txt_apalt2, string.format("%03d",apaltcap%1000))
	end
end -- function


-- Information bar center --
function new_infobarcenter(tas, gs, oat, winddir, windspd, heading, inhg)
	img_visible(img_headind,false)
	img_visible(img_headindblue,true)
-- True airspeed and ground speed
if tas==0 then
	txt_set(txt_tas, "---")
	txt_set(txt_gs, "---")
else
	txt_set(txt_tas, var_round(tas * 1.94384449, 0))
	txt_set(txt_gs, var_round(gs * 1.94384449, 0))
end	
-- Outside air temperature
	txt_set(txt_oat, var_round(oat, 0) .. "\°c")
	
-- Wind direction and speed
if tas>10 then --if speed >10kts wind is displayed
	visible(txt_wind,true)
	txt_set(txt_wind, var_round(winddir, 0) .. "\°/" .. var_round(windspd, 0) .. " kt")
	visible(img_windarrow,true)
	img_rotate(img_windarrow, (winddir + 180) - heading)
else
	visible(txt_wind,false)
	visible(img_windarrow,false)
end

-- Barometric setting
--on passe le texte en magenta
txt_style(txt_inhg,"-fx-font-size:40px; -fx-font-family:Arial; -fx-fill: magenta; -fx-font-weight:bold; -fx-text-alignment:right;")
txt_style(txt_inhg_unit,"-fx-font-size:24px; -fx-font-family:Arial; -fx-fill: magenta; -fx-font-weight:bold; -fx-text-alignment:right;")
if baro_unit=="Millibars" then
	txt_set(txt_inhg, var_round(inhg * 33.8639, 0)) -- affichage en millibars
else 
	txt_set(txt_inhg, var_format(inhg, 2)) -- affichage en InHg
end
end

				   
-- Heading and turnrate indicator --
function new_heading(elecheading, turnrate)

-- Rotate compass
	img_rotate(img_compasrose, elecheading * -1)
	txt_set(txt_compheading, string.format("%03d" .. "\°", math.floor(elecheading) ))
	running_txt_move_carot(compass_inner_txt_id, (elecheading / 30) + 6)
    running_txt_move_carot(compass_inner_txt_id2, (elecheading / 30) + 6)
-- Turn indicator
	
	--dispturnrate = var_cap(turnrate, -20, 20)
	
	angturnrate=turnrate*8/3
	--print(turnrate)
	--print(angturnrate.."***")
	if turnrate > 0 then
		img_rotate(img_turnright, angturnrate-8)
		--img_rotate(img_turnright, dispturnrate - 10)
	else
		img_rotate(img_turnright, 0)
	end
	
	if turnrate < 0 then
		img_rotate(img_turnleft, angturnrate+8)
		--img_rotate(img_turnleft, dispturnrate + 10)
	else
		img_rotate(img_turnleft, 8)
	end
	
end

function new_heading_FSX(elecheading, turnrate)

	new_heading(elecheading, turnrate )--* -40
	
end

-- Vertical speed indicator --
function new_vsi(vs)
	
	if vs <= 999 and vs >= -999 then
		vsi = var_round(vs / 10, 0) * 10
	elseif vs > 999 or vs < -999 then
		vsi = var_round(vs / 100, 0) * 100
	end

	if vs >= 10 then
		txt_set(txt_vsi, "+" .. vsi)
		txt_set(txt_vsi2,"FPM")
	elseif vs <= -10 then
		txt_set(txt_vsi, vsi)
		txt_set(txt_vsi2,"FPM")
	else
		txt_set(txt_vsi, " ")
		txt_set(txt_vsi2,"")
	end
	
end

-- Direction indicator (Credits go to macnfly for this code)
function new_HSI(xhsimode, xrmi1mode, xrmi2mode, nav1name, nav1freq, nav1obs, nav1hasnav, nav1flag, nav1hasloc, nav1hdef, nav1hasgs, nav1gsflag, nav1vdef, nav1bearing, nav1dme, nav1speed, nav2name, nav2freq, nav2obs, nav2hasnav, nav2flag, nav2hasloc, nav2hdef, nav2hasgs, nav2gsflag, nav2vdef, nav2bearing, nav2dme, nav2speed, gpsbearing, gpswptname, gpswptbearing, gpswptdme, gpswptete, apheading, elecheading, groundtrack)
   

img_rotate(img_rose, -elecheading) -- rotate the compas rose
      --	bug de cap...\\--
img_visible(img_headind,false)
img_visible(img_headindblue,true) 
img_rotate(img_headind, (apheading-elecheading))
	
img_rotate(img_headindblue, (apheading-elecheading))
img_rotate(img_trueh, (groundtrack-elecheading))
	


-- HSI display
if hsimode == 0 then -- source is VOR1
	hdef=nav1hdef 
	vdef=nav1vdef
    hsihassignal=nav1hasnav
	hsiwptfreq=nav1freq
	hsiwptname=nav1name
	hsiflag=nav1flag
	hsiwptbearing=nav1bearing
	hsiwptdme=nav1dme
	hsiwptspeed=nav1speed
	if nav1hasloc then
		txt_cdi_source="LOC1"
	elseif nav1hasgs then
		txt_cdi_source="ILS1"
	else
		txt_cdi_source="VOR1"
	end
	if nav1speed>0 then 
		hsiwptETA=nav1dme/nav1speed
		else
		hsiwptETA=0
		end
	crs=nav1obs
end
if hsimode == 1 then --source is VOR2
 	hdef=nav2hdef 
	vdef=nav2vdef
    hsihassignal=nav2hasnav
	hsiwptfreq=nav2freq
	hsiwptname=nav2name
	hsiflag=nav2flag
	hsiwptbearing=nav2bearing
	hsiwptdme=nav2dme
	hsiwptspeed=nav2speed
	if nav2hasloc then
		txt_cdi_source="LOC2"
	elseif nav2hasgs then
		txt_cdi_source="ILS2"
	else
		txt_cdi_source="VOR2"
	end
	if nav2speed>0 then
		hsiwptETA=nav2dme/nav2speed
		else
		hsiwptETA=0
		end
	crs=nav2obs
end
 if hsimode == 2 then --source is GPS
	txt_cdi_source="GPS1"
 	hdef=gpshdef 
	vdef=gpshdef
    hsihassignal=true
	hsiwptfreq=0
	hsiwptname=gpswptname
	hsiflag=1 -- always TO in GPS mode
	hsiwptbearing=gpswptbearing
	hsiwptdme=gpswptdme
	hsiwptspeed=25.0
	hsiwptETA=gpswptete
	crs=gpsbearing
    end

hdef = var_cap(hdef, -5, 5)
vdef = var_cap(vdef, -2, 2)	
if 	hsihassignal==false then -- no data available, the needle is not displayed
    img_visible(img_to_flag,false)
	img_visible(img_from_flag,false)
	img_visible(img_center_needle_to, false)
	img_visible(img_center_needle_from, false)
	img_visible(img_center_needlehollow_to, false)
	img_visible(img_center_needlehollow_from, false)
	elseif hsiflag==1 then  --TO flag
    img_visible(img_to_flag,true)
	img_visible(img_from_flag,false)
	if (hdef<=-5 or hdef>=5) then -- CDI off limits, (hollow needle is displayed)
		img_visible(img_center_needle_to, false)
		img_visible(img_center_needle_from, false)
		img_visible(img_center_needlehollow_to, true)
		img_visible(img_center_needlehollow_from, false)
	else
		img_visible(img_center_needle_to, true)
		img_visible(img_center_needle_from, false)
		img_visible(img_center_needlehollow_to, false)
		img_visible(img_center_needlehollow_from, false)
	end
	
 	else -- FROM flag
    img_visible(img_to_flag,false)
	img_visible(img_from_flag,true)
    if (hdef<=-5 or hdef>=5) then
		img_visible(img_center_needle_to, false)
		img_visible(img_center_needle_from, false)
		img_visible(img_center_needlehollow_to, false)
		img_visible(img_center_needlehollow_from, true)
	else
		img_visible(img_center_needle_to, false)
		img_visible(img_center_needle_from, true)
		img_visible(img_center_needlehollow_to, false)
		img_visible(img_center_needlehollow_from, false)
	end
end --if 	nav1flag==0

-- rotate the CDI needle(including the hollow one), and the to/from flag	  
img_rotate(img_needle, crs-elecheading)
img_rotate(img_to_flag, crs-elecheading)
img_rotate(img_from_flag, crs-elecheading)
img_rotate(img_center_needle_to, crs-elecheading)
img_rotate(img_center_needle_from, crs-elecheading)
img_rotate(img_center_needlehollow_to, crs-elecheading)
img_rotate(img_center_needlehollow_from, crs-elecheading)
	

dh = hdef* 30.79* math.cos((-elecheading+crs)*math.pi/180) --(246.3+30.8+30.8)/10)=30.79
dv = hdef* 30.79* math.sin((-elecheading+crs)*math.pi/180) --(246.3+30.8+30.8)/10)=30.79
--dm = nav1vdef*54
flagh =  math.cos((-elecheading+crs)*math.pi/180)
flagv = math.sin((-elecheading+crs)*math.pi/180)
-- print("nav1hdef-->"..nav1hdef)
-- print("dh-->"..dh)
-- print("dv-->"..dv)
	img_move(img_to_flag, flagh + 400-(549.4/2), flagv + 1139-(549.4/2), nil, nil)--flagh + 400-(29/2), flagv + 1139-(300/2), nil, nil)
  	img_move(img_from_flag, flagh + 400-(549.4/2), flagv + 1139-(549.4/2), nil, nil)
	img_move(img_center_needle_to, dh + 400-(549.4/2), dv + 1139-(549.4/2), nil, nil)--dh + 400-(26.5/2), dv + 1139-(251.6/2), nil, nil)
	img_move(img_center_needle_from, dh + 400-(549.4/2), dv + 1139-(549.4/2), nil, nil)--dh + 400-(26.5/2), dv + 1139-(251.6/2), nil, nil)
	img_move(img_center_needlehollow_to, dh + 400-(549.4/2), dv + 1139-(549.4/2), nil, nil)--dh + 400-(13.17/2), dv + 1139-(251.6/2), nil, nil)
	img_move(img_center_needlehollow_from, dh + 400-(549.4/2), dv + 1139-(549.4/2), nil, nil)--dh + 400-(13.17/2), dv + 1139-(251.6/2), nil, nil)

   -- if nav1display > 0 or nav2display > 0 or mode == 2 then
        -- img_visible(img_center_needle, true)
    -- else
        -- img_visible(img_center_needle, false)
    -- end
   
	-- Source mode selected for HSI
if hsimode == 0 then --VOR1
		txt_set(txt_CDI_source,txt_cdi_source )
		txt_set(txt_centerbutton, "VLOC1")
		txt_set(txt_CDI_wptid,var_format(var_round(hsiwptfreq,2),2).."MHz")
	elseif hsimode == 1 then
		txt_set(txt_CDI_source, txt_cdi_source)
		txt_set(txt_centerbutton, "VLOC2")
		txt_set(txt_CDI_wptid,var_format(var_round(hsiwptfreq,2),2).."MHz")
	elseif hsimode == 2 then
		txt_set(txt_CDI_source, txt_cdi_source)
		txt_set(txt_centerbutton, "GPS1")
		txt_set(txt_CDI_wptid,hsiwptname)
end	
		
if hsihassignal == true then
			visible(img_redslash_centerbutton,false)
			visible(txt_CDI_wptid,true)
			visible(txt_CDI_wptbearingdist,true)
			visible(txt_CDI_wptETA,true)
			if hsiwptdme>99 then
				dmeformat=string.format("%04d" .. "\°", (hsiwptbearing)%360).."/"..var_round(hsiwptdme,0) 
			else 
				dmeformat=string.format("%03d" .. "\°", (hsiwptbearing)%360).."/"..var_format(hsiwptdme,1)
			end
			txt_set(txt_CDI_wptbearingdist,dmeformat)--
			if  hsiwptspeed>20 then --
				hsiwptETA_Hour,hsiwptETA_Min=math.modf(hsiwptETA)
				txt_set(txt_CDI_wptETA,hsiwptETA_Hour..":"..string.format("%02d",hsiwptETA_Min*60))
			end
		else
			visible(txt_CDI_wptid,false)
			visible(txt_CDI_wptbearingdist,false)
			visible(txt_CDI_wptETA,false)
			visible(img_redslash_centerbutton,true)-- on flagge l'indicateur
		end
		
if rmi1mode ==1 then -- VOR1
	txt_set(txt_leftbutton,"VOR1")
	visible(img_rmi1needleblue,true)
	rmi1ident=nav1freq.."MHz"
	rmi1dme=nav1dme
	rmi1hassignal=nav1hasnav
	rmi1_flagged=not(nav1hasnav)
	rmi1bearing=(nav1bearing)%360
elseif rmi1mode ==2 then -- VOR2
	txt_set(txt_leftbutton,"VOR2")
	visible(img_rmi1needleblue,true)
	rmi1ident=nav2freq.."MHz"
	rmi1dme=nav2dme
	rmi1hassignal=nav2hasnav
	rmi1_flagged=not(nav2hasnav)
	rmi1bearing=(nav2bearing)%360
else --GSP1 ou rien, on affiche rien
	txt_set(txt_leftbutton,"")
	visible(img_rmi1needleblue,false)
	rmi1ident=""-- nav1freq.."MHz"
	rmi1dme=0
	rmi1hassignal=false
	rmi1_flagged=false
	rmi1bearing=0--(nav1bearing+180)%180

end
----- pas de RMI2 pour l'instant!!!!!!!!!!!!!!!!!
	visible(img_rmi2needleblue,false)
	rmi2ident=""-- nav1freq.."MHz"
	rmi2dme=0
	rmi2hassignal=false
	rmi2_flagged=false
	rmi2bearing=(nav2bearing)%360
	
img_rotate(img_rmi1needleblue, nav1bearing-elecheading)
img_rotate(img_rmi2needleblue, nav2bearing-elecheading)		
if rmi1hassignal == true then
			visible(img_redslash_leftbutton,false)
			visible(txt_RMI1_wptid,true)
			visible(txt_RMI1_wptbearingdist,true)
			if rmi1dme>99 then
				dmeformat=var_round(rmi1dme,0).."Nm"
			else 
				dmeformat=var_format(rmi1dme,1).."Nm"
			end
			visible(img_rmi1needleblue,true)
		else
			visible(txt_RMI1_wptid,true)
			visible(txt_RMI1_wptbearingdist,false)
			visible(img_redslash_leftbutton,rmi1_flagged)-- on flagge l'indicateur
			visible(img_rmi1needleblue,false) -- on cache l'aiguille
		end
txt_set(txt_RMI1_wptbearingdist,dmeformat)
txt_set(txt_RMI1_wptid,rmi1ident)
if rmi2hassignal == true then
			visible(img_redslash_rightbutton,false)
			visible(txt_RMI2_wptid,true)
			visible(txt_RMI2_wptbearingdist,true)
			if rmi2dme>99 then
				dmeformat=var_round(rmi2dme,0).."Nm"-- on force sans virgule
			else 
				dmeformat=var_format(rmi2dme,1).."Nm"
			end

			visible(img_rmi2needleblue,true)
		else
			visible(txt_RMI2_wptid,true)
			visible(txt_RMI2_wptbearingdist,false)
			visible(img_redslash_rightbutton,rmi2_flagged)-- on flagge l'indicateur
			visible(img_rmi2needleblue,false) -- on cache l'aiguille
		end	
txt_set(txt_RMI2_wptbearingdist,dmeformat)
txt_set(txt_RMI2_wptid,rmi2ident)
	-- else
		-- txt_set(txt_CDI_source, " ")
		-- visible(txt_CDI_wptid,false)
		-- visible(txt_CDI_wptbearingdist,false)
		-- visible(txt_CDI_wptETA,false)
		-- txt_set(txt_centerbutton, " ")
	-- end
		--// Course text \\--
	txt_style(txt_course,"-fx-font-size:42px; -fx-font-family:Arial; -fx-fill: magenta; -fx-font-weight:bolder; -fx-text-alignment:left;")
	txt_set(txt_course, string.format("%03d" .. "\°", crs) )
	--// Heading text, AP heading dialled in  
	txt_style(txt_hdg,"-fx-font-size:42px; -fx-font-family:Arial; -fx-fill: magenta; -fx-font-weight:bolder; -fx-text-alignment:left;")
	txt_set(txt_hdg, string.format("%03d" .. "\°", apheading) )
end

function new_HSI_FSX(nav1name, nav1freq, nav1obs, nav1hasnav, nav1flag, nav1hasloc, nav1hdef, nav1hasgs, nav1gsflag, nav1vdef, nav1bearing, nav1dme, nav1speed,nav2name, nav2freq, nav2obs, nav2hasnav, nav2flag, nav2hasloc, nav2hdef, nav2hasgs, nav2gsflag, nav2vdef, nav2bearing, nav2dme, nav2speed, gpsbearing, gpswptname, gpswptbearing, gpswptdme, gpswptete, apheading, elecheading, groundtrack)

	verticaldeviation = 4 / 119 --* nav1vdef -- value returned by fs is +/- 119
	horizontaldeviation = 5 /127 -- * nv1hdef   -- value returned by fs is +/- 127
	nav1bearing=(nav1bearing+180)%360
	nav2bearing=(nav2bearing+180)%360
	gpswptbearing=(gpswptbearing+180)%360
	xhsimode=hsimode
	new_HSI(xhsimode, 0, 0, nav1name, nav1freq, nav1obs, nav1hasnav, nav1flag, nav1hasloc, nav1hdef*horizontaldeviation, nav1hasgs, nav1gsflag, nav1vdef, nav1bearing, nav1dme, nav1speed,nav2name, nav2freq, nav2obs, nav2hasnav, nav2flag, nav2hasloc, nav2hdef*horizontaldeviation, nav2hasgs, nav2gsflag, nav2vdef, nav2bearing, nav2dme, nav2speed, gpsbearing, gpswptname, gpswptbearing, gpswptdme, gpswptete, apheading, elecheading, groundtrack)
	
end

-----------------------------------------------------------
-- intercommunication with bezel gauge Buttons and dials --
-----------------------------------------------------------

-- Button REV (ON/OFF)
function new_latbuttonrevstate(latbuttonrevstate)
--print(latbuttonrevstate)
buttonpressed=true
if latbuttonrevstate==1 then
	if off_state== false then -- lance la procédure d'arrêt
		shutdown_sequence()
		--off_state = true
		else -- lance le démarrage
		startup_sequence()
		--off_state = false
		end
	end--if
end-- 
----------------------------------------------------------------------------
am_variable_subscribe("am_latbuttonrevstate","INT",new_latbuttonrevstate)
new_latbuttonrevstate(1) -- force la jauge sur ON en mode debug 
----------------------------------------------------------------------------
-- Button 1 (TPS)
function new_latbutton1state(latbutton1state)
buttonpressed=true
--print(latbutton1state)
if (latbutton1state==1) then
	if tapes_displayed==false then
	display_tapes(true) 
	else
	display_tapes(false)
	end
end
end
am_variable_subscribe("am_latbutton1state","INT",new_latbutton1state)

-- Button 2 (MIN)
function new_latbutton2state(latbutton2state)
buttonpressed=true
--print(latbutton2state)
if latbutton2state==1 then
	-- si l'affichage des tapes a été demandé
	if min_displayed == false then
		min_displayed = true
		
		-- affichage légende sur menu latéral
		visible(img_MINlegend_green,true)
		visible(img_MINlegend_gray,false)
	else
		min_displayed = false
		-- affichage légende sur menu latéral
		visible(img_MINlegend_green,false)		
		visible(img_MINlegend_gray,true)
	end
end--if
-- affichage du minimum

end-- 
am_variable_subscribe("am_latbutton2state","INT",new_latbutton2state)

-- Bottom Center button
function new_centerbuttonstate(HSIsource)
buttonpressed=true
if HSIsource>2 then 
HSIsource=1
end
if HSIsource==1 then
--txt_set(txt_centerbutton,"VLOC1")
hsimode=0
elseif HSIsource==2 then
hsimode=1
--txt_set(txt_centerbutton,"VLOC2")
else
hsimode=2
--txt_set(txt_centerbutton,"GPS1")
end

end
am_variable_subscribe("am_centerbuttonstate","INT",new_centerbuttonstate)

-- Bottom Left button
function new_leftbuttonstate(RMI1source)
buttonpressed=true
if RMI1source>3 then 
	RMI1source=0
end
if RMI1source==0 then
	txt_set(txt_leftbutton,"")
	rmi1mode=0 --VOR1
	visible(img_redslash_leftbutton,false)
elseif RMI1source==1 then
	rmi1mode=1 -- VOR2
elseif RMI1source==2 then
	rmi1mode=2
else
	rmi1mode=3 -- GPS1
end
end -- function
am_variable_subscribe("am_leftbuttonstate","INT",new_leftbuttonstate)

-- Bottom Right button
function new_rightbuttonstate(RMI2source)
buttonpressed=true
if RMI2source>3 then 
RMI2source=0
end
if RMI2source==0 then
txt_set(txt_rightbutton,"")
rmi2mode=0
visible(img_redslash_rightbutton,false)
elseif RMI2source==1 then
txt_set(txt_rightbutton,"VOR1")
rmi2mode=1
elseif RMI2source==2 then
rmi2mode=2
txt_set(txt_rightbutton,"VOR2")
else
rmi2mode=3
txt_set(txt_rightbutton,"GPS1")
end

end-- function
am_variable_subscribe("am_rightbuttonstate","INT",new_rightbuttonstate)
------------------------
-- Data bus subscribe --
------------------------
-- V-Speed values may be set for: 
-- •  Va – Design Maneuvering Speed 
-- •  Vbg – Best Glide Speed 
-- •  Vref – Approach Reference Speed 
-- •  Vr – Rotation Speed 
-- •  Vx – Best Angle of Climb Speed 
-- •  Vy – Best Rate of Climb Speed 
-- •  Vlo – Maximum Landing Gear Operating Speed 
-- •  Vle – Maximum Landing Gear Extended Speed 



xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot", "FLOAT",
					  "sim/cockpit/misc/radio_altimeter_minimum", "FLOAT",
					  "sim/flightmodel/misc/h_ind", "FLOAT", 
					  "sim/cockpit2/gauges/indicators/airspeed_kts_pilot", "FLOAT",
					  --"sim/aircraft/view/acf_Vne", "FLOAT",
					  --"sim/aircraft/view/acf_Vno", "FLOAT", 
					  "sim/cockpit/autopilot/altitude", "FLOAT", new_altitudeorspeed)
fsx_variable_subscribe("RADIO HEIGHT", "FEET",
					   "INDICATED ALTITUDE", "FEET",
					   "AIRSPEED INDICATED", "KNOTS",
					   "AUTOPILOT ALTITUDE LOCK VAR", "FEET", new_altitudeorspeed_fsx)
--------------------------------------------------------------------------------------------------------------------------
xpl_dataref_subscribe("sim/flightmodel/position/phi", "FLOAT",
					  "sim/flightmodel/position/theta", "FLOAT", 
					  "sim/cockpit2/gauges/indicators/slip_deg", "FLOAT", new_attitude)
fsx_variable_subscribe("ATTITUDE INDICATOR BANK DEGREES", "Degrees",
					   "ATTITUDE INDICATOR PITCH DEGREES", "Degrees",
					   --"INCIDENCE BETA", "Degrees", 
					   "TURN COORDINATOR BALL","Number",new_attitude_fsx)
--------------------------------------------------------------------------------------------------------------------------
xpl_dataref_subscribe("sim/cockpit/autopilot/airspeed", "FLOAT", 
					  "sim/cockpit/autopilot/altitude", "FLOAT", 
					  "sim/cockpit2/gauges/indicators/airspeed_kts_pilot", "FLOAT", new_infobartop)
fsx_variable_subscribe("AUTOPILOT AIRSPEED HOLD VAR", "Knots",
					   "AUTOPILOT ALTITUDE LOCK VAR", "Feet",
					   "AIRSPEED INDICATED", "KNOTS", new_infobartop)
--------------------------------------------------------------------------------------------------------------------------
xpl_dataref_subscribe("sim/cockpit/autopilot/autopilot_mode", "INT",
					  "sim/cockpit/autopilot/flight_director_pitch", "FLOAT",
					  "sim/cockpit/autopilot/flight_director_roll", "FLOAT", new_flight_director)
fsx_variable_subscribe("AUTOPILOT FLIGHT DIRECTOR ACTIVE", "BOOL",
					   "AUTOPILOT FLIGHT DIRECTOR PITCH", "Degrees",
					   "AUTOPILOT FLIGHT DIRECTOR BANK", "Degrees",
						"ATTITUDE INDICATOR PITCH DEGREES", "Degrees",
					   "ATTITUDE INDICATOR BANK DEGREES", "Degrees",new_flight_director_fsx)
--------------------------------------------------------------------------------------------------------------------------
xpl_dataref_subscribe("sim/flightmodel/position/true_airspeed", "FLOAT",
					  "sim/flightmodel/position/groundspeed", "FLOAT",
					  "sim/cockpit2/temperature/outside_air_temp_degc", "FLOAT",
					  "sim/cockpit2/gauges/indicators/wind_heading_deg_mag", "FLOAT", 
					  "sim/weather/wind_speed_kt", "FLOAT",
					  "sim/cockpit/gyros/psi_ind_degm3", "FLOAT",
					  "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot", "FLOAT", new_infobarcenter)
fsx_variable_subscribe("AIRSPEED TRUE", "Meters per second",
					   "GPS GROUND SPEED", "Meters per second",
					   "AMBIENT TEMPERATURE", "Celsius",
					   "AMBIENT WIND DIRECTION", "Degrees", 
					   "AMBIENT WIND VELOCITY", "Knots",
					   "GPS GROUND TRUE HEADING", "Degrees",
					   "KOHLSMAN SETTING HG", "inHg", new_infobarcenter)
--------------------------------------------------------------------------------------------------------------------------
xpl_dataref_subscribe("sim/cockpit/gyros/psi_ind_degm3", "FLOAT",
					  "sim/flightmodel/misc/turnrate_roll", "FLOAT", new_heading)
fsx_variable_subscribe("PLANE HEADING DEGREES GYRO", "Degrees", 
					   "DELTA HEADING RATE","Degrees",
					   new_heading_FSX)
--------------------------------------------------------------------------------------------------------------------------
xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/vvi_fpm_pilot", "FLOAT", new_vsi)
fsx_variable_subscribe("VERTICAL SPEED", "Feet per minute", new_vsi)
--------------------------------------------------------------------------------------------------------------------------
-- xpl_dataref_subscribe(
			  -- "sim/cockpit/gyros/psi_vac_ind_degm", "FLOAT",
              -- "sim/cockpit2/radios/actuators/HSI_source_select_pilot", "INT",
              -- "sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot", "FLOAT",
			  -- "sim/cockpit/radios/nav1_fromto","INT",
			  -- "sim/cockpit/radios/nav2_fromto","INT",
			  -- "sim/cockpit/radios/gps_fromto","INT",
              -- "sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot", "FLOAT",
              -- "sim/cockpit2/radios/indicators/nav2_hdef_dots_pilot", "FLOAT",
              -- "sim/cockpit2/radios/indicators/gps_hdef_dots_pilot", "FLOAT",
              -- "sim/cockpit2/radios/indicators/nav1_vdef_dots_pilot", "FLOAT",
              -- "sim/cockpit2/radios/indicators/nav2_vdef_dots_pilot", "FLOAT",
              -- "sim/cockpit2/radios/indicators/gps_vdef_dots_pilot", "FLOAT", 
              -- "sim/cockpit2/radios/indicators/nav1_display_horizontal", "INT", 
              -- "sim/cockpit2/radios/indicators/nav2_display_horizontal", "INT",
			  -- "sim/cockpit/autopilot/heading_mag", "FLOAT", 
			  -- "sim/cockpit/gyros/psi_ind_degm3", "FLOAT",
			  -- "sim/flightmodel/position/psi", "FLOAT", new_HSI)
--function new_HSI(heading, mode, crs, nav1flag, nav2flag, gpsflag, nav1hdef, nav2hdef, gpshdef, nav1vdef, nav2vdef, gpsvdef, nav1display, nav2display, hsihassignal, hsiwptfreq, hsiwptname, hsiwptbearing, hsiwptdme,hsiwptspeed,apheading, elecheading, groundtrack,)
   


fsx_variable_subscribe(
					"NAV IDENT:1","String",					
					"NAV ACTIVE FREQUENCY:1","Megahertz",
					"NAV OBS:1", "Degrees",
					"NAV HAS NAV:1","Bool",
					"NAV TOFROM:1","Number", 
					"NAV HAS LOCALIZER:1","Bool",
					"NAV CDI:1", "Number",
					"NAV HAS GLIDE SLOPE:1", "Bool",
					"NAV GS FLAG:1", "Bool", 
					"NAV GSI:1", "Number",
					"NAV RADIAL:1","Degrees",
					"NAV DME:1","Nautical miles",
					"NAV DMESPEED:1","Knots",						
					"NAV IDENT:2","String",					
					"NAV ACTIVE FREQUENCY:2","Megahertz",
					"NAV OBS:2", "Degrees",
					"NAV HAS NAV:2","Bool",
					"NAV TOFROM:2","Number", 
					"NAV HAS LOCALIZER:2","Bool",
					"NAV CDI:2", "Number",
					"NAV HAS GLIDE SLOPE:2", "Bool",
					"NAV GS FLAG:2", "Bool", 
					"NAV GSI:2", "Number",
					"NAV RADIAL:2","Degrees",
					"NAV DME:2","Nautical miles",
					"NAV DMESPEED:2","Knots",					
					"GPS WP DESIRED TRACK", "Degrees",-- obs en mode GPS
					"NAV IDENT","String",
					"GPS WP BEARING","Degrees",
					"GPS WP DISTANCE","Nautical miles",
					"GPS WP ETE","Hours",			
					"AUTOPILOT HEADING LOCK DIR", "Degrees",
					"PLANE HEADING DEGREES GYRO", "Degrees",
					"GPS GROUND TRUE TRACK", "Degrees",					   
						new_HSI_FSX)
					-- "HSI STATION IDENT","String",	
					-- "HSI BEARING VALID","BOOL",
   					-- "HSI TF FLAG","Number"	
					-- "HSI CDI NEEDLE VALID","BOOL",
					-- "HSI HAS LOCALIZER","BOOL",
					-- "HSI CDI NEEDLE","Number",
					-- "HSI GSI NEEDLE VALID","BOOL",
					-- "HSI GSI NEEDLE","Number",
					-- "HSI BEARING","Degrees",
					-- "HSI DISTANCE","Nautical miles",
					-- "HSI SPEED","Knots",	
-- function new_HSI(heading,cdimode, rmi1mode,rmi2mode, nav1wptname, nav1wptfreq, nav1obs, nav1hasnav, nav1flag, nav1hasloc, nav1hdef, nav1hasgs, nav1gsflag, nav1vdef, nav1bearing, nav1dme, nav1speed,nav2wptname, nav2wptfreq, nav2obs, nav2hasnav, nav2flag, nav2hasloc, nav2hdef, nav2hasgs, nav2gsflag, nav2vdef, nav2bearing, nav2dme, nav2speed,gpsbearing, gpswptname, gpshdef, gpswptbearing, gpswptdme, gpswptete, apheading, elecheading, groundtrack) --nav1display, nav2display
