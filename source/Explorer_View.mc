using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Math;
using Toybox.Timer;
using Toybox.Time.Gregorian;
using Toybox.Application.Properties;

// buffered background screen offset;

// text align - center vertical and horizontal
const cAlign = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;
const cTransparent = Graphics.COLOR_TRANSPARENT;
/**
Watch view.
 */
class Explorer_View extends WatchUi.WatchFace {


    var f_hands = null;
	var current_hand = null;
	var hour = null;
    var minute = null;
    var second = null;
    var isAwake = true;
    var mBackGroundColor = 0x000000;
    var mForeGroundColor = 0xffffff;
    var mHandsOutline = 0x323232;
    var mSecondHandOn;
    var screenW = 240;
    var screenH = 240;
    var mBatteryWarningLevel = 20;
    var _partialUpdatesAllowed as Boolean;
   
    // hands.json offsets
    enum {
        PosSecond,
        PosMinute = 5,
        PosHour = 13,
        PosEOF2 = 21
    }

    var mHourHand;
    var mMinuteHand;

    var mBuffer;
    var mBackground;

    // String resources
    var cWeekDays, cMonths;

    // prev clip
    var fx, fy, gx, gy;
    // clip
    var ax, ay, bx, by;
   
    var r0, r1;

    // buffer pos
    var bufx, bufy, bufw, bufh, center;



    var mSmallyFont, mDayFont, mDateFont;

