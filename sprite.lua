-- 
-- Abstract: sprite library
-- 
-- Version: 1.0
-- 
-- Disclaimer: IMPORTANT:  This ANSCA software is supplied to you by ANSCA Inc.
-- ("ANSCA") in consideration of your agreement to the following terms, and your
-- use, installation, modification or redistribution of this ANSCA software
-- constitutes acceptance of these terms.  If you do not agree with these terms,
-- please do not use, install, modify or redistribute this ANSCA software.
-- 
-- In consideration of your agreement to abide by the following terms, and subject
-- to these terms, ANSCA grants you a personal, non-exclusive license, under
-- ANSCA's copyrights in this original ANSCA software (the "ANSCA Software"), to
-- use, reproduce, modify and redistribute the ANSCA Software, with or without
-- modifications, in source and/or binary forms; provided that if you redistribute
-- the ANSCA Software in its entirety and without modifications, you must retain
-- this notice and the following text and disclaimers in all such redistributions
-- of the ANSCA Software.
-- Neither the name, trademarks, service marks or logos of ANSCA Inc. may be used
-- to endorse or promote products derived from the ANSCA Software without specific
-- prior written permission from ANSCA.  Except as expressly stated in this notice,
-- no other rights or licenses, express or implied, are granted by ANSCA herein,
-- including but not limited to any patent rights that may be infringed by your
-- derivative works or by other works in which the ANSCA Software may be
-- incorporated.
-- 
-- The ANSCA Software is provided by ANSCA on an "AS IS" basis.  ANSCA MAKES NO
-- WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
-- WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE, REGARDING THE ANSCA SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
-- COMBINATION WITH YOUR PRODUCTS.
-- 
-- IN NO EVENT SHALL ANSCA BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
-- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
-- DISTRIBUTION OF THE ANSCA SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
-- CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
-- ANSCA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- Copyright (C) 2009 ANSCA Inc. All Rights Reserved.



-- sprite.lua (currently includes Anim class only)

module(..., package.seeall)


function newAnim (imageTable)

	-- Set up graphics
	local g = display.newGroup()
	local animFrames = {}
	local animLabels = {}

	local i = 1
	while imageTable[i] do
		animFrames[i] = display.newImage(imageTable[i]);
		g:insert(animFrames[i], true)
		animLabels[i] = i -- default frame label is frame number
		animFrames[i].isVisible = false
		i = i + 1
	end
	-- show first frame by default
	animFrames[1].isVisible = true 
	

	-------------------------
	-- Define private methods
	
	local currentFrame = 1

	local nextFrame = function()
		animFrames[currentFrame].isVisible = false
		currentFrame = currentFrame + 1
		if (currentFrame > #animFrames) then
			currentFrame = 1
		end
		animFrames[currentFrame].isVisible = true
	end
	
	local prevFrame = function()
		animFrames[currentFrame].isVisible = false
		currentFrame = currentFrame - 1
		if (currentFrame < 1) then
			currentFrame = #animFrames
		end
		animFrames[currentFrame].isVisible = true
	end
	

	------------------------
	-- Define public methods

	local repeatFunction

	function g:play()
		Runtime:removeEventListener( "enterFrame", repeatFunction )
		repeatFunction = nextFrame
		Runtime:addEventListener( "enterFrame", repeatFunction )
	end
	
	function g:reverse()
		Runtime:removeEventListener( "enterFrame", repeatFunction )
		repeatFunction = prevFrame
		Runtime:addEventListener( "enterFrame", repeatFunction )
	end
		
	function g:stop()
		Runtime:removeEventListener( "enterFrame", repeatFunction )
	end
		
	function g:stopAtFrame(label)
		-- This works for either numerical indices or optional text labels
		if (type(label) == "number") then
			Runtime:removeEventListener( "enterFrame", repeatFunction )
			animFrames[currentFrame].isVisible = false
			currentFrame = label
			animFrames[currentFrame].isVisible = true
		elseif (type(label) == "string") then
			for k, v in next, animLabels do
				if (v == label) then
					Runtime:removeEventListener( "enterFrame", repeatFunction )
					animFrames[currentFrame].isVisible = false
					currentFrame = k
					animFrames[currentFrame].isVisible = true
				end
			end
		end
	end

	-- Optional function to assign text labels to frames
	function g:setLabels(labelTable)
		for k, v in next, labelTable do
			if (type(k) == "string") then
				animLabels[v] = k
			end
		end		
	end
	
	-- Return instance of anim
	return g

end