    function initialize() {
        WatchFace.initialize();
        _partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);


    }








    // Load your resources here
    function onLayout(dc) {   
     	   
        bufw = loadResource(Rez.Strings.bufferw).toNumber();
        bufh = loadResource(Rez.Strings.bufferh).toNumber();
        

        bufx = loadResource(Rez.Strings.bufferX).toNumber();
        bufy = loadResource(Rez.Strings.bufferY).toNumber();
        center = loadResource(Rez.Strings.center).toNumber();

        var data = loadResource(Rez.JsonData.hands_json);

   	            screenW = dc.getWidth();
	            screenH = dc.getHeight();
	            ax = screenW;
	            ay = screenH;
	            bx = 0;
                by = 0;
	            r0 = loadResource(Rez.Strings.r0).toNumber();
	            r1 = loadResource(Rez.Strings.r1).toNumber();
        mBuffer = new Graphics.BufferedBitmap({
                :width=>bufw,
                :height=>bufh
        });
               
    }


    function getXY(i, data) {
        var d = data[i / 2];
        var shift = (i % 2 == 0)? 16: 0;
        var x = (d >> (shift + 8)) & 0xFF;
        var y = (d >> shift) & 0xFF;
        return [x, y];
    }

    function updateClip(x, y) {
        if (ax > x) {
            ax = x;
        }
        if (bx < x) {
            bx = x;
        }
        if (ay > y) {
            ay = y;
        }
        if (by < y) {
            by = y;
        }
    }
					   



	   function drawDialMarkers(targetDc,this_x,this_y) {		      


      	// let's load the dial resources
      		    
	  	
	  	
	  	      // draw dials
      // --------------------------

      // let's load the dial resources
      f_hands = loadResource(Rez.Fonts.dial_markers_font);
      current_hand = loadResource(Rez.JsonData.dial_markers_data);

      // draw chapters
      targetDc.setColor(mForeGroundColor, Graphics.COLOR_TRANSPARENT);
      drawTiles(current_hand[0],f_hands,targetDc,this_x,this_y);
		  	
	  	}  							   



	   function drawDialChapters(targetDc,this_x,this_y) {		      



      	// let's load the dial resources
      		    
	  	
	  	
	  	      // draw dials
      // --------------------------

      // let's load the dial resources
      f_hands = loadResource(Rez.Fonts.dial_chapters_font);
      current_hand = loadResource(Rez.JsonData.dial_chapters_data);

      // draw chapters
      targetDc.setColor(0xffffff, Graphics.COLOR_TRANSPARENT);
      drawTiles(current_hand[0],f_hands,targetDc,this_x,this_y);

      // draw markers outline
       targetDc.setColor(mHandsOutline, Graphics.COLOR_TRANSPARENT);
      drawTiles(current_hand[1],f_hands,targetDc,this_x,this_y);
	  	
	  	
	  	}  
								  
								  
								  
			 function drawTime(targetDc,this_x,this_y) {	
			    
			  // draw hour hand
								      
			  var hour_is = (Math.floor((hour+(minute/60.0))*5.0)).toNumber()%60;
			  var hr_is = hour_is;
			
			  // load the appropriate tilemaps as
			  // hours are split across four tilemaps;
			  // 0_14, 15_29, 30_44, 45_59
			  if (hour_is>=55 && hour_is<=59) {
			    f_hands = loadResource(Rez.Fonts.font_hour_55_59);
			    current_hand = loadResource(Rez.JsonData.font_hour_55_59_data);
			    hr_is = hour_is - 55;
			  }
			  if (hour_is>=50 && hour_is<=54) {
			    f_hands = loadResource(Rez.Fonts.font_hour_50_54);
			    current_hand = loadResource(Rez.JsonData.font_hour_50_54_data);
			    hr_is = hour_is - 50;
			  }
			  if (hour_is>=45 && hour_is<=49) {
			    f_hands = loadResource(Rez.Fonts.font_hour_45_49);
			    current_hand = loadResource(Rez.JsonData.font_hour_45_49_data);
			    hr_is = hour_is - 45;
			  }
			 if (hour_is>=40 && hour_is<=44) {
			    f_hands = loadResource(Rez.Fonts.font_hour_40_44);
			    current_hand = loadResource(Rez.JsonData.font_hour_40_44_data);
			    hr_is = hour_is - 40;
			  }
			  if (hour_is>=35 && hour_is<=39) {
			    f_hands = loadResource(Rez.Fonts.font_hour_35_39);
			    current_hand = loadResource(Rez.JsonData.font_hour_35_39_data);
			    hr_is = hour_is - 35;
			  }
			  if (hour_is>=30 && hour_is<=34) {
			    f_hands = loadResource(Rez.Fonts.font_hour_30_34);
			    current_hand = loadResource(Rez.JsonData.font_hour_30_34_data);
			    hr_is = hour_is - 30;
			  }
			  if (hour_is>=25 && hour_is<=29) {
			    f_hands = loadResource(Rez.Fonts.font_hour_25_29);
			    current_hand = loadResource(Rez.JsonData.font_hour_25_29_data);
			    hr_is = hour_is - 25;
			  }
			  if (hour_is>=20 && hour_is<=24) {
			    f_hands = loadResource(Rez.Fonts.font_hour_20_24);
			    current_hand = loadResource(Rez.JsonData.font_hour_20_24_data);
			    hr_is = hour_is - 20;
			  }
			  if (hour_is>=15 && hour_is<=19) {
			    f_hands = loadResource(Rez.Fonts.font_hour_15_19);
			    current_hand = WatchUi.loadResource(Rez.JsonData.font_hour_15_19_data);
			    hr_is = hour_is - 15;
			  }
			 if (hour_is>=10 && hour_is<=14) {
			    f_hands = loadResource(Rez.Fonts.font_hour_10_14);
			    current_hand = WatchUi.loadResource(Rez.JsonData.font_hour_10_14_data);
			    hr_is = hour_is - 10;
			  }
			  if (hour_is>=5 && hour_is<=9) {
			    f_hands = loadResource(Rez.Fonts.font_hour_5_9);
			    current_hand = loadResource(Rez.JsonData.font_hour_5_9_data);
			    hr_is = hour_is - 5;
			  }
			 if (hour_is>=0 && hour_is<=4) {
			    f_hands = loadResource(Rez.Fonts.font_hour_0_4);
			    current_hand = loadResource(Rez.JsonData.font_hour_0_4_data);
			    hr_is = hour_is;
			  }
			
			  // let's draw the actual hour hand tilemap   0x4B4B4B
			  targetDc.setColor(0xffffff, Graphics.COLOR_TRANSPARENT);
			  drawTiles(current_hand[hr_is+5],f_hands,targetDc,this_x,this_y);
			  targetDc.setColor(mHandsOutline, Graphics.COLOR_TRANSPARENT);
			  drawTiles(current_hand[hr_is],f_hands,targetDc,this_x,this_y);
			
			
			  // draw minute hand
			  // --------------------------
			
			  var min = minute;
			
			  // load the appropriate tilemaps as
			  // minutes are split across four tilemaps;
			  // 0_14, 15_29, 30_44, 45_59
			  if (minute>=50 && minute<=59) {
			    f_hands = loadResource(Rez.Fonts.font_min_50_59);
			    current_hand = loadResource(Rez.JsonData.font_min_50_59_data);
			    min = minute - 50;
			  }
			  if (minute>=40 && minute<=49) {
			    f_hands = loadResource(Rez.Fonts.font_min_40_49);
			    current_hand = loadResource(Rez.JsonData.font_min_40_49_data);
			    min = minute - 40;
			  }
			  if (minute>=30 && minute<=39) {
			    f_hands = loadResource(Rez.Fonts.font_min_30_39);
			    current_hand = loadResource(Rez.JsonData.font_min_30_39_data);
			    min = minute - 30;
			  }
			  if (minute>=20 && minute<=29) {
			    f_hands = loadResource(Rez.Fonts.font_min_20_29);
			    current_hand = loadResource(Rez.JsonData.font_min_20_29_data);
			    min = minute - 20;
			  }
			  if (minute>=10 && minute<=19) {
			    f_hands = loadResource(Rez.Fonts.font_min_10_19);
			    current_hand = loadResource(Rez.JsonData.font_min_10_19_data);
			    min = minute - 10;
			  }
			  if (minute>=0 && minute<=9) {
			    f_hands = loadResource(Rez.Fonts.font_min_0_9);
			    current_hand = loadResource(Rez.JsonData.font_min_0_9_data);
			    min = minute;
			  }
			
			  // let's draw the actual minute hand tilemap
			  targetDc.setColor(0xffffff, Graphics.COLOR_TRANSPARENT);
			  drawTiles(current_hand[min+10],f_hands,targetDc,this_x,this_y);
			  targetDc.setColor(mHandsOutline, Graphics.COLOR_TRANSPARENT);
			  drawTiles(current_hand[min],f_hands,targetDc,this_x,this_y);
			
			}    
    

  
	    /**
	    Draws second hand poligon and accent
	
	    * second hand is always drawed directly to device
	    * thus, center is always (center, center)
	    * accent r radial coord is (80, 95)
	
	    dc - device only context
	    time - local time
	     */
	    function drawSecondHand(dc, withBuffer) {


            if (mSecondHandOn) {
            
	        if(dc has :setAntiAlias) {
               dc.setAntiAlias(true);
            }
	        
	        fx = ax;
	        fy = ay;
	        gx = bx;
	        gy = by;
	        ax = screenW;
	        ay = screenH;
	        bx = 0;
	        by = 0;
	        var pos;
	        pos = Gregorian.info(Time.now(), Time.FORMAT_SHORT).sec * 6;
	        var angle = Math.toRadians(pos);
            //angle = 0;
	        //clip edges

	       	//var points = fillRadialPolygon(dc, angle, mSecondCoords, center, center);
	       
	       
	       var sa = Math.sin(angle);
	       var ca = Math.cos(angle);
              
	      //second hand clip referference points
	      var tail_x_center = (r0-5)*sa;  
	      var tail_x_offset = 5*ca;
	      var tail_y_center = (r0-5)*ca;  
	      var tail_y_offset = 5*sa;
	        	        
	      var tip_x_center= (r1+1)*sa;  
	      var tip_x_offset = 9*ca;
	      var tip_y_center = (r1+1)*ca;  
	      var tip_y_offset = 9*sa; 	        
	        	        
	        	      
	       		
			var hand =      [
							[center+tail_x_center-tail_x_offset,center-tail_y_center-tail_y_offset],						
							[center+tip_x_center-tip_x_offset,center-tip_y_center-tip_y_offset],
					        [center+tip_x_center+tip_x_offset,center-tip_y_center+tip_y_offset],
					        [center+tail_x_center+tail_x_offset,center-tail_y_center+tail_y_offset]					
								];	
	        
	        
	        /**
						
						
		var hand =      [
							[center+(r0*sa)-(20*ca),center-(r0*ca)-(20*sa)],						
							[center+(r1*sa)-(20*ca),center-(r1*ca)-(20*sa)],
					        [center+(r1*sa)+(20*ca),center-(r1*ca)+(20*sa)],
					        [center+(r0*sa)+(20*ca),center-(r0*ca)+(20*sa)]					
								];	
							
	        */
	        
	        
	        
	        var points = hand;
	        	       
	        updateClip(points[0][0], points[0][1]);
	        updateClip(points[1][0], points[1][1]);
	        updateClip(points[2][0], points[2][1]);
	        updateClip(points[3][0], points[3][1]);

	        
	                   
                      
	        if (withBuffer) {
	            var mx = (fx < ax)? fx: ax;
	            var my = (fy < ay)? fy: ay;
	            var nx = (gx > bx)? gx: bx;
	            var ny = (gy > by)? gy: by;
	            dc.setClip(mx, my, Math.ceil(nx - mx + 1), Math.ceil(ny - my + 1));
	            //dc.setClip(12,12,216,216);
	            dc.drawBitmap(bufx, bufy, mBuffer);

	        }
	
	       	

							
			//dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
		    //dc.fillPolygon(hand);		
		    
		    dc.setPenWidth(1);
	        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
	        dc.drawCircle(center, center, 9);

	   	    
	   	    
	   	    dc.setPenWidth(2);
			var tail_center_x = center+(r0)*sa;
			var tail_center_y = center-(r0)*ca;
			dc.setColor(mHandsOutline, Graphics.COLOR_TRANSPARENT);
			dc.drawLine(tail_center_x, tail_center_y,
			center+(r1)*sa,center-(r1)*ca);
			
			
			//Big circle
			dc.setPenWidth(2);
			var b_Center_x= center+(r1*0.65)*sa;
			var b_Center_y= center-(r1*0.65)*ca;
			var b_radius = 8;
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.fillCircle(b_Center_x,b_Center_y,b_radius);		
			dc.setColor(mHandsOutline, Graphics.COLOR_TRANSPARENT);
			dc.drawCircle(b_Center_x,b_Center_y,b_radius);
		
		    //little circle
			dc.setPenWidth(2);
			var l_radius = 4;
			dc.setColor(mHandsOutline, Graphics.COLOR_TRANSPARENT);
			dc.fillCircle(tail_center_x, tail_center_y, l_radius);		
			//dc.setColor(mHandsOutline, Graphics.COLOR_TRANSPARENT);
			//dc.drawCircle(center+(r0)*Math.sin(angle),center-(r0)*Math.cos(angle),3);
		    
	          
	       
	        // Draw second hand main polygon
	        //dc.setColor(Graphics.COLOR_RED, cTransparent);
	        //dc.fillPolygon(points);
	        // Draw red line for hand accent
	        //dc.setColor(Graphics.COLOR_DK_GRAY, cTransparent);
	        //dc.drawLine(x1, y1, x2, y2);
	        // Draw second hand cap;

	        
	         dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
	         dc.fillCircle(center, center, 2);

	        
              }

	        
	        
	    }

    


				function drawTiles(current_hand,font,dc,xoff,yoff) {
				
				  for(var i = 0; i < current_hand.size(); i++)
				  {
				    var packed_value = current_hand[i];
				
				    var char = (packed_value&0x00000FFF);
				    var xpos = (packed_value&0x003FF000)>>12;
				    var ypos = (packed_value&0xFFC00000)>>22;
				
				    dc.drawText(xoff+xpos,yoff+ypos,font,(char.toNumber()).toChar(),Graphics.TEXT_JUSTIFY_LEFT);
				  }
				}

   
   
    function onPartialUpdate(dc) {
            //var time = System.getClockTime();
            //System.println(Lang.format("$1$:$2$:$3$ onPartialUpdate", [time.hour, time.min, time.sec]));
         drawSecondHand(dc, true);

    }
    
    

	    // Update the view
	    function onUpdate(dc) {
	    
	          var clockTime = System.getClockTime();
	          var bc = null;
	          hour = clockTime.hour;
	          minute = clockTime.min;
	          second=clockTime.sec;
	          mForeGroundColor = 0xffffff;
              mHandsOutline = 0x323232;
	          mSecondHandOn = Properties.getValue("SecHandEnable");
	          mBackGroundColor =  Properties.getValue("backgroundColor");
	          mBatteryWarningLevel = Properties.getValue("BatteryWarningLevel");
	        
	        
	        if(mBackGroundColor!=0) 
	        {mForeGroundColor = 0x000000; 
	        mHandsOutline = 0x000000; 
	        }  
 
	    
	        // Prepare all data
	
	        // System.println(Lang.format("$1$:$2$:$3$ onUpdate", [clockTime.hour, clockTime.min, clockTime.sec]));
	        var pos, angle;
	 
	 	    dc.setColor(mBackGroundColor, mBackGroundColor);
            dc.clear();

      	   
      	   
      	    //dc.setColor(mForeGroundColor, mBackGroundColor);
     	    //drawDialMarkers(dc,0,0);
	 
	 
	       // If we have an offscreen buffer that we are using to draw the background,
	       // set the draw context of that buffer as our target.
	        if (null != mBuffer) {
	            dc.clearClip();
	            bc = mBuffer.getDc();
	            }  else
	            {
	            dc = bc;
	        }
	
	        //Clears Buffer
	        bc.setColor(mBackGroundColor, mBackGroundColor);
	        bc.clear();
	        
     	    
	        //draw dial objects to buffer    
            drawDialMarkers(bc,-bufx,-bufy);
	        drawDialChapters(bc,-bufx,-bufy);
	       
	        
	        //var dial_marks_font  = loadResource(Rez.Fonts.dial_marks_font); 
      	    //bc.setColor(mForeGroundColor, Graphics.COLOR_TRANSPARENT);
     	    //bc.drawText(0, 0, dial_marks_font, " ", Graphics.TEXT_JUSTIFY_LEFT);
     	    
     	    
	       ///draw battery warning
	       if ((System.getSystemStats().battery + 0.5) <= mBatteryWarningLevel) {
		            var battery_font = loadResource(Rez.Fonts.battery);
		            bc.setColor(mForeGroundColor, Graphics.COLOR_TRANSPARENT);
		            bc.drawText(screenW/2-bufx, (screenH/2-bufy)/2.4, battery_font, "!", Graphics.TEXT_JUSTIFY_CENTER);
		                      }
		      
		      
		      
		               //Draw Phone Connection Warning to buffer
		   if(Properties.getValue("ConnectionWarningOn")) {
		   if (Toybox.System.getDeviceSettings().phoneConnected ) { }        
           else {		   
		   var icon_set_01 = loadResource(Rez.Fonts.icon_set_01_font);
		   bc.setColor(mForeGroundColor, Graphics.COLOR_TRANSPARENT);
		   bc.drawText(screenW/4.1, screenH/1.9, icon_set_01, "k", Graphics.TEXT_JUSTIFY_CENTER);   
		   }      
           }
           
           
                           
		    //Draw Date to buffer
	        var today = Gregorian.info(Time.now(), Time.FORMAT_LONG);
	        var acumin_font = loadResource(Rez.Fonts.acumin_font);
	        var dateStr = today.day_of_week.toUpper() + " " + today.day.format("%.2d");
	        bc.setColor(mForeGroundColor, Graphics.COLOR_TRANSPARENT);
	        bc.drawText(212*screenW/240, 89*screenH/240, acumin_font, dateStr, Graphics.TEXT_JUSTIFY_RIGHT);                                  
	        
	        
	        //draw digital clock
	        /*
	        	bc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
	        	var digital_font = loadResource(Rez.Fonts.digital_font);
	        	//var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
    	   		 //bc.drawText(130,140,digital_font,timeString, Graphics.TEXT_JUSTIFY_RIGHT);
	        	        
	        	if (isAwake) {
     		  	var timeString = Lang.format("$1$:$2$:$3$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d"),clockTime.sec.format("%02d")]);
     		  //var secondString = Lang.format(":$1$", [clockTime.sec.format("%02d")]);
     		   //System.println("isAwake");
     		  	bc.drawText(108,50,digital_font,timeString, Graphics.TEXT_JUSTIFY_CENTER);
     	   			}
     	   	*/		
	        
	        
	        //draw time to buffer
	        drawTime(bc,-bufx,-bufy);
		    // System.println("draw from buffer");

      		  
		    //draw everything from bugger
	        dc.setColor(mBackGroundColor, mBackGroundColor);
     	    dc.clear();
     	    drawDialMarkers(dc,0,0);
	        dc.drawBitmap(bufx, bufy, mBuffer);

	        


		     if (isAwake) {
		            // System.println("second hand");
		            // Drawind second hand to device context;
		            // (only in active/background modes
		         drawSecondHand(dc, false);
		       } else if (_partialUpdatesAllowed) { onPartialUpdate(dc); }
	        
	        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
	        dc.fillCircle(center, center, 2);
        
	  
	    }



    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        //System.println("onShow");
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        //System.println("onHide");
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        //System.println("onExitSleep");
        isAwake = true;
        
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        //System.println("onEnterSleep");
        isAwake = false;
    }

    function timerCallback() {
        // System.println("RequestUpdate");
        WatchUi.requestUpdate();
    }

    //! Turn off partial updates
    function turnPartialUpdatesOff() as Void {
        _partialUpdatesAllowed = false;
    }

}


//! Receives watch face events
class Explorer_Delegate extends WatchUi.WatchFaceDelegate {
    var _view as Explorer_View;
    
    
    //! Constructor
    //! @param view The analog view
    function initialize(view as Explorer_View)  {
        WatchFaceDelegate.initialize();
        _view = view;
    }



   //! The onPowerBudgetExceeded callback is called by the system if the
    //! onPartialUpdate method exceeds the allowed power budget. If this occurs,
    //! the system will stop invoking onPartialUpdate each second, so we notify the
    //! view here to let the rendering methods know they should not be rendering a
    //! second hand.
    //! @param powerInfo Information about the power budget
    function onPowerBudgetExceeded(powerInfo) {
        System.println("Average execution time: " + powerInfo.executionTimeAverage);
        System.println("Allowed execution time: " + powerInfo.executionTimeLimit);
        _view.turnPartialUpdatesOff();
    }
}